import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SpeedControl extends StatelessWidget {
  final double speed;
  final bool isLoading;
  final ValueChanged<double> onChanged;

  const SpeedControl({
    super.key,
    required this.speed,
    required this.isLoading,
    required this.onChanged,
  });

  String _getSpeedLabel(double val) {
    if (val <= 20) return 'Sangat Lambat 🐢';
    if (val <= 40) return 'Lambat 🚶';
    if (val <= 60) return 'Normal 👍';
    if (val <= 80) return 'Cepat ⚡';
    return 'Sangat Cepat 🔥';
  }

  int _getStep(double val) {
    return ((val / 100) * 9 + 1).round().clamp(1, 10);
  }

  @override
  Widget build(BuildContext context) {
    final step = _getStep(speed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KECEPATAN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textTertiary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getSpeedLabel(speed),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppTheme.accentPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.accentPrimary.withValues(alpha: 0.15),
                ),
              ),
              child: Text(
                'Step $step',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentPrimary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Slider
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppTheme.accentPrimary,
            inactiveTrackColor: AppTheme.divider,
            thumbColor: Colors.white,
            overlayColor: AppTheme.accentPrimary.withValues(alpha: 0.12),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 3,
              pressedElevation: 6,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
          ),
          child: Slider(
            value: speed,
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: isLoading ? null : onChanged,
          ),
        ),

        // Step indicators
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(10, (index) {
              final isActive = (index + 1) <= step;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 3,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.accentPrimary
                      : AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 8),

        // Min/Max labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lambat',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textTertiary.withValues(alpha: 0.7),
                ),
              ),
              Text(
                'Cepat',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textTertiary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
