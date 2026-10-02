import 'dart:math';
import 'package:flutter/material.dart';

class WeeklyBarChartPainter extends CustomPainter {
  final List<double> weeklySpending; // 7 phần tử (T2 -> CN)

  WeeklyBarChartPainter({required this.weeklySpending});

  @override
  void paint(Canvas canvas, Size size) {
    final maxVal = weeklySpending.reduce(max);
    final effectiveMax = maxVal == 0 ? 1.0 : maxVal;
    final barWidth = size.width / 16;
    final spacing = size.width / 7;
    final labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    final bgBarPaint = Paint()
      ..color = const Color(0xFFECEFF1)
      ..style = PaintingStyle.fill;

    final barPaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..style = PaintingStyle.fill;

    const chartHeight = 85.0;

    for (int i = 0; i < 7; i++) {
      final x = i * spacing + (spacing - barWidth) / 2;
      final heightRatio = weeklySpending[i] / effectiveMax;
      final barHeight = heightRatio * chartHeight;

      // Cột nền mờ
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, 0, barWidth, chartHeight), const Radius.circular(6)),
        bgBarPaint,
      );

      // Cột dữ liệu thực tế
      if (barHeight > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, chartHeight - barHeight, barWidth, barHeight),
            const Radius.circular(6),
          ),
          barPaint,
        );
      }

      // Nhãn thứ trong tuần
      final textSpan = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w500),
      );
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      textPainter.paint(canvas, Offset(x + (barWidth - textPainter.width) / 2, chartHeight + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}