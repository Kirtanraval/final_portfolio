// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/quiz_models.dart';
import '../providers/quiz_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  int _selectedNav = 0;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _headerFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _headerCtrl.forward();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final profile = quiz.userProfile;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top Bar ─────────────────────────────────────────────────
            SlideTransition(
              position: _headerSlide,
              child: FadeTransition(
                opacity: _headerFade,
                child: _buildTopBar(context, profile),
              ),
            ),
            // ─── Content ─────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildHeroBanner(context),
                    const SizedBox(height: 28),
                    _buildQuickStats(profile),
                    const SizedBox(height: 28),
                    _buildSectionHeader('Quick Play', 'Choose a category'),
                    const SizedBox(height: 16),
                    _buildCategoryGrid(context),
                    const SizedBox(height: 28),
                    _buildSectionHeader('Recent Activity', ''),
                    const SizedBox(height: 12),
                    _buildRecentActivity(quiz.history),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar(BuildContext context, UserProfile? profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back,',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text(
                profile?.name ?? 'Player',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const Spacer(),
          // Streak badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: AppColors.gold, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${profile?.currentStreak ?? 0} streak',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/analytics'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.bar_chart_outlined,
                  color: AppColors.textSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/setup'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.accent, AppColors.accentGlow.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('🤖 AI-Powered',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Start a New\nQuiz Challenge',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'AI generates unique questions\nfor every game session',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Play Now',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded,
                          color: AppColors.accent, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(UserProfile? p) {
    return Row(
      children: [
        Expanded(
            child: StatCard(
                label: 'Total Score',
                value: '${p?.totalScore ?? 0}',
                icon: Icons.star_rounded,
                color: AppColors.gold)),
        const SizedBox(width: 12),
        Expanded(
            child: StatCard(
                label: 'Games',
                value: '${p?.gamesPlayed ?? 0}',
                icon: Icons.gamepad_outlined,
                color: AppColors.accent)),
        const SizedBox(width: 12),
        Expanded(
            child: StatCard(
                label: 'Win Rate',
                value: '${p?.winRate.toStringAsFixed(0) ?? 0}%',
                icon: Icons.emoji_events_outlined,
                color: AppColors.success)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            if (subtitle.isNotEmpty)
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final categories =
        QuizCategory.values.where((c) => c != QuizCategory.custom).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final cat = categories[i];
        return CategoryCard(
          category: cat,
          onTap: () {
            Navigator.pushNamed(context, '/setup', arguments: cat);
          },
        );
      },
    );
  }

  Widget _buildRecentActivity(List<QuizResult> history) {
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.history_outlined,
                  color: AppColors.textMuted, size: 40),
              const SizedBox(height: 8),
              Text('No games yet',
                  style: TextStyle(color: AppColors.textMuted)),
              Text('Play your first quiz!',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: history.take(3).map((r) => _buildActivityItem(r)).toList(),
    );
  }

  Widget _buildActivityItem(QuizResult r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: r.category.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(r.category.icon, color: r.category.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.category.label,
                    style: Theme.of(context).textTheme.labelLarge),
                Text(
                  '${r.correctAnswers}/${r.totalQuestions} correct · ${r.difficulty.label}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${r.score}',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  fontSize: 16,
                ),
              ),
              Text(
                r.grade,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  color: r.accuracy >= 70 ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.leaderboard_outlined, Icons.leaderboard_rounded, 'Ranking'),
      (Icons.people_outline, Icons.people_rounded, 'Multiplayer'),
      (Icons.edit_outlined, Icons.edit_rounded, 'Custom'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isSelected = _selectedNav == i;
              final item = items[i];
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedNav = i);
                  final routes = [
                    '/home',
                    '/leaderboard',
                    '/multiplayer',
                    '/custom-quiz'
                  ];
                  if (i != 0) Navigator.pushNamed(context, routes[i]);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.$2 : item.$1,
                        color:
                            isSelected ? AppColors.accent : AppColors.textMuted,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$3,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
