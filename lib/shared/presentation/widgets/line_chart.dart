import 'package:flutter/material.dart';

import 'package:nexoraiot/app/theme/app_colors.dart';

class LineChart extends StatelessWidget {
  final List<double> values;
  final bool showGrid;
  final bool showLastDot;

  const LineChart({
    super.key,
    required this.values,
    this.showGrid = false,
    this.showLastDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LineChartPainter(
        values: values,
        showGrid: showGrid,
        showLastDot: showLastDot,
      ),
      size: Size.infinite,
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> values;
  final bool showGrid;
  final bool showLastDot;

  LineChartPainter({
    required this.values,
    required this.showGrid,
    required this.showLastDot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    double minValue = values.first;
    double maxValue = values.first;

    for (final value in values) {
      if (value < minValue) minValue = value;
      if (value > maxValue) maxValue = value;
    }

    final range = maxValue - minValue == 0 ? 1 : maxValue - minValue;
    final dx = size.width / (values.length - 1);

    if (showGrid) {
      final gridPaint = Paint()
        ..color = AppColors.border.withOpacity(0.6)
        ..strokeWidth = 1;

      for (int i = 1; i <= 3; i++) {
        final y = size.height * i / 4;
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          gridPaint,
        );
      }
    }

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      final x = dx * i;
      final normalized = (values[i] - minValue) / range;
      final y = size.height - normalized * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..color = AppColors.blue.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    if (showLastDot) {
      final lastX = dx * (values.length - 1);
      final lastNormalized = (values.last - minValue) / range;
      final lastY = size.height - lastNormalized * size.height;

      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = AppColors.blue
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(lastX, lastY), 4, dotPaint);
      canvas.drawCircle(Offset(lastX, lastY), 4, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.showLastDot != showLastDot;
  }
}
