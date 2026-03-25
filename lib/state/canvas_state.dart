import 'package:flutter/material.dart';

class CanvasState extends ChangeNotifier {
  double _zoom = 1.0;
  Offset _panOffset = Offset.zero;
  bool _showGrid = true;
  double _gridSize = 20.0;

  double get zoom => _zoom;
  Offset get panOffset => _panOffset;
  bool get showGrid => _showGrid;
  double get gridSize => _gridSize;

  void updateZoom(double newZoom) {
    _zoom = newZoom.clamp(0.1, 5.0);
    notifyListeners();
  }

  void updatePan(Offset delta) {
    _panOffset += delta;
    notifyListeners();
  }

  void setPan(Offset offset) {
    _panOffset = offset;
    notifyListeners();
  }

  void toggleGrid() {
    _showGrid = !_showGrid;
    notifyListeners();
  }

  void setGridSize(double size) {
    _gridSize = size;
    notifyListeners();
  }

  double snap(double value) {
    return (value / _gridSize).round() * _gridSize;
  }

  Offset snapOffset(Offset offset) {
    return Offset(snap(offset.dx), snap(offset.dy));
  }
}
