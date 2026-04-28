import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ServoToggle extends StatelessWidget {
  final bool isOn;
  final bool isLoading;
  final ValueChanged<bool> onChanged;

  const ServoToggle({
    super.key,
    required this.isOn,
    required this.isLoading,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Servo visual indicator
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isOn
                        ? AppTheme.accentPrimary.withValues(alpha: 0.2)
                        : AppTheme.divider,
                    width: 2,
                  ),
                  boxShadow: [
                    if (isOn)
                      BoxShadow(
                        color: AppTheme.accentPrimary.withValues(alpha: 0.08),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                  ],
                ),
              ),
              // Inner circle with degree text
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isOn
                        ? [AppTheme.accentPrimary, const Color(0xFF1D4ED8)]
                        : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isOn
                          ? AppTheme.accentPrimary.withValues(alpha: 0.3)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          isOn ? '90°' : '0°',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
              // Servo arm indicator
              AnimatedRotation(
                turns: isOn ? 0.25 : 0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: isOn ? AppTheme.accentPrimary : AppTheme.textTertiary,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        if (isOn)
                          BoxShadow(
                            color: AppTheme.accentPrimary.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Toggle switch
        GestureDetector(
          onTap: isLoading ? null : () => onChanged(!isOn),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: 88,
            height: 46,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: isOn
                  ? AppTheme.accentPrimary
                  : const Color(0xFFE2E8F0),
              boxShadow: [
                BoxShadow(
                  color: isOn
                      ? AppTheme.accentPrimary.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Status label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isOn ? AppTheme.accentPrimary : AppTheme.textSecondary,
            letterSpacing: 1.5,
          ),
          child: Text(isOn ? 'BUKA' : 'TUTUP'),
        ),

        const SizedBox(height: 4),

        Text(
          'Tap toggle untuk ubah posisi',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textTertiary.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
