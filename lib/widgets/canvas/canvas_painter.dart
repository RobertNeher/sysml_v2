import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/sysml_types.dart';
import '../../models/sysml_element.dart';
import '../../models/connection.dart';
import '../../utils/routing_utils.dart';

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

      final pathPoints = RoutingUtils.calculateOrthogonalPath(source, target);
      final isSelected = connection.id == selectedConnectionId;

      final paint = Paint()
        ..color = isSelected ? Colors.blue : Colors.black
        ..strokeWidth = (isSelected ? 3.0 : 2.0) / zoom
        ..style = PaintingStyle.stroke;

      final roundedPath = _createRoundedPath(pathPoints, 8.0 / zoom);

      if (connection.type == ConnectionType.dependency) {
        paint.strokeWidth = (isSelected ? 2.5 : 1.5) / zoom;
        _drawDashedPath(canvas, roundedPath, paint);
      } else {
        canvas.drawPath(roundedPath, paint);
      }

      // Calculate direction of the last segment for arrowhead
      if (pathPoints.length >= 2) {
        final last = pathPoints.last;
        final secondLast = pathPoints[pathPoints.length - 2];
        _drawArrowhead(canvas, secondLast, last, connection.type, isSelected);
      }
    }
  }

  void _drawConnectionPreview(Canvas canvas) {
    if (activeConnectionType == null || connectionSourceId == null || mousePosition == null) return;

    final source = elements.firstWhere((e) => e.id == connectionSourceId);
    final sourceRect = Rect.fromLTWH(source.x, source.y, source.width, source.height);
    
    // Choose start position on source boundary
    final start = sourceRect.center;
    final end = mousePosition!;
    
    // Simple logic for preview start point
    late Offset previewStart;
    if ((end.dx - start.dx).abs() > (end.dy - start.dy).abs()) {
      previewStart = Offset(end.dx > start.dx ? sourceRect.right : sourceRect.left, start.dy);
    } else {
      previewStart = Offset(start.dx, end.dy > start.dy ? sourceRect.bottom : sourceRect.top);
    }

    final pathPoints = RoutingUtils.calculatePreviewRoute(previewStart, end);

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..strokeWidth = 2.0 / zoom
      ..style = PaintingStyle.stroke;

    final roundedPath = _createRoundedPath(pathPoints, 8.0 / zoom);
    _drawDashedPath(canvas, roundedPath, paint);
  }

  Path _createRoundedPath(List<Offset> points, double radius) {
    if (points.isEmpty) return Path();
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    if (points.length < 2) return path;

    for (int i = 1; i < points.length; i++) {
      final p1 = points[i - 1];
      final p2 = points[i];

      if (i < points.length - 1) {
        final p3 = points[i + 1];
        
        // Direction vectors
        final v1 = (p2 - p1);
        final v2 = (p3 - p2);
        
        final actualRadius = math.min(radius, math.min(v1.distance / 2, v2.distance / 2));
        
        final d1 = v1 / v1.distance;
        final d2 = v2 / v2.distance;
        
        final curveStart = p2 - d1 * actualRadius;
        final curveEnd = p2 + d2 * actualRadius;
        
        path.lineTo(curveStart.dx, curveStart.dy);
        path.arcToPoint(
          curveEnd,
          radius: Radius.circular(actualRadius),
          clockwise: _isClockwise(p1, p2, p3),
        );
      } else {
        path.lineTo(p2.dx, p2.dy);
      }
    }
    return path;
  }

  bool _isClockwise(Offset a, Offset b, Offset c) {
    // Cross product of (b-a) and (c-b)
    return (b.dx - a.dx) * (c.dy - b.dy) - (b.dy - a.dy) * (c.dx - b.dx) > 0;
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 10.0;
    const dashSpace = 5.0;

    for (final pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final double nextDistance = distance + dashWidth;
        final Path dashPath = pathMetric.extractPath(distance, math.min(nextDistance, pathMetric.length));
        canvas.drawPath(dashPath, paint);
        distance = nextDistance + dashSpace;
      }
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
