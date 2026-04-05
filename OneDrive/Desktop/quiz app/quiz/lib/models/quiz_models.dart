// lib/models/quiz_models.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum Difficulty { easy, medium, hard, expert }

enum QuizCategory {
  generalKnowledge,
  science,
  history,
  geography,
  technology,
  mathematics,
  literature,
  sports,
  art,
  custom,
}

enum LifelineType { fiftyFifty, skip, hint, extraTime }

enum QuizStatus { idle, loading, active, paused, completed, error }

enum MultiplayerStatus { waiting, inProgress, completed, cancelled }

// ─── Extensions ──────────────────────────────────────────────────────────────

extension DifficultyExt on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
    }
  }

  Color get color {
    switch (this) {
      case Difficulty.easy:
        return AppColors.easy;
      case Difficulty.medium:
        return AppColors.medium;
      case Difficulty.hard:
        return AppColors.hard;
      case Difficulty.expert:
        return AppColors.expert;
    }
  }

  int get timeSeconds {
    switch (this) {
      case Difficulty.easy:
        return 30;
      case Difficulty.medium:
        return 20;
      case Difficulty.hard:
        return 15;
      case Difficulty.expert:
        return 10;
    }
  }

  int get baseScore {
    switch (this) {
      case Difficulty.easy:
        return 10;
      case Difficulty.medium:
        return 20;
      case Difficulty.hard:
        return 30;
      case Difficulty.expert:
        return 50;
    }
  }
}

extension QuizCategoryExt on QuizCategory {
  String get label {
    switch (this) {
      case QuizCategory.generalKnowledge:
        return 'General Knowledge';
      case QuizCategory.science:
        return 'Science';
      case QuizCategory.history:
        return 'History';
      case QuizCategory.geography:
        return 'Geography';
      case QuizCategory.technology:
        return 'Technology';
      case QuizCategory.mathematics:
        return 'Mathematics';
      case QuizCategory.literature:
        return 'Literature';
      case QuizCategory.sports:
        return 'Sports';
      case QuizCategory.art:
        return 'Art & Culture';
      case QuizCategory.custom:
        return 'Custom';
    }
  }

  IconData get icon {
    switch (this) {
      case QuizCategory.generalKnowledge:
        return Icons.lightbulb_outline;
      case QuizCategory.science:
        return Icons.science_outlined;
      case QuizCategory.history:
        return Icons.history_edu_outlined;
      case QuizCategory.geography:
        return Icons.public_outlined;
      case QuizCategory.technology:
        return Icons.computer_outlined;
      case QuizCategory.mathematics:
        return Icons.calculate_outlined;
      case QuizCategory.literature:
        return Icons.menu_book_outlined;
      case QuizCategory.sports:
        return Icons.sports_soccer_outlined;
      case QuizCategory.art:
        return Icons.palette_outlined;
      case QuizCategory.custom:
        return Icons.edit_outlined;
    }
  }

  Color get color {
    final colors = AppColors.categoryGradients;
    return colors[index % colors.length];
  }
}

// ─── Models ──────────────────────────────────────────────────────────────────

class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final Difficulty difficulty;
  final QuizCategory category;
  final String? hint;
  final bool isAIGenerated;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.difficulty,
    required this.category,
    this.hint,
    this.isAIGenerated = false,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] ?? '',
        text: json['text'] ?? '',
        options: List<String>.from(json['options'] ?? []),
        correctIndex: json['correctIndex'] ?? 0,
        explanation: json['explanation'] ?? '',
        difficulty: Difficulty.values.firstWhere(
          (d) => d.name == json['difficulty'],
          orElse: () => Difficulty.medium,
        ),
        category: QuizCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => QuizCategory.generalKnowledge,
        ),
        hint: json['hint'],
        isAIGenerated: json['isAIGenerated'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
        'difficulty': difficulty.name,
        'category': category.name,
        'hint': hint,
        'isAIGenerated': isAIGenerated,
      };
}

class QuizSession {
  final String id;
  final List<Question> questions;
  final Difficulty difficulty;
  final QuizCategory category;
  final int totalQuestions;
  final DateTime startTime;

  // Mutable state
  int currentIndex;
  List<int?> answers;
  int score;
  int streak;
  int maxStreak;
  Map<LifelineType, bool> lifelines;
  List<Duration> answerTimes;
  bool isCompleted;
  DateTime? endTime;

  QuizSession({
    required this.id,
    required this.questions,
    required this.difficulty,
    required this.category,
    required this.startTime,
  })  : totalQuestions = questions.length,
        currentIndex = 0,
        answers = List.filled(questions.length, null),
        score = 0,
        streak = 0,
        maxStreak = 0,
        lifelines = {
          LifelineType.fiftyFifty: true,
          LifelineType.skip: true,
          LifelineType.hint: true,
          LifelineType.extraTime: true,
        },
        answerTimes = [],
        isCompleted = false;

