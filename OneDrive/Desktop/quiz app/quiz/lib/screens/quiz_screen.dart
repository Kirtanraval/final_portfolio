// lib/screens/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/quiz_models.dart';
import '../providers/quiz_provider.dart';
import '../widgets/timer_ring.dart';
import '../widgets/lifeline_button.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  int _lastQuestionIndex = -1;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _slideAnim = Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _slideCtrl.forward();
  }

  void _animateNewQuestion() {
    _slideCtrl.reset();
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();

    if (quiz.status == QuizStatus.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/result');
      });
    }

    final session = quiz.session;
    if (session == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Detect question change
    if (_lastQuestionIndex != session.currentIndex) {
      _lastQuestionIndex = session.currentIndex;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _animateNewQuestion());
    }

    final q = session.currentQuestion;

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitDialog(context);
        return shouldExit;
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Column(
            children: [
              // ─── Top Bar ───────────────────────────────────────────────
              _buildTopBar(context, quiz, session),
              // ─── Progress ──────────────────────────────────────────────
              _buildProgressBar(session),
              // ─── Hint Banner ───────────────────────────────────────────
              if (quiz.showHint) _buildHintBanner(context, quiz),
              // ─── Question ──────────────────────────────────────────────
              Expanded(
                child: SlideTransition(
                  position: _slideAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuestionCard(quiz, session, q),
                          const SizedBox(height: 20),
                          ..._buildOptions(quiz, session, q),
                          if (quiz.showFeedback) ...[
                            const SizedBox(height: 20),
                            _buildFeedback(quiz, q),
                          ],
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // ─── Lifelines ─────────────────────────────────────────────
              _buildLifelines(quiz, session),
              // ─── Next Button ───────────────────────────────────────────
              if (quiz.showFeedback) _buildNextButton(context, quiz, session),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
      BuildContext context, QuizProvider quiz, QuizSession session) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showExitDialog(context).then((v) {
              if (v && mounted) Navigator.pop(context);
            }),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.close_rounded,
                  color: AppColors.textSecondary, size: 20),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.category.label,
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      color: AppColors.textSecondary),
                ),
                Text(
                  'Question ${session.currentIndex + 1} of ${session.totalQuestions}',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          // Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
                const SizedBox(width: 5),
                Text(
                  '${session.score}',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w700,
                      color: AppColors.gold,
                      fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Streak
          if (session.streak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: AppColors.error, size: 16),
                  const SizedBox(width: 4),
                  Text('${session.streak}',
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                          fontSize: 15)),
                ],
              ),
            ),
          const SizedBox(width: 12),
          // Timer ring
          TimerRing(progress: quiz.timerProgress, seconds: quiz.timeRemaining),
        ],
      ),
    );
  }

  Widget _buildProgressBar(QuizSession session) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: session.progress,
          backgroundColor: AppColors.border,
          valueColor: AlwaysStoppedAnimation(AppColors.accent),
          minHeight: 4,
        ),
      ),
    );
  }

  Widget _buildHintBanner(BuildContext context, QuizProvider quiz) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.gold, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              quiz.currentHint ?? '',
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  color: AppColors.gold.withOpacity(0.9)),
            ),
          ),
          GestureDetector(
            onTap: quiz.dismissHint,
            child: Icon(Icons.close_rounded,
                color: AppColors.gold.withOpacity(0.6), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
      QuizProvider quiz, QuizSession session, Question q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: q.difficulty.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  q.difficulty.label,
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: q.difficulty.color),
                ),
              ),
              if (q.isAIGenerated) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '🤖 AI',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentLight),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            q.text,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOptions(
      QuizProvider quiz, QuizSession session, Question q) {
    return List.generate(q.options.length, (i) {
      final isEliminated = quiz.eliminatedOptions?.contains(i) == true;
      final isSelected = quiz.selectedAnswer == i;
      final isCorrect = i == q.correctIndex;
      final showResult = quiz.showFeedback;

      Color borderColor = AppColors.border;
      Color bgColor = AppColors.surfaceCard;
      Color textColor = AppColors.textPrimary;
      IconData? trailingIcon;

      if (isEliminated) {
        borderColor = AppColors.border.withOpacity(0.3);
        bgColor = AppColors.surfaceCard.withOpacity(0.3);
        textColor = AppColors.textMuted.withOpacity(0.4);
      } else if (showResult) {
        if (isCorrect) {
          borderColor = AppColors.success;
          bgColor = AppColors.success.withOpacity(0.12);
          textColor = AppColors.successLight;
          trailingIcon = Icons.check_circle_rounded;
        } else if (isSelected && !isCorrect) {
          borderColor = AppColors.error;
          bgColor = AppColors.error.withOpacity(0.1);
          textColor = AppColors.errorLight;
          trailingIcon = Icons.cancel_rounded;
        }
      } else if (isSelected) {
        borderColor = AppColors.accent;
        bgColor = AppColors.accent.withOpacity(0.12);
      }

      final labels = ['A', 'B', 'C', 'D'];

      return GestureDetector(
        onTap: isEliminated || showResult ? null : () => quiz.selectAnswer(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: borderColor,
                width: isSelected || (showResult && isCorrect) ? 1.5 : 1),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isEliminated
                      ? AppColors.border.withOpacity(0.2)
                      : showResult && isCorrect
                          ? AppColors.success.withOpacity(0.2)
                          : showResult && isSelected
                              ? AppColors.error.withOpacity(0.2)
                              : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isEliminated
                          ? AppColors.textMuted.withOpacity(0.3)
                          : textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  q.options[i],
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    decoration:
                        isEliminated ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon,
                    color: isCorrect ? AppColors.success : AppColors.error,
                    size: 22),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFeedback(QuizProvider quiz, Question q) {
    final isCorrect = quiz.wasCorrect;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppColors.success.withOpacity(0.08)
            : AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isCorrect
                ? AppColors.success.withOpacity(0.3)
                : AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_outline : Icons.info_outline,
                color: isCorrect ? AppColors.success : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect
                    ? 'Correct!'
                    : (quiz.selectedAnswer == -1 ? "Time's Up!" : 'Incorrect'),
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isCorrect ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            q.explanation,
            style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLifelines(QuizProvider quiz, QuizSession session) {
    if (quiz.showFeedback) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          LifelineButton(
            icon: Icons.looks_two_outlined,
            label: '50/50',
            isAvailable: session.lifelines[LifelineType.fiftyFifty] == true,
            onTap: quiz.useFiftyFifty,
          ),
          LifelineButton(
            icon: Icons.skip_next_outlined,
            label: 'Skip',
            isAvailable: session.lifelines[LifelineType.skip] == true,
            onTap: quiz.useSkip,
          ),
          LifelineButton(
            icon: Icons.lightbulb_outline,
            label: 'Hint',
            isAvailable: session.lifelines[LifelineType.hint] == true,
            onTap: quiz.useHint,
          ),
          LifelineButton(
            icon: Icons.timer_outlined,
            label: '+15s',
            isAvailable: session.lifelines[LifelineType.extraTime] == true,
            onTap: quiz.useExtraTime,
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(
      BuildContext context, QuizProvider quiz, QuizSession session) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: quiz.nextQuestion,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            session.isLastQuestion ? 'See Results' : 'Next Question',
            style: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Exit Quiz?',
            style: TextStyle(
                fontFamily: 'Outfit',
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700)),
        content: Text('Your progress will be lost.',
            style: TextStyle(
                fontFamily: 'Outfit', color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Continue')),
          ElevatedButton(
            onPressed: () {
              context.read<QuizProvider>().resetQuiz();
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
