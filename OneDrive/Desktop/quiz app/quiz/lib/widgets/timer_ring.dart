// lib/widgets/timer_ring.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TimerRing extends StatelessWidget {
  final double progress;
  final int seconds;

  const TimerRing({super.key, required this.progress, required this.seconds});

  Color get _color {
    if (progress > 0.5) return AppColors.success;
    if (progress > 0.25) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3.5,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation(_color),
            strokeCap: StrokeCap.round,
          ),
          Text(
            '$seconds',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}

// lib/widgets/stat_card.dart
// (inline in the same file for convenience)

// lib/widgets/category_card.dart
// lib/widgets/lifeline_button.dart