  Question get currentQuestion => questions[currentIndex];
  bool get isLastQuestion => currentIndex == totalQuestions - 1;
  double get progress => (currentIndex + 1) / totalQuestions;
  int get correctCount => answers
      .where(
          (a) => a != null && questions[answers.indexOf(a)].correctIndex == a)
      .length;

  int get correctAnswers {
    int count = 0;
    for (int i = 0; i < answers.length; i++) {
      if (answers[i] != null && answers[i] == questions[i].correctIndex)
        count++;
    }
    return count;
  }

  double get accuracy =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;
  Duration get totalTime => (endTime ?? DateTime.now()).difference(startTime);

  int calculateScore(int questionIndex, int timeRemaining, int totalTime) {
    final q = questions[questionIndex];
    final isCorrect = answers[questionIndex] == q.correctIndex;
    if (!isCorrect) return 0;

    final base = q.difficulty.baseScore;
    final timeBonus = ((timeRemaining / totalTime) * base * 0.5).round();
    final streakBonus = streak > 2 ? (streak * 2) : 0;
    return base + timeBonus + streakBonus;
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  int totalScore;
  int gamesPlayed;
  int gamesWon;
  Map<QuizCategory, int> categoryScores;
  Map<Difficulty, int> difficultyStats;
  List<Achievement> achievements;
  int currentStreak;
  int maxStreak;
  DateTime lastPlayed;
  int rank;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.totalScore = 0,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    Map<QuizCategory, int>? categoryScores,
    Map<Difficulty, int>? difficultyStats,
    List<Achievement>? achievements,
    this.currentStreak = 0,
    this.maxStreak = 0,
    DateTime? lastPlayed,
    this.rank = 0,
  })  : categoryScores = categoryScores ?? {},
        difficultyStats = difficultyStats ?? {},
        achievements = achievements ?? [],
        lastPlayed = lastPlayed ?? DateTime.now();

  double get winRate => gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0;
  double get avgScore => gamesPlayed > 0 ? totalScore / gamesPlayed : 0;
}

class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final int score;
  final int rank;
  final int gamesPlayed;
  final double accuracy;
  final DateTime updatedAt;

  const LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.score,
    required this.rank,
    required this.gamesPlayed,
    required this.accuracy,
    required this.updatedAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        userId: json['userId'] ?? '',
        userName: json['userName'] ?? '',
        avatarUrl: json['avatarUrl'],
        score: json['score'] ?? 0,
        rank: json['rank'] ?? 0,
        gamesPlayed: json['gamesPlayed'] ?? 0,
        accuracy: (json['accuracy'] ?? 0).toDouble(),
        updatedAt: DateTime.parse(
            json['updatedAt'] ?? DateTime.now().toIso8601String()),
      );
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.unlockedAt,
  });
}

class MultiplayerRoom {
  final String id;
  final String hostId;
  final String hostName;
  final List<MultiplayerPlayer> players;
  final int maxPlayers;
  final QuizCategory category;
  final Difficulty difficulty;
  final int questionCount;
  MultiplayerStatus status;
  int currentQuestionIndex;
  List<Question>? questions;

  MultiplayerRoom({
    required this.id,
    required this.hostId,
    required this.hostName,
    required this.players,
    this.maxPlayers = 4,
    required this.category,
    required this.difficulty,
    this.questionCount = 10,
    this.status = MultiplayerStatus.waiting,
    this.currentQuestionIndex = 0,
    this.questions,
  });

  bool get isFull => players.length >= maxPlayers;
  bool get canStart =>
      players.length >= 2 && status == MultiplayerStatus.waiting;
}

class MultiplayerPlayer {
  final String userId;
  final String name;
  final String? avatarUrl;
  int score;
  int answeredCount;
  bool isReady;
  bool isHost;

  MultiplayerPlayer({
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.score = 0,
    this.answeredCount = 0,
    this.isReady = false,
    this.isHost = false,
  });
}

class QuizResult {
  final String sessionId;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final Duration totalTime;
  final double accuracy;
  final int maxStreak;
  final Difficulty difficulty;
  final QuizCategory category;
  final List<Question> questions;
  final List<int?> answers;
  final DateTime completedAt;

  const QuizResult({
    required this.sessionId,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.totalTime,
    required this.accuracy,
    required this.maxStreak,
    required this.difficulty,
    required this.category,
    required this.questions,
    required this.answers,
    required this.completedAt,
  });

  String get grade {
    if (accuracy >= 90) return 'A+';
    if (accuracy >= 80) return 'A';
    if (accuracy >= 70) return 'B';
    if (accuracy >= 60) return 'C';
    return 'D';
  }
}
