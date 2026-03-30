import 'package:flutter/material.dart';

class RequirementPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final double foldSize;

  RequirementPainter({
    required this.color,
    required this.borderColor,
    this.borderWidth = 1.0,
    this.foldSize = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - foldSize, 0);
    path.lineTo(size.width, foldSize);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    // Draw the fold line
    final foldPath = Path();
    foldPath.moveTo(size.width - foldSize, 0);
    foldPath.lineTo(size.width - foldSize, foldSize);
    foldPath.lineTo(size.width, foldSize);
    
    // Add a bit of shadow/contrast to the fold
    final foldPaint = Paint()
      ..color = borderColor.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(foldPath, foldPaint);
    canvas.drawPath(foldPath, borderPaint);
  }

  @override
  bool shouldRepaint(RequirementPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.foldSize != foldSize;
  }
}
