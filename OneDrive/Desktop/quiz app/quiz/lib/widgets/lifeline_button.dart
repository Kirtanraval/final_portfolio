import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LifelineButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isAvailable;
  final VoidCallback onTap;

  const LifelineButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isAvailable ? 1.0 : 0.35,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isAvailable
                ? AppColors.accent.withOpacity(0.12)
                : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAvailable
                  ? AppColors.accent.withOpacity(0.35)
                  : AppColors.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color:
                    isAvailable ? AppColors.accentLight : AppColors.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      isAvailable ? AppColors.accentLight : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
