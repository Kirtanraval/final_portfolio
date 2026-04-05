// lib/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/quiz_models.dart';
import '../providers/quiz_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final history = quiz.history;
    final profile = quiz.userProfile;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(title: const Text('Analytics')),
      body: history.isEmpty
          ? _buildEmpty(context)
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverview(profile, history),
                  const SizedBox(height: 24),
                  _buildPerformanceTrend(context, history),
                  const SizedBox(height: 24),
                  _buildCategoryBreakdown(context, history),
                  const SizedBox(height: 24),
                  _buildDifficultyStats(context, history),
                  const SizedBox(height: 24),
                  _buildPersonalBests(history),
                ],
              ),
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('No data yet', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Play some quizzes to see your analytics',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/setup'),
            child: const Text('Start Playing'),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(profile, List<QuizResult> history) {
    final avgAccuracy = history.isEmpty
        ? 0.0
        : history.fold(0.0, (s, r) => s + r.accuracy) / history.length;
    final totalScore = history.fold(0, (s, r) => s + r.score);
    final bestScore = history.isEmpty
        ? 0
        : history.map((r) => r.score).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview',
            style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
                child: _bigStat('Total Score', '$totalScore',
                    Icons.star_rounded, AppColors.gold)),
            const SizedBox(width: 12),
            Expanded(
                child: _bigStat(
                    'Avg Accuracy',
                    '${avgAccuracy.toStringAsFixed(1)}%',
                    Icons.track_changes_outlined,
                    AppColors.accent)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: _bigStat('Games Played', '${history.length}',
                    Icons.gamepad_outlined, AppColors.success)),
            const SizedBox(width: 12),
            Expanded(
                child: _bigStat('Best Score', '$bestScore',
                    Icons.emoji_events_outlined, AppColors.error)),
          ],
        ),
      ],
    );
  }

  Widget _bigStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildPerformanceTrend(
      BuildContext context, List<QuizResult> history) {
    final recent = history.take(7).toList().reversed.toList();
    if (recent.isEmpty) return const SizedBox();

    final maxScore =
        recent.map((r) => r.score).reduce((a, b) => a > b ? a : b).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Performance',
            style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: recent.map((r) {
                    final h = maxScore > 0 ? (r.score / maxScore) * 100 : 10.0;
                    final color =
                        r.accuracy >= 70 ? AppColors.success : AppColors.error;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text('${r.score}',
                                style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 10,
                                    color: AppColors.textMuted)),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              height: h.clamp(10, 100).toDouble(),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: recent
                    .map((r) => Text(
                          r.category.label.substring(0, 3),
                          style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 10,
                              color: AppColors.textMuted),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(
      BuildContext context, List<QuizResult> history) {
    final categoryMap = <QuizCategory, List<double>>{};
    for (final r in history) {
      categoryMap.putIfAbsent(r.category, () => []).add(r.accuracy);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category Performance',
            style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: categoryMap.entries.map((e) {
              final avg = e.value.fold(0.0, (s, v) => s + v) / e.value.length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(e.key.icon, color: e.key.color, size: 16),
                        const SizedBox(width: 8),
                        Text(e.key.label,
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                color: AppColors.textSecondary)),
                        const Spacer(),
                        Text('${avg.toStringAsFixed(0)}%',
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontSize: 13)),
                        Text(' · ${e.value.length} games',
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 11,
                                color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: avg / 100,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(e.key.color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyStats(BuildContext context, List<QuizResult> history) {
    final diffMap = <Difficulty, List<QuizResult>>{};
    for (final r in history) {
      diffMap.putIfAbsent(r.difficulty, () => []).add(r);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Difficulty Breakdown',
            style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        Row(
          children: Difficulty.values.map((d) {
            final games = diffMap[d] ?? [];
            final avg = games.isEmpty
                ? 0.0
                : games.fold(0.0, (s, r) => s + r.accuracy) / games.length;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: d != Difficulty.expert ? 10 : 0),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: d.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: d.color.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Text(d.label,
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 11,
                            color: d.color,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('${games.length}',
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: d.color)),
                    Text('games',
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10,
                            color: AppColors.textMuted)),
                    const SizedBox(height: 4),
                    Text('${avg.toStringAsFixed(0)}%',
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPersonalBests(List<QuizResult> history) {
    if (history.isEmpty) return const SizedBox();
    final best = history.reduce((a, b) => a.score > b.score ? a : b);
    final bestAccuracy =
        history.reduce((a, b) => a.accuracy > b.accuracy ? a : b);
    final bestStreak =
        history.reduce((a, b) => a.maxStreak > b.maxStreak ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Personal Bests',
            style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _bestRow(
                  '🏆 Highest Score', '${best.score} pts', best.category.label),
              const Divider(color: AppColors.border, height: 24),
              _bestRow(
                  '🎯 Best Accuracy',
                  '${bestAccuracy.accuracy.toStringAsFixed(1)}%',
                  bestAccuracy.category.label),
              const Divider(color: AppColors.border, height: 24),
              _bestRow('🔥 Longest Streak', '${bestStreak.maxStreak}x',
                  bestStreak.difficulty.label),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _bestRow(String label, String value, String sub) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 14,
                color: AppColors.textSecondary)),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value,
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 15)),
            Text(sub,
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 11,
                    color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }
}
