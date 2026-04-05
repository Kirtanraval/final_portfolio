// lib/screens/multiplayer_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/quiz_models.dart';

class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});
  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  final List<MultiplayerRoom> _rooms = [
    MultiplayerRoom(
        id: '1',
        hostId: 'u1',
        hostName: 'Alex Chen',
        players: [
          MultiplayerPlayer(
              userId: 'u1', name: 'Alex Chen', isHost: true, isReady: true),
          MultiplayerPlayer(userId: 'u2', name: 'Sarah K', isReady: true),
        ],
        category: QuizCategory.science,
        difficulty: Difficulty.medium),
    MultiplayerRoom(
        id: '2',
        hostId: 'u3',
        hostName: 'Marcus W',
        players: [
          MultiplayerPlayer(
              userId: 'u3', name: 'Marcus W', isHost: true, isReady: true),
        ],
        category: QuizCategory.history,
        difficulty: Difficulty.hard),
    MultiplayerRoom(
        id: '3',
        hostId: 'u4',
        hostName: 'Priya P',
        players: [
          MultiplayerPlayer(
              userId: 'u4', name: 'Priya P', isHost: true, isReady: true),
          MultiplayerPlayer(userId: 'u5', name: 'Jordan L', isReady: false),
          MultiplayerPlayer(userId: 'u6', name: 'Emma D', isReady: true),
        ],
        category: QuizCategory.technology,
        difficulty: Difficulty.easy),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('Multiplayer'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _showCreateRoom(context)),
        ],
      ),
      body: Column(
        children: [
          // Online count banner
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.accent.withOpacity(0.2),
                AppColors.accentGlow.withOpacity(0.1)
              ]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.success)),
                const SizedBox(width: 10),
                Text('247 players online',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                const Spacer(),
                Text('Find Match',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: AppColors.accent),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Open Rooms',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const Spacer(),
                Text('${_rooms.length} available',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _rooms.length,
              itemBuilder: (_, i) => _buildRoomCard(_rooms[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(MultiplayerRoom room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: room.category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(room.category.icon,
                    color: room.category.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(room.category.label,
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            fontSize: 15)),
                    Text('Host: ${room.hostName}',
                        style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: room.difficulty.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(room.difficulty.label,
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: room.difficulty.color)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ...room.players.map((p) => Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color:
                              p.isReady ? AppColors.success : AppColors.border,
                          width: 2),
                    ),
                    child: Center(
                        child: Text(p.name[0],
                            style: TextStyle(
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w700,
                                color: AppColors.accent,
                                fontSize: 13))),
                  )),
              ...List.generate(
                  room.maxPlayers - room.players.length,
                  (_) => Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: AppColors.border.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Icon(Icons.add,
                            size: 14, color: AppColors.textMuted),
                      )),
              const Spacer(),
              Text('${room.players.length}/${room.maxPlayers}',
                  style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      color: AppColors.textMuted)),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: room.isFull ? null : () => _joinRoom(room),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      room.isFull ? AppColors.border : AppColors.accent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(room.isFull ? 'Full' : 'Join',
                    style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _joinRoom(MultiplayerRoom room) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joining ${room.category.label} room...',
            style: TextStyle(fontFamily: 'Outfit')),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showCreateRoom(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Room',
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            Text(
                'This feature connects to Firebase Firestore for real-time multiplayer. Configure your Firebase project and update the MultiplayerService to enable live games.',
                style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
