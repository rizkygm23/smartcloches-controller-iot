import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode for mobile
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set system UI overlay style (status bar)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.bgColor,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const SmartClochesApp());
}

class SmartClochesApp extends StatelessWidget {
  const SmartClochesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Cloches',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
