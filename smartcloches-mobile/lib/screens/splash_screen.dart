import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import 'home_page.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<double> _progressFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
      ),
    );

    _progressFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.75, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    // Check saved username while splash plays
    final username = await SupabaseService.getSavedUsername();

    // Wait for splash animation to finish
    await Future.delayed(const Duration(milliseconds: 3200));

    if (!mounted) return;

    final Widget destination =
        (username != null && username.isNotEmpty)
            ? const HomePage()
            : const LoginScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Logo
                Opacity(
                  opacity: _logoFade.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentPrimary.withValues(alpha: 0.15),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // App name
                Opacity(
                  opacity: _textFade.value,
                  child: const Column(
                    children: [
                      Text(
                        'Smart Clothesline',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Jemuran Otomatis IoT',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // Loading indicator
                Opacity(
                  opacity: _progressFade.value,
                  child: SizedBox(
                    width: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        minHeight: 3,
                        backgroundColor: AppTheme.divider,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.accentPrimary,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Footer
                Opacity(
                  opacity: _textFade.value,
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
