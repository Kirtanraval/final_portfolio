// lib/providers/quiz_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/quiz_models.dart';
import '../services/ai_question_service.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QuizProvider extends ChangeNotifier {
  static final _uuid = Uuid();

  // ─── Quiz Session State ───────────────────────────────────────────────────
  QuizSession? _session;
  QuizStatus _status = QuizStatus.idle;
  String? _error;
  bool _isAIMode = false;

  // ─── Timer State ──────────────────────────────────────────────────────────
  Timer? _timer;
  int _timeRemaining = 30;
  int _totalTime = 30;

  // ─── Answer Feedback ──────────────────────────────────────────────────────
  int? _selectedAnswer;
  bool _showFeedback = false;
  bool _wasCorrect = false;

  // ─── Lifeline State ───────────────────────────────────────────────────────
  List<int>? _eliminatedOptions; // for 50/50
  String? _currentHint;
  bool _showHint = false;

  // ─── Analytics State ──────────────────────────────────────────────────────
  List<QuizResult> _history = [];
  UserProfile? _userProfile;

  // ─── Getters ──────────────────────────────────────────────────────────────
  QuizSession? get session => _session;
  QuizStatus get status => _status;
  String? get error => _error;
  bool get isAIMode => _isAIMode;
  int get timeRemaining => _timeRemaining;
  int get totalTime => _totalTime;
  int? get selectedAnswer => _selectedAnswer;
  bool get showFeedback => _showFeedback;
  bool get wasCorrect => _wasCorrect;
  List<int>? get eliminatedOptions => _eliminatedOptions;
  String? get currentHint => _currentHint;
  bool get showHint => _showHint;
  List<QuizResult> get history => _history;
  UserProfile? get userProfile => _userProfile;

  double get timerProgress => _totalTime > 0 ? _timeRemaining / _totalTime : 0;

  // ─── Initialization ───────────────────────────────────────────────────────
  Future<void> initialize() async {
    await _loadHistory();
    await _loadProfile();
  }

  // ─── Start Quiz ───────────────────────────────────────────────────────────
  Future<void> startQuiz({
    required QuizCategory category,
    required Difficulty difficulty,
    int questionCount = 10,
    bool useAI = false,
  }) async {
    _status = QuizStatus.loading;
    _error = null;
    _isAIMode = useAI;
    notifyListeners();

    try {
      List<Question> questions;

      if (useAI) {
        questions = await AIQuestionService.generateQuestions(
          category: category,
          difficulty: difficulty,
          count: questionCount,
        );
      } else {
        // Load from local static bank
        questions = await AIQuestionService.generateQuestions(
          category: category,
          difficulty: difficulty,
          count: questionCount,
        );
      }

      _session = QuizSession(
        id: _uuid.v4(),
        questions: questions,
        difficulty: difficulty,
        category: category,
        startTime: DateTime.now(),
      );

      _status = QuizStatus.active;
      _resetQuestionState();
      _startTimer();
      notifyListeners();
    } catch (e) {
      _status = QuizStatus.error;
      _error = e.toString();
      notifyListeners();
    }
  }

  // ─── Timer ────────────────────────────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    _totalTime = _session!.difficulty.timeSeconds;
    _timeRemaining = _totalTime;

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        // Time's up — auto-submit null
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    _timer?.cancel();
    _selectedAnswer = -1; // -1 = timed out
    _showFeedback = true;
    _wasCorrect = false;

    final session = _session!;
    session.answers[session.currentIndex] = null;
    // Streak broken
    session.streak = 0;
    notifyListeners();

    // Auto-advance after 2s
    Future.delayed(const Duration(seconds: 2), nextQuestion);
  }

  // ─── Answer Submission ────────────────────────────────────────────────────
  void selectAnswer(int index) {
    if (_showFeedback || _selectedAnswer != null) return;
    if (_eliminatedOptions?.contains(index) == true) return;

    _timer?.cancel();
    _selectedAnswer = index;

    final session = _session!;
    final q = session.currentQuestion;
    _wasCorrect = index == q.correctIndex;

    session.answers[session.currentIndex] = index;
    session.answerTimes.add(
      DateTime.now().difference(session.startTime),
    );

    if (_wasCorrect) {
      session.streak++;
      if (session.streak > session.maxStreak) {
        session.maxStreak = session.streak;
      }
      session.score += session.calculateScore(
        session.currentIndex,
        _timeRemaining,
        _totalTime,
      );
    } else {
      session.streak = 0;
    }

    _showFeedback = true;
    notifyListeners();
  }

  // ─── Navigation ───────────────────────────────────────────────────────────
  void nextQuestion() {
    final session = _session!;

    if (session.isLastQuestion) {
      _completeQuiz();
      return;
    }

    session.currentIndex++;
    _resetQuestionState();
    _startTimer();
    notifyListeners();
  }

  void _resetQuestionState() {
    _selectedAnswer = null;
    _showFeedback = false;
    _wasCorrect = false;
    _eliminatedOptions = null;
    _currentHint = null;
    _showHint = false;
  }

  // ─── Lifelines ────────────────────────────────────────────────────────────
  void useFiftyFifty() {
    final session = _session!;
    if (session.lifelines[LifelineType.fiftyFifty] != true) return;
    if (_showFeedback) return;

    final q = session.currentQuestion;
    final correct = q.correctIndex;
    final wrong = List.generate(4, (i) => i).where((i) => i != correct).toList()
      ..shuffle();
    _eliminatedOptions = wrong.take(2).toList();

    session.lifelines[LifelineType.fiftyFifty] = false;
    notifyListeners();
  }

  void useSkip() {
    final session = _session!;
    if (session.lifelines[LifelineType.skip] != true) return;
    if (_showFeedback) return;

    _timer?.cancel();
    session.answers[session.currentIndex] = null; // skipped = null
    session.lifelines[LifelineType.skip] = false;
    session.streak = 0;

    notifyListeners();

    // Advance after brief delay
    Future.delayed(const Duration(milliseconds: 300), nextQuestion);
  }

  void useHint() {
    final session = _session!;
    if (session.lifelines[LifelineType.hint] != true) return;
    if (_showFeedback) return;

    _currentHint =
        session.currentQuestion.hint ?? 'No hint available for this question.';
    _showHint = true;
    session.lifelines[LifelineType.hint] = false;
    notifyListeners();
  }

  void useExtraTime() {
    final session = _session!;
    if (session.lifelines[LifelineType.extraTime] != true) return;
    if (_showFeedback) return;

    _timeRemaining += 15;
    if (_timeRemaining > _totalTime) _totalTime = _timeRemaining;
    session.lifelines[LifelineType.extraTime] = false;
    notifyListeners();
  }

  void dismissHint() {
    _showHint = false;
    notifyListeners();
  }

  // ─── Complete Quiz ────────────────────────────────────────────────────────
  void _completeQuiz() {
    _timer?.cancel();
    final session = _session!;
    session.isCompleted = true;
    session.endTime = DateTime.now();

    final result = QuizResult(
      sessionId: session.id,
      score: session.score,
      correctAnswers: session.correctAnswers,
      totalQuestions: session.totalQuestions,
      totalTime: session.totalTime,
      accuracy: session.accuracy,
      maxStreak: session.maxStreak,
      difficulty: session.difficulty,
      category: session.category,
      questions: session.questions,
      answers: session.answers,
      completedAt: DateTime.now(),
    );

    _history.insert(0, result);
    _saveHistory();
    _updateProfile(result);

    _status = QuizStatus.completed;
    notifyListeners();
  }

  QuizResult? get latestResult => _history.isNotEmpty ? _history.first : null;

  // ─── Reset ────────────────────────────────────────────────────────────────
  void resetQuiz() {
    _timer?.cancel();
    _session = null;
    _status = QuizStatus.idle;
    _error = null;
    _resetQuestionState();
    notifyListeners();
  }

  // ─── Pause / Resume ───────────────────────────────────────────────────────
  void pauseQuiz() {
    if (_status != QuizStatus.active) return;
    _timer?.cancel();
    _status = QuizStatus.paused;
    notifyListeners();
  }

  void resumeQuiz() {
    if (_status != QuizStatus.paused) return;
    _status = QuizStatus.active;
    _startTimer();
    notifyListeners();
  }

  // ─── Persistence ──────────────────────────────────────────────────────────
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = _history
          .take(50) // Keep last 50
          .map((r) => jsonEncode({
                'sessionId': r.sessionId,
                'score': r.score,
                'correctAnswers': r.correctAnswers,
                'totalQuestions': r.totalQuestions,
                'totalTimeMs': r.totalTime.inMilliseconds,
                'accuracy': r.accuracy,
                'maxStreak': r.maxStreak,
                'difficulty': r.difficulty.name,
                'category': r.category.name,
                'completedAt': r.completedAt.toIso8601String(),
              }))
          .toList();
      await prefs.setStringList('quiz_history', encoded);
    } catch (_) {}
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList('quiz_history') ?? [];
      _history = raw.map((s) {
        final j = jsonDecode(s);
        return QuizResult(
          sessionId: j['sessionId'],
          score: j['score'],
          correctAnswers: j['correctAnswers'],
          totalQuestions: j['totalQuestions'],
          totalTime: Duration(milliseconds: j['totalTimeMs']),
          accuracy: (j['accuracy'] as num).toDouble(),
          maxStreak: j['maxStreak'],
          difficulty:
              Difficulty.values.firstWhere((d) => d.name == j['difficulty']),
          category:
              QuizCategory.values.firstWhere((c) => c.name == j['category']),
          questions: [],
          answers: [],
          completedAt: DateTime.parse(j['completedAt']),
        );
      }).toList();
    } catch (_) {}
  }

  Future<void> _loadProfile() async {
    _userProfile = UserProfile(
      id: 'local_user',
      name: 'Player',
      email: '',
      totalScore: _history.fold(0, (s, r) => s + r.score),
      gamesPlayed: _history.length,
    );
  }

  void _updateProfile(QuizResult result) {
    _userProfile ??= UserProfile(id: 'local_user', name: 'Player', email: '');
    _userProfile!.totalScore += result.score;
    _userProfile!.gamesPlayed++;
    if (result.accuracy >= 70) _userProfile!.gamesWon++;
    _userProfile!.lastPlayed = DateTime.now();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
