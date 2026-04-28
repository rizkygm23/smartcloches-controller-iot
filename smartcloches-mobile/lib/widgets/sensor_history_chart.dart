import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SensorHistoryChart extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> tempHistory;
  final List<Map<String, dynamic>> humHistory;

  const SensorHistoryChart({
    super.key,
    required this.title,
    required this.tempHistory,
    required this.humHistory,
  });

  @override
  State<SensorHistoryChart> createState() => _SensorHistoryChartState();
}

class _SensorHistoryChartState extends State<SensorHistoryChart>
    with SingleTickerProviderStateMixin {
  bool _showTemp = true;
  bool _showHum = true;
  late AnimationController _animController;
  late Animation<double> _animValue;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animValue = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(SensorHistoryChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh animation if new points added
    if (oldWidget.tempHistory.length != widget.tempHistory.length) {
      _animController.forward(from: 0.8);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.divider.withValues(alpha: 0.5),
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentPrimary.withValues(alpha: 0.12),
                          AppTheme.accentSecondary.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      color: AppTheme.accentPrimary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Mode Live (Bebas Limit)',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Toggle chips
          Row(
            children: [
              _ToggleChip(
                label: 'Suhu',
                color: AppTheme.tempColor,
                isActive: _showTemp,
                onTap: () => setState(() => _showTemp = !_showTemp),
              ),
              const SizedBox(width: 8),
              _ToggleChip(
                label: 'Kelembaban',
                color: AppTheme.humColor,
                isActive: _showHum,
                onTap: () => setState(() => _showHum = !_showHum),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Chart area
          SizedBox(
            height: 180,
            child: (widget.tempHistory.isEmpty && widget.humHistory.isEmpty)
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.show_chart_rounded,
                          size: 36,
                          color: AppTheme.textTertiary.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Menunggu data...',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.textTertiary.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  )
                : AnimatedBuilder(
                    animation: _animValue,
                    builder: (context, _) {
                      return CustomPaint(
                        size: const Size(double.infinity, 180),
                        painter: _ChartPainter(
                          tempData: _showTemp ? widget.tempHistory : [],
                          humData: _showHum ? widget.humHistory : [],
                          animValue: _animValue.value,
                          tempColor: AppTheme.tempColor,
                          humColor: AppTheme.humColor,
                          gridColor: AppTheme.divider,
                        ),
                      );
                    },
                  ),
          ),

          if (widget.tempHistory.isNotEmpty || widget.humHistory.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (_showTemp && widget.tempHistory.isNotEmpty)
                  _StatChip(
                    label: 'Suhu Saat Ini',
                    value: '${widget.tempHistory.last['value'].toStringAsFixed(1)}°C',
                    color: AppTheme.tempColor,
                  ),
                if (_showTemp && _showHum) const SizedBox(width: 8),
                if (_showHum && widget.humHistory.isNotEmpty)
                  _StatChip(
                    label: 'Hum Saat Ini',
                    value: '${widget.humHistory.last['value'].toStringAsFixed(0)}%',
                    color: AppTheme.humColor,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleChip({
    required this.label,
    required this.color,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.3) : AppTheme.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? color : AppTheme.divider,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? color : AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> tempData;
  final List<Map<String, dynamic>> humData;
  final double animValue;
  final Color tempColor;
  final Color humColor;
  final Color gridColor;

  _ChartPainter({
    required this.tempData,
    required this.humData,
    required this.animValue,
    required this.tempColor,
    required this.humColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartHeight = size.height - 20;
    final chartWidth = size.width;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = chartHeight * i / 4;
      canvas.drawLine(Offset(0, y), Offset(chartWidth, y), gridPaint);
    }

    // Draw temperature line
    if (tempData.isNotEmpty) {
      _drawLine(canvas, size, tempData, tempColor, chartHeight, chartWidth);
    }

    // Draw humidity line
    if (humData.isNotEmpty) {
      _drawLine(canvas, size, humData, humColor, chartHeight, chartWidth);
    }
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<Map<String, dynamic>> data,
    Color color,
    double chartHeight,
    double chartWidth,
  ) {
    if (data.length < 2) return;

    final values = data.map((e) => e['value'] as double).toList();
    final minVal = values.reduce(math.min) - 1;
    final maxVal = values.reduce(math.max) + 1;
    final range = maxVal - minVal;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length > 1 ? data.length - 1 : 1)) * chartWidth;
      final normalized = range > 0 ? (values[i] - minVal) / range : 0.5;
      final y = chartHeight - (normalized * chartHeight * animValue);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, chartHeight);
        fillPath.lineTo(x, y);
      } else {
        final prevX = ((i - 1) / (data.length - 1)) * chartWidth;
        final prevNorm = range > 0 ? (values[i - 1] - minVal) / range : 0.5;
        final prevY = chartHeight - (prevNorm * chartHeight * animValue);
        final cpX = (prevX + x) / 2;

        path.cubicTo(cpX, prevY, cpX, y, x, y);
        fillPath.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    fillPath.lineTo(chartWidth, chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.15 * animValue),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, chartWidth, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = color.withValues(alpha: animValue)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}
