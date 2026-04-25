import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBgTranslucent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.glassBorder),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
