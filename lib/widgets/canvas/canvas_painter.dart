import 'package:flutter/material.dart';

class CanvasPainter extends CustomPainter {
  final double zoom;
  final Offset panOffset;
  final bool showGrid;
  final double gridSize;
  final Color gridColor;

  CanvasPainter({
    required this.zoom,
    required this.panOffset,
    required this.showGrid,
    required this.gridSize,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      _drawGrid(canvas, size);
    }
    
    // Connections will be drawn here later
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor.withOpacity(0.1)
      ..strokeWidth = 1.0;

    final scaledGridSize = gridSize * zoom;
    
    // Calculate the start positions based on pan offset
    double startX = panOffset.dx % scaledGridSize;
    double startY = panOffset.dy % scaledGridSize;

    // Draw vertical lines
    for (double x = startX; x < size.width; x += scaledGridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = startY; y < size.height; y += scaledGridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return oldDelegate.zoom != zoom ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.gridSize != gridSize;
  }
}
