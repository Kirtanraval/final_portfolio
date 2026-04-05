// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/quiz_models.dart';
import '../providers/quiz_provider.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreCtrl;
  late AnimationController _cardCtrl;
  late Animation<double> _scoreAnim;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _scoreCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _cardCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _scoreAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _scoreCtrl, curve: Curves.easeOutCubic));
    _cardFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic));

    _scoreCtrl.forward().then((_) => _cardCtrl.forward());
  }

  @override
  void dispose() {
    _scoreCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final result = quiz.latestResult;

    if (result == null) {
      return Scaffold(
        body: Center(
            child: ElevatedButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/home'),
                child: const Text('Go Home'))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildScoreCircle(result),
                const SizedBox(height: 28),
                SlideTransition(
                  position: _cardSlide,
                  child: FadeTransition(
                    opacity: _cardFade,
                    child: Column(
                      children: [
                        _buildGradeCard(result),
                        const SizedBox(height: 16),
                        _buildStatsGrid(result),
                        const SizedBox(height: 16),
                        _buildAnswerBreakdown(result),
                        const SizedBox(height: 28),
                        _buildActions(context, quiz),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreCircle(QuizResult result) {
    return AnimatedBuilder(
      animation: _scoreAnim,
      builder: (context, _) {
        final displayed = (result.score * _scoreAnim.value).round();
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: result.accuracy / 100 * _scoreAnim.value,
                    strokeWidth: 10,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation(
                        _getAccuracyColor(result.accuracy)),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$displayed',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -2,
                      ),
                    ),
                    Text('points',
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getResultMessage(result.accuracy),
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${result.category.label} · ${result.difficulty.label}',
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  color: AppColors.textSecondary),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGradeCard(QuizResult result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _getAccuracyColor(result.accuracy).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: _getAccuracyColor(result.accuracy).withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                result.grade,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _getAccuracyColor(result.accuracy),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Grade',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text(
                  '${result.accuracy.toStringAsFixed(1)}% Accuracy',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary),
                ),
                Text(
                  '${result.correctAnswers} of ${result.totalQuestions} correct',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 13,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (result.maxStreak > 1)
            Column(
              children: [
                const Icon(Icons.local_fire_department,
                    color: AppColors.error, size: 24),
                Text(
                  '${result.maxStreak}x',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                      fontSize: 14),
                ),
                Text('streak',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 11,
                        color: AppColors.textMuted)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(QuizResult result) {
    final minutes = result.totalTime.inMinutes;
    final seconds = result.totalTime.inSeconds % 60;
    final timeStr = minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';

    final stats = [
      ('Time', timeStr, Icons.timer_outlined, AppColors.accent),
      ('Score', '${result.score}', Icons.star_outlined, AppColors.gold),
      (
        'Streak',
        '${result.maxStreak}x',
        Icons.local_fire_department,
        AppColors.error
      ),
      (
        'Correct',
        '${result.correctAnswers}/${result.totalQuestions}',
        Icons.check_circle_outline,
        AppColors.success
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: stats.map((s) => _statTile(s.$1, s.$2, s.$3, s.$4)).toList(),
    );
  }

  Widget _statTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      color: AppColors.textMuted)),
              Text(value,
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerBreakdown(QuizResult result) {
    if (result.questions.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Question Breakdown',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 14),
          ...List.generate(result.questions.length, (i) {
            final q = result.questions[i];
            final answer = result.answers.length > i ? result.answers[i] : null;
            final isCorrect = answer == q.correctIndex;
            final isSkipped = answer == null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSkipped
                          ? AppColors.textMuted.withOpacity(0.1)
                          : isCorrect
                              ? AppColors.success.withOpacity(0.15)
                              : AppColors.error.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isSkipped
                          ? Icons.remove
                          : isCorrect
                              ? Icons.check
                              : Icons.close,
                      color: isSkipped
                          ? AppColors.textMuted
                          : isCorrect
                              ? AppColors.success
                              : AppColors.error,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Q${i + 1}. ${q.text}',
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, QuizProvider quiz) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              quiz.resetQuiz();
              Navigator.pushReplacementNamed(context, '/setup');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Play Again',
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  quiz.resetQuiz();
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Home',
                    style: TextStyle(
                        fontFamily: 'Outfit', color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/leaderboard'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.leaderboard_outlined,
                        color: AppColors.gold, size: 18),
                    const SizedBox(width: 6),
                    Text('Rankings',
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return AppColors.success;
    if (accuracy >= 60) return AppColors.gold;
    return AppColors.error;
  }

  String _getResultMessage(double accuracy) {
    if (accuracy >= 90) return '🏆 Outstanding!';
    if (accuracy >= 80) return '🎯 Excellent!';
    if (accuracy >= 70) return '👏 Well Done!';
    if (accuracy >= 60) return '👍 Good Effort!';
    return '📚 Keep Practicing!';
  }
}
