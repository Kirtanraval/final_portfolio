// lib/providers/leaderboard_provider.dart
import 'package:flutter/foundation.dart';
import '../models/quiz_models.dart';

class LeaderboardProvider extends ChangeNotifier {
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = false;
  String _filter = 'all_time'; // 'all_time', 'weekly', 'daily'

  List<LeaderboardEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String get filter => _filter;

  LeaderboardProvider() {
    _loadMockLeaderboard();
  }

  void setFilter(String f) {
    _filter = f;
    _loadMockLeaderboard();
    notifyListeners();
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    _loadMockLeaderboard();
    _isLoading = false;
    notifyListeners();
  }

  void _loadMockLeaderboard() {
    // Simulated leaderboard data (replace with Firestore in production)
    _entries = [
      LeaderboardEntry(
          userId: '1',
          userName: 'Alex Chen',
          score: 12450,
          rank: 1,
          gamesPlayed: 87,
          accuracy: 94.2,
          updatedAt: DateTime.now()),
      LeaderboardEntry(
          userId: '2',
          userName: 'Sarah Kim',
          score: 11800,
          rank: 2,
          gamesPlayed: 72,
          accuracy: 91.5,
          updatedAt: DateTime.now()),
      LeaderboardEntry(
          userId: '3',
          userName: 'Marcus Williams',
          score: 11200,
          rank: 3,
          gamesPlayed: 95,
          accuracy: 88.3,
          updatedAt: DateTime.now()),
      LeaderboardEntry(
          userId: '4',
          userName: 'Priya Patel',
          score: 10500,
          rank: 4,
          gamesPlayed: 63,
          accuracy: 90.1,
          updatedAt: DateTime.now()),
      LeaderboardEntry(
          userId: '5',
          userName: 'Jordan Lee',
          score: 9800,
          rank: 5,
          gamesPlayed: 54,
          accuracy: 86.7,
          updatedAt: DateTime.now()),
      LeaderboardEntry(
          userId: '6',
          userName: 'Emma Davis',
          score: 9200,
          rank: 6,
          gamesPlayed: 48,
          accuracy: 85.0,
          updatedAt: DateTime.now()),
      LeaderboardEntry(
          userId: '7',
          userName: 'Raj Sharma',
          score: 8700,
          rank: 7,
          gamesPlayed: 61,
          accuracy: 83.2,
          updatedAt: DateTime.now()),
      LeaderboardEntry(
          userId: '8',
          userName: 'Aisha Johnson',
          score: 8100,
          rank: 8,
          gamesPlayed: 42,
          accuracy: 87.5,
          updatedAt: DateTime.now()),
      LeaderboardEntry(
          userId: '9',
          userName: 'Tyler Brooks',
          score: 7600,
          rank: 9,
          gamesPlayed: 38,
          accuracy: 81.9,
          updatedAt: DateTime.now()),
      LeaderboardEntry(
          userId: '10',
          userName: 'You',
          score: 3200,
          rank: 10,
          gamesPlayed: 12,
          accuracy: 78.3,
          updatedAt: DateTime.now()),
    ];

    if (_filter == 'weekly') {
      _entries = _entries
          .map((e) => LeaderboardEntry(
                userId: e.userId,
                userName: e.userName,
                score: (e.score * 0.3).round(),
                rank: e.rank,
                gamesPlayed: (e.gamesPlayed * 0.2).round(),
                accuracy: e.accuracy,
                updatedAt: e.updatedAt,
              ))
          .toList();
    } else if (_filter == 'daily') {
      _entries = _entries
          .map((e) => LeaderboardEntry(
                userId: e.userId,
                userName: e.userName,
                score: (e.score * 0.05).round(),
                rank: e.rank,
                gamesPlayed: (e.gamesPlayed * 0.04).round(),
                accuracy: e.accuracy,
                updatedAt: e.updatedAt,
              ))
          .toList();
    }
  }
}
