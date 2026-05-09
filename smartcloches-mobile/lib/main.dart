import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://eldrxpulpluelgapyfjs.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVsZHJ4cHVscGx1ZWxnYXB5ZmpzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2NjA4MTYsImV4cCI6MjA4MDIzNjgxNn0.XkzWa3q_OC_KOYxWoo2plTznIZ4EbjtSY2lna6ZETgs',
  );

  // Lock to portrait mode for mobile
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set system UI overlay style (status bar)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppTheme.bgColor,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(const SmartClotheslineApp());
}

class SmartClotheslineApp extends StatelessWidget {
  const SmartClotheslineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Clothesline',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
