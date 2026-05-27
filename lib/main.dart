// KEY CONCEPTS IN THIS FILE:
// • ProviderScope: A widget that stores the state of all providers in the app.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/colors.dart';
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Day 1: We wrap this in a try/catch so the app runs 
  // even if students haven't set up Firebase yet.
  try {
    // await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase not initialized: $e');
  }

  runApp(
    const ProviderScope(
      child: QuestArenaApp(),
    ),
  );
}

class QuestArenaApp extends StatelessWidget {
  const QuestArenaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuestArena',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.primaryBg,
        // Using our primary purple as the seed for the theme
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.purple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // We start with the SplashScreen
      home: const SplashScreen(),
    );
  }
}
