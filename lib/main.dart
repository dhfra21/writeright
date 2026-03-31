import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/gamification/gamification_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()..init()),
        ChangeNotifierProvider(create: (_) => GamificationService()..loadProgress()),
      ],
      child: MaterialApp(
        title: 'WriteRight',
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
