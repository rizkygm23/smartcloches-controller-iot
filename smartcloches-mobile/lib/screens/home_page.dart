import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/blynk_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/sensor_card.dart';
import '../widgets/servo_toggle.dart';
import '../widgets/speed_control.dart';
import '../widgets/sensor_history_chart.dart';
import 'bluetooth_setup_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _servoOn = false;
  double _speed = 50;
  double _temp = 0;
  double _hum = 0;
  bool _isRaining = false;
  bool _isOnline = false;
  bool _isLoading = false;
  
  final List<Map<String, dynamic>> _notifications = [];
  double? _prevTemp;
  bool _prevRain = false;
  int _unreadCount = 0;

  final List<Map<String, dynamic>> _tempHistory = [];
  final List<Map<String, dynamic>> _humHistory = [];
  
  Timer? _pollTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutQuart,
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

  void _addNotification(String title, String message, IconData icon, Color color) {
    final now = DateTime.now();
    setState(() {
      _notifications.insert(0, {
        'title': title,
        'message': message,
        'time': '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
        'icon': icon,
        'color': color,
        'isNew': true,
      });
      _unreadCount++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  Text(message, style: const TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color.withValues(alpha: 0.9),
        duration: const Duration(seconds: 4),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      ),
    );
  }

  Future<void> _fetchStatus() async {
    final position = await BlynkService.getServoStatus();
    final speed = await BlynkService.getServoSpeed();
    final temp = await BlynkService.getTemperature();
    final hum = await BlynkService.getHumidity();
    final rain = await BlynkService.getRainStatus();

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
      
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (temp != null) {
        if (_prevTemp != null && (_prevTemp! - temp) >= 1.5) {
          _addNotification(
            'Mendung Terdeteksi',
            'Suhu turun drastis (${temp.toStringAsFixed(1)}°C). Sistem bersiap.',
            Icons.cloud_queue_rounded,
            AppTheme.accentSecondary,
          );
        }
        _temp = temp;
        _prevTemp = temp;
        _tempHistory.add({'timestamp': now, 'value': _temp});
        if (_tempHistory.length > 60) _tempHistory.removeAt(0);
      }
      
      if (hum != null) {
        _hum = hum;
        _humHistory.add({'timestamp': now, 'value': _hum});
        if (_humHistory.length > 60) _humHistory.removeAt(0);
      }

      if (rain != null) {
        bool currentRain = rain == 1;
        if (currentRain && !_prevRain) {
          _addNotification(
            'Hujan Terdeteksi!',
            'Sensor mendeteksi air. Atap otomatis ditutup.',
            Icons.umbrella_rounded,
            AppTheme.danger,
          );
        }
        _isRaining = currentRain;
        _prevRain = currentRain;
      }
    });
  }

  void _showNotifications() {
    setState(() {
      _unreadCount = 0;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppTheme.bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Riwayat Notifikasi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none_rounded, size: 64, color: AppTheme.textTertiary.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          const Text('Belum ada notifikasi baru', style: TextStyle(color: AppTheme.textTertiary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final n = _notifications[index];
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: AppTheme.divider.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (n['color'] as Color).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(n['icon'] as IconData, color: n['color'] as Color, size: 24),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(n['title'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.textPrimary)),
                                        Text(n['time'], style: const TextStyle(fontSize: 12, color: AppTheme.textTertiary, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(n['message'], style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleServo(bool value) async {
    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);
    final success = await BlynkService.setServoPosition(value ? 1 : 0);
    if (success) setState(() => _servoOn = value);
    setState(() => _isLoading = false);
  }

  Future<void> _changeSpeed(double value) async {
    HapticFeedback.selectionClick();
    setState(() => _isLoading = true);
    final success = await BlynkService.setServoSpeed(value.round());
    if (success) setState(() => _speed = value);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Premium App Bar
            SliverAppBar(
              expandedHeight: 140,
              collapsedHeight: 80,
              pinned: true,
              floating: false,
              elevation: 0,
              backgroundColor: AppTheme.bgColor,
              surfaceTintColor: AppTheme.bgColor,
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1.2,
                titlePadding: const EdgeInsets.only(left: 24, bottom: 16, right: 24),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SmartCloches',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            letterSpacing: -1,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isOnline ? AppTheme.success : AppTheme.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isOnline ? 'Online' : 'Offline',
                              style: const TextStyle(
                                color: AppTheme.textTertiary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: AppTheme.textPrimary, size: 28),
                      onPressed: _showNotifications,
                    ),
                    if (_unreadCount > 0)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle),
                          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                          child: Text(
                            '$_unreadCount',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.bluetooth_searching_rounded, color: AppTheme.textPrimary, size: 28),
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const BluetoothSetupScreen())
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),

            // Main Content with separate SliverPaddings
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            
            // Sensor Cards Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.15,
                children: [
                  SensorCard(
                    title: 'SUHU',
                    value: _temp.toStringAsFixed(1),
                    unit: '°C',
                    icon: Icons.thermostat_rounded,
                    color: AppTheme.tempColor,
                  ),
                  SensorCard(
                    title: 'KELEMBABAN',
                    value: _hum.toStringAsFixed(0),
                    unit: '%',
                    icon: Icons.water_drop_rounded,
                    color: AppTheme.humColor,
                  ),
                ],
              ),
            ),

            // Rain Alert Card
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              sliver: SliverToBoxAdapter(
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: (_isRaining ? AppTheme.danger : AppTheme.success).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _isRaining ? Icons.umbrella_rounded : Icons.wb_sunny_rounded,
                          color: _isRaining ? AppTheme.danger : AppTheme.success,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isRaining ? 'Sedang Hujan' : 'Cuaca Cerah',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _isRaining ? 'Atap tertutup otomatis' : 'Kondisi ideal untuk jemuran',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isRaining)
                        const Icon(Icons.warning_amber_rounded, color: AppTheme.danger, size: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Control Section Header
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'KONTROL PERANGKAT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textTertiary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            // Servo & Speed Controls
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      ServoToggle(
                        isOn: _servoOn,
                        isLoading: _isLoading,
                        onChanged: _toggleServo,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(color: AppTheme.divider, height: 1),
                      ),
                      SpeedControl(
                        speed: _speed,
                        isLoading: _isLoading,
                        onChanged: _changeSpeed,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Live Stats Header
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'STATISTIK REAL-TIME',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textTertiary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            // Live Chart
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverToBoxAdapter(
                child: SensorHistoryChart(
                  title: 'Live Monitor',
                  tempHistory: _tempHistory,
                  humHistory: _humHistory,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }
}
