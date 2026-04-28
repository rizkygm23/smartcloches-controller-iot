import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RainStatusCard extends StatelessWidget {
  final bool isRaining;
  final bool isOnline;

  const RainStatusCard({
    super.key,
    required this.isRaining,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isRaining
              ? [
                  AppTheme.rainColor.withValues(alpha: 0.08),
                  AppTheme.rainColor.withValues(alpha: 0.03),
                ]
              : [
                  AppTheme.success.withValues(alpha: 0.06),
                  AppTheme.success.withValues(alpha: 0.02),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isRaining
              ? AppTheme.rainColor.withValues(alpha: 0.2)
              : AppTheme.success.withValues(alpha: 0.15),
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          // Rain icon with animation
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isRaining
                  ? AppTheme.rainColor.withValues(alpha: 0.12)
                  : AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  isRaining ? Icons.thunderstorm_rounded : Icons.wb_sunny_rounded,
                  color: isRaining ? AppTheme.rainColor : AppTheme.success,
                  size: 28,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STATUS CUACA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textTertiary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isRaining ? 'Hujan Terdeteksi' : 'Cuaca Cerah',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isRaining ? AppTheme.rainColor : AppTheme.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isRaining
                      ? 'Jemuran akan otomatis ditutup'
                      : 'Aman untuk menjemur',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textTertiary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isRaining
                  ? AppTheme.rainColor.withValues(alpha: 0.12)
                  : AppTheme.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRaining ? AppTheme.rainColor : AppTheme.success,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isRaining ? 'WET' : 'DRY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isRaining ? AppTheme.rainColor : AppTheme.success,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
