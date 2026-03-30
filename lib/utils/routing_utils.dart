import 'dart:ui';
import '../models/sysml_element.dart';

class RoutingUtils {
  /// Calculates a 3-segment orthogonal path between [source] and [target].
  /// Returns a list of points (Offsets).
  static List<Offset> calculateOrthogonalPath(SysmlElement source, SysmlElement target) {
    // 1. Calculate boundaries
    final sourceRect = Rect.fromLTWH(source.x, source.y, source.width, source.height);
    final targetRect = Rect.fromLTWH(target.x, target.y, target.width, target.height);

    final start = sourceRect.center;
    final end = targetRect.center;

    // 2. Determine relative positions
    final dx = (end.dx - start.dx).abs();
    final dy = (end.dy - start.dy).abs();

    List<Offset> points = [];

    // 3. Simple Z-shape routing logic
    if (dx > dy) {
      // Primary horizontal separation: [Source Center] -> [Midpoint X] -> [Target Y] -> [Target Center]
      // To look good, we exit from left/right sides.
      final startX = end.dx > start.dx ? sourceRect.right : sourceRect.left;
      final endX = end.dx > start.dx ? targetRect.left : targetRect.right;
      final midX = startX + (endX - startX) / 2;

      points = [
        Offset(startX, start.dy),
        Offset(midX, start.dy),
        Offset(midX, end.dy),
        Offset(endX, end.dy),
      ];
    } else {
      // Primary vertical separation: [Source Center] -> [Midpoint Y] -> [Target X] -> [Target Center]
      // Exit from top/bottom sides.
      final startY = end.dy > start.dy ? sourceRect.bottom : sourceRect.top;
      final endY = end.dy > start.dy ? targetRect.top : targetRect.bottom;
      final midY = startY + (endY - startY) / 2;

      points = [
        Offset(start.dx, startY),
        Offset(start.dx, midY),
        Offset(end.dx, midY),
        Offset(end.dx, endY),
      ];
    }

    return points;
  }

  /// Calculates an orthogonal path from [start] (fixed point) to [mouse] (moving point).
  /// Used for live previews.
  static List<Offset> calculatePreviewRoute(Offset start, Offset mouse) {
    final dx = (mouse.dx - start.dx).abs();
    final dy = (mouse.dy - start.dy).abs();

    if (dx > dy) {
      return [
        start,
        Offset(mouse.dx, start.dy),
        mouse,
      ];
    } else {
      return [
        start,
        Offset(start.dx, mouse.dy),
        mouse,
      ];
    }
  }
}
