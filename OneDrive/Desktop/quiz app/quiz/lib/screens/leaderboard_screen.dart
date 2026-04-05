// lib/screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/leaderboard_provider.dart';
import '../models/quiz_models.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lb = context.watch<LeaderboardProvider>();

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: lb.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: ['all_time', 'weekly', 'daily'].map((f) {
                final labels = {
                  'all_time': 'All Time',
                  'weekly': 'This Week',
                  'daily': 'Today'
                };
                final isSelected = lb.filter == f;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => lb.setFilter(f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8, bottom: 16),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.border),
                      ),
                      child: Text(
                        labels[f]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Top 3 podium
          if (lb.entries.length >= 3) _buildPodium(lb.entries),
          // Full list
          Expanded(
            child: lb.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: lb.entries.length,
                    itemBuilder: (_, i) => _buildEntry(context, lb.entries[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> entries) {
    final colors = [AppColors.gold, AppColors.textSecondary, Color(0xFFCD7F32)];
    final ranks = [1, 0, 2]; // Silver, Gold, Bronze position order

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surfaceCard, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ranks.map((r) {
            final e = entries[r];
            final heights = [80.0, 100.0, 60.0];
            final h = heights[ranks.indexOf(r)];
            return Column(
              children: [
                CircleAvatar(
                  radius: r == 0 ? 28 : 22,
                  backgroundColor: colors[r].withOpacity(0.2),
                  child: Text(e.userName[0],
                      style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w700,
                          color: colors[r],
                          fontSize: r == 0 ? 20 : 16)),
                ),
                const SizedBox(height: 6),
                Text(e.userName.split(' ').first,
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        color: AppColors.textSecondary)),
                Text('${e.score}',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w700,
                        color: colors[r],
                        fontSize: 14)),
                const SizedBox(height: 4),
                Container(
                  width: 60,
                  height: h,
                  decoration: BoxDecoration(
                    color: colors[r].withOpacity(0.15),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                    border: Border.all(color: colors[r].withOpacity(0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '#${r + 1}',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w800,
                        color: colors[r],
                        fontSize: 18),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEntry(BuildContext context, LeaderboardEntry e) {
    final isCurrentUser = e.userName == 'You';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.accent.withOpacity(0.1)
            : AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isCurrentUser
                ? AppColors.accent.withOpacity(0.3)
                : AppColors.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${e.rank}',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w700,
                color: e.rank <= 3 ? AppColors.gold : AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.accent.withOpacity(0.15),
            child: Text(e.userName[0],
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.userName,
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 15)),
                Text(
                    '${e.gamesPlayed} games · ${e.accuracy.toStringAsFixed(1)}% accuracy',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        color: AppColors.textMuted)),
              ],
            ),
          ),
          Text(
            '${e.score}',
            style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
                fontSize: 16),
          ),
        ],
      ),
    );
  }
}
