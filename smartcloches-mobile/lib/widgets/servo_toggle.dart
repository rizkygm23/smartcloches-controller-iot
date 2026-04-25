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
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer glow ring
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isOn
                        ? AppTheme.accentPrimary.withValues(alpha: 0.3)
                        : AppTheme.danger.withValues(alpha: 0.15),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isOn
                          ? AppTheme.accentPrimary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              // Inner circle with degree text
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isOn
                        ? [AppTheme.accentPrimary, const Color(0xFF059669)]
                        : [const Color(0xFF1E293B), const Color(0xFF0F172A)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isOn
                          ? AppTheme.accentPrimary.withValues(alpha: 0.4)
                          : Colors.black45,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          isOn ? '90°' : '0°',
                          style: const TextStyle(
                            fontSize: 28,
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
                    width: 60,
                    height: 6,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: isOn ? AppTheme.accentPrimary : AppTheme.textSecondary,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: isOn
                              ? AppTheme.accentPrimary.withValues(alpha: 0.5)
                              : Colors.transparent,
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

        const SizedBox(height: 32),

        // Toggle switch
        GestureDetector(
          onTap: isLoading ? null : () => onChanged(!isOn),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            width: 100,
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: isOn
                  ? AppTheme.accentPrimary.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: isOn
                    ? AppTheme.accentPrimary.withValues(alpha: 0.5)
                    : AppTheme.glassBorder,
              ),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isOn
                          ? AppTheme.accentPrimary.withValues(alpha: 0.6)
                          : Colors.black38,
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Status label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isOn ? AppTheme.accentPrimary : AppTheme.danger,
            letterSpacing: 1.5,
          ),
          child: Text(isOn ? 'NYALA' : 'MATI'),
        ),

        const SizedBox(height: 4),

        Text(
          'Tap toggle untuk ubah posisi',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
