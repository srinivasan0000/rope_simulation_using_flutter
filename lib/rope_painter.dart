import 'dart:math';

import 'package:flutter/material.dart';

class RopePainter extends CustomPainter {
  final List<Point> points;
  final Offset handlePosition;
  final Color ropeColor;
  final double ropeThickness;
  final bool showPoints;

  RopePainter(this.points, this.handlePosition, this.ropeColor, this.ropeThickness, this.showPoints);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // ..blendMode = BlendMode.
      ..shader = const LinearGradient(
        tileMode: TileMode.repeated,
        colors: [Color.fromARGB(255, 225, 30, 16), Colors.red, Color.fromARGB(255, 203, 88, 80)],
        stops: [0.0, 0.5, 1.0],
      ).createShader(Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height)))
      ..color = ropeColor
      ..strokeWidth = ropeThickness
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(
        Offset(points[i].x.toDouble(), points[i].y.toDouble()),
        Offset(points[i + 1].x.toDouble(), points[i + 1].y.toDouble()),
        paint,
      );
    }

    final handlePaint = Paint()..color = Colors.pink;
    canvas.drawCircle(handlePosition, 10, handlePaint);

    if (showPoints) {
      final pointPaint = Paint()..color = Colors.yellow;
      for (var point in points) {
        canvas.drawCircle(Offset(point.x.toDouble(), point.y.toDouble()), 3, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
