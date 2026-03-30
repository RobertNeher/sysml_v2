import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/sysml_types.dart';
import '../../models/sysml_element.dart';
import '../../models/connection.dart';

class CanvasPainter extends CustomPainter {
  final double zoom;
  final Offset panOffset;
  final bool showGrid;
  final double gridSize;
  final Color gridColor;
  final Offset? selectionStart;
  final Offset? selectionEnd;
  final List<SysmlElement> elements;
  final List<Connection> connections;
  final String? connectionSourceId;
  final ConnectionType? activeConnectionType;
  final String? selectedConnectionId;
  final Offset? mousePosition;

  CanvasPainter({
    required this.zoom,
    required this.panOffset,
    this.showGrid = true,
    this.gridSize = 20.0,
    required this.gridColor,
    this.selectionStart,
    this.selectionEnd,
    required this.elements,
    required this.connections,
    this.connectionSourceId,
    this.activeConnectionType,
    this.selectedConnectionId,
    this.mousePosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showGrid) {
      _drawGrid(canvas, size);
    }

    _drawConnections(canvas);
    _drawConnectionPreview(canvas);

    if (selectionStart != null && selectionEnd != null) {
      _drawSelectionBox(canvas);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor.withOpacity(0.2)
      ..strokeWidth = 0.5;

    final double width = 5000;
    final double height = 5000;

    for (double x = -width; x < width; x += gridSize) {
      canvas.drawLine(Offset(x, -height), Offset(x, height), paint);
    }
    for (double y = -height; y < height; y += gridSize) {
      canvas.drawLine(Offset(-width, y), Offset(width, y), paint);
    }
  }

  void _drawConnections(Canvas canvas) {
    for (var connection in connections) {
      final source = elements.firstWhere((e) => e.id == connection.sourceElementId);
      final target = elements.firstWhere((e) => e.id == connection.targetElementId);

      final startPos = Offset(
        source.x + source.width / 2,
        source.y + source.height / 2,
      );
      final endPos = Offset(
        target.x + target.width / 2,
        target.y + target.height / 2,
      );

      final isSelected = connection.id == selectedConnectionId;

      final paint = Paint()
        ..color = isSelected ? Colors.blue : Colors.black
        ..strokeWidth = (isSelected ? 3.0 : 2.0) / zoom
        ..style = PaintingStyle.stroke;

      if (connection.type == ConnectionType.dependency) {
        paint.strokeWidth = (isSelected ? 2.5 : 1.5) / zoom;
        _drawDashedLine(canvas, startPos, endPos, paint);
      } else {
        canvas.drawLine(startPos, endPos, paint);
      }

      _drawArrowhead(canvas, startPos, endPos, connection.type, isSelected);
    }
  }

  void _drawConnectionPreview(Canvas canvas) {
    if (activeConnectionType == null || connectionSourceId == null || mousePosition == null) return;

    final source = elements.firstWhere((e) => e.id == connectionSourceId);
    final startPos = Offset(
      source.x + source.width / 2,
      source.y + source.height / 2,
    );

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 2.0 / zoom
      ..style = PaintingStyle.stroke;

    _drawDashedLine(canvas, startPos, mousePosition!, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 5.0;
    double distance = (end - start).distance;
    if (distance == 0) return;
    double currentDistance = 0;
    Offset direction = (end - start) / distance;

    while (currentDistance < distance) {
      canvas.drawLine(
        start + direction * currentDistance,
        start + direction * math.min(currentDistance + dashWidth, distance),
        paint,
      );
      currentDistance += dashWidth + dashSpace;
    }
  }

  void _drawArrowhead(Canvas canvas, Offset start, Offset end, ConnectionType type, bool isSelected) {
    final direction = (end - start).direction;
    final arrowSize = 10.0 / zoom;

    final path = Path();
    if (type == ConnectionType.generalization) {
      final strokePaint = Paint()
        ..color = isSelected ? Colors.blue : Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 / zoom;
      
      final fillPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      path.moveTo(end.dx, end.dy);
      path.lineTo(
        end.dx - arrowSize * math.cos(direction - math.pi / 6),
        end.dy - arrowSize * math.sin(direction - math.pi / 6),
      );
      path.lineTo(
        end.dx - arrowSize * math.cos(direction + math.pi / 6),
        end.dy - arrowSize * math.sin(direction + math.pi / 6),
      );
      path.close();
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    } else if (type == ConnectionType.dependency) {
      final strokePaint = Paint()
        ..color = isSelected ? Colors.blue : Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 / zoom;

      path.moveTo(
        end.dx - arrowSize * math.cos(direction - math.pi / 6),
        end.dy - arrowSize * math.sin(direction - math.pi / 6),
      );
      path.lineTo(end.dx, end.dy);
      path.lineTo(
        end.dx - arrowSize * math.cos(direction + math.pi / 6),
        end.dy - arrowSize * math.sin(direction + math.pi / 6),
      );
      canvas.drawPath(path, strokePaint);
    }
  }

  void _drawSelectionBox(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0 / zoom;

    final rect = Rect.fromPoints(selectionStart!, selectionEnd!);
    canvas.drawRect(rect, paint);
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) {
    return oldDelegate.zoom != zoom ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.gridSize != gridSize ||
        oldDelegate.selectionStart != selectionStart ||
        oldDelegate.selectionEnd != selectionEnd ||
        oldDelegate.elements != elements ||
        oldDelegate.connections != connections ||
        oldDelegate.connectionSourceId != connectionSourceId ||
        oldDelegate.activeConnectionType != activeConnectionType ||
        oldDelegate.selectedConnectionId != selectedConnectionId ||
        oldDelegate.mousePosition != mousePosition;
  }
}
