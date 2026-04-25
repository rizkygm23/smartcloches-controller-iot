import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/blynk_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/servo_toggle.dart';
import '../widgets/speed_control.dart';
import 'bluetooth_setup_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _servoOn = false;
  double _speed = 50;
  bool _isLoading = false;
  bool _isOnline = false;
  String _lastAction = 'Menunggu...';
  Timer? _pollTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _fetchStatus();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchStatus(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    final position = await BlynkService.getServoStatus();
    final speed = await BlynkService.getServoSpeed();
    if (!mounted) return;
    setState(() {
      if (position != null) {
        _servoOn = position == 1;
        _isOnline = true;
      } else {
        _isOnline = false;
      }
      if (speed != null) {
        _speed = speed.toDouble().clamp(0, 100);
      }
    });
  }

  Future<void> _toggleServo(bool value) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
      _lastAction = value ? 'Menyalakan servo...' : 'Mematikan servo...';
    });

    final success = await BlynkService.setServoPosition(value ? 1 : 0);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (success) {
        _servoOn = value;
        _lastAction = value ? '✅ Servo ON (90°)' : '🔴 Servo OFF (0°)';
      } else {
        _lastAction = '❌ Gagal mengirim perintah';
      }
    });
  }

  Future<void> _changeSpeed(double value) async {
    HapticFeedback.selectionClick();
    setState(() {
      _speed = value;
    });

    final success = await BlynkService.setServoSpeed(value.round());

    if (!mounted) return;
    setState(() {
      if (success) {
        _lastAction = '✅ Speed: ${value.round()} (Step ${((value / 100) * 9 + 1).round()})';
      } else {
        _lastAction = '❌ Gagal mengatur speed';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Logo
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.accentPrimary,
                                  AppTheme.accentSecondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.memory_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SMART CLOCHES',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                'IoT Controller',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Status badge and BT setup
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _isOnline
                                  ? AppTheme.accentPrimary.withValues(alpha: 0.12)
                                  : AppTheme.danger.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isOnline
                                    ? AppTheme.accentPrimary.withValues(alpha: 0.3)
                                    : AppTheme.danger.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isOnline
                                        ? AppTheme.accentPrimary
                                        : AppTheme.danger,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _isOnline
                                            ? AppTheme.accentPrimary
                                            : AppTheme.danger,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isOnline ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _isOnline
                                        ? AppTheme.accentPrimary
                                        : AppTheme.danger,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.bluetooth_searching, size: 20, color: Colors.white70),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BluetoothSetupScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Servo Control
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                  child: GlassCard(
                    child: ServoToggle(
                      isOn: _servoOn,
                      isLoading: _isLoading,
                      onChanged: _toggleServo,
                    ),
                  ),
                ),
              ),

              // Speed Control
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: GlassCard(
                    child: SpeedControl(
                      speed: _speed,
                      isLoading: _isLoading,
                      onChanged: _changeSpeed,
                    ),
                  ),
                ),
              ),

              // Activity Log
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.terminal_rounded,
                            color: _isOnline
                                ? AppTheme.accentPrimary
                                : AppTheme.danger,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'AKTIVITAS TERAKHIR',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _lastAction,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'monospace',
                                  color: _isOnline
                                      ? AppTheme.accentPrimary
                                      : AppTheme.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      '© 2026 Smart Cloches • Blynk Cloud',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
