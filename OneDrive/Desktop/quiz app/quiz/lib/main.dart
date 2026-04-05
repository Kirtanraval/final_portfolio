// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/quiz_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_setup_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/result_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/multiplayer_screen.dart';
import 'screens/custom_quiz_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.primary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
      ],
      child: MaterialApp(
        title: 'QuizMaster Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/home': (_) => const HomeScreen(),
          '/setup': (_) => const QuizSetupScreen(),
          '/quiz': (_) => const QuizScreen(),
          '/result': (_) => const ResultScreen(),
          '/leaderboard': (_) => const LeaderboardScreen(),
          '/analytics': (_) => const AnalyticsScreen(),
          '/multiplayer': (_) => const MultiplayerScreen(),
          '/custom-quiz': (_) => const CustomQuizScreen(),
        },
      ),
    );
  }
}
