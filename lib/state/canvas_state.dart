import 'package:flutter/material.dart';

class CanvasState extends ChangeNotifier {
  double _zoom = 1.0;
  Offset _panOffset = Offset.zero;
  bool _showGrid = true;
  double _gridSize = 20.0;
  final Set<String> _selectedIds = {};
  Offset? _selectionStart;
  Offset? _selectionEnd;

  double get zoom => _zoom;
  Offset get panOffset => _panOffset;
  bool get showGrid => _showGrid;
  double get gridSize => _gridSize;
  Set<String> get selectedIds => _selectedIds;
  Offset? get selectionStart => _selectionStart;
  Offset? get selectionEnd => _selectionEnd;

  bool isSelected(String id) => _selectedIds.contains(id);

  void selectElement(String id, {bool multi = false}) {
    if (!multi) {
      _selectedIds.clear();
    }
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }

  void deselectElement(String id) {
    _selectedIds.remove(id);
    notifyListeners();
  }

  void clearSelection() {
    if (_selectedIds.isNotEmpty) {
      _selectedIds.clear();
      notifyListeners();
    }
  }

  void selectAll(Iterable<String> ids) {
    _selectedIds.addAll(ids);
    notifyListeners();
  }

  void startSelection(Offset position) {
    _selectionStart = position;
    _selectionEnd = position;
    notifyListeners();
  }

  void updateSelectionEnd(Offset position) {
    _selectionEnd = position;
    notifyListeners();
  }

  void clearSelectionBox() {
    _selectionStart = null;
    _selectionEnd = null;
    notifyListeners();
  }

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

  void updateFromSettings(double gridSize, bool showGrid) {
    bool changed = false;
    if (_gridSize != gridSize) {
      _gridSize = gridSize;
      changed = true;
    }
    if (_showGrid != showGrid) {
      _showGrid = showGrid;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  double snap(double value) {
    return (value / _gridSize).round() * _gridSize;
  }

  Offset snapOffset(Offset offset) {
    return Offset(snap(offset.dx), snap(offset.dy));
  }
}
