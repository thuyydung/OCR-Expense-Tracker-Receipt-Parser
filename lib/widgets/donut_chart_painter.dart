import 'dart:math';
import 'package:flutter/material.dart';

class DonutChartPainter extends CustomPainter {
  final Map<String, double> categoryData;
  final Map<String, Color> categoryColors;

  DonutChartPainter({required this.categoryData, required this.categoryColors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = categoryData.values.fold(0.0, (sum, val) => sum + val);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    const strokeWidth = 22.0;

    if (total == 0) {
      final basePaint = Paint()
        ..color = Colors.grey.shade200
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawCircle(center, radius - strokeWidth / 2, basePaint);
      return;
    }

    double startAngle = -pi / 2;
    for (final entry in categoryData.entries) {
      if (entry.value <= 0) continue;
      final sweepAngle = (entry.value / total) * 2 * pi;
      final paint = Paint()
        ..color = categoryColors[entry.key] ?? Colors.indigo
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}