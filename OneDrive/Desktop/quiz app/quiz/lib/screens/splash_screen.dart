// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _bgCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _bgOpacity;

  @override
  void initState() {
    super.initState();

    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    _bgOpacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeIn));

    _logoScale = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.5)));

    _textOpacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _runAnimation();
  }

  Future<void> _runAnimation() async {
    await _bgCtrl.forward();
    await _logoCtrl.forward();
    await _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_bgCtrl, _logoCtrl, _textCtrl]),
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryDark,
                  AppColors.primary,
                  AppColors.primaryLight
                ],
                stops: const [0, 0.5, 1],
              ),
            ),
            child: Opacity(
              opacity: _bgOpacity.value,
              child: Stack(
                children: [
                  // Grid pattern background
                  CustomPaint(
                    painter: _GridPainter(),
                    size: MediaQuery.of(context).size,
                  ),
                  // Glow circles
                  Positioned(
                    top: -100,
                    right: -100,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -80,
                    left: -80,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withOpacity(0.06),
                      ),
                    ),
                  ),
                  // Center content
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.accent,
                                    AppColors.accentGlow
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.4),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.psychology_outlined,
                                color: Colors.white,
                                size: 52,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        // App name
                        SlideTransition(
                          position: _textSlide,
                          child: Opacity(
                            opacity: _textOpacity.value,
                            child: Column(
                              children: [
                                Text(
                                  'QuizMaster',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 38,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -1,
                                  ),
                                ),
                                Text(
                                  'PRO',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                    letterSpacing: 6,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Challenge. Learn. Compete.',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom loading bar
                  Positioned(
                    bottom: 60,
                    left: 80,
                    right: 80,
                    child: Opacity(
                      opacity: _textOpacity.value,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation(AppColors.accent),
                          minHeight: 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withOpacity(0.04)
      ..strokeWidth = 1;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
