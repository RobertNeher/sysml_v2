import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:sysml_v2/models/sysml_element.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/sysml_types.dart';
import '../models/alignment_types.dart';
import '../models/settings.dart';
import '../models/connection.dart';

class AppState extends ChangeNotifier {
  Project _project;
  int _currentTabIndex = 0;
  final _uuid = const Uuid();

  ConnectionType? _activeConnectionType;
  String? _connectionSourceId;

  ConnectionType? get activeConnectionType => _activeConnectionType;
  String? get connectionSourceId => _connectionSourceId;

  void setActiveConnectionType(ConnectionType? type) {
    _activeConnectionType = type;
    _connectionSourceId = null;
    notifyListeners();
  }

  void setConnectionSourceId(String? id) {
    _connectionSourceId = id;
    notifyListeners();
  }

  AppState()
      : _project = Project(
          name: 'New Project',
          tabs: [
            DiagramTab(
              id: 'initial-tab',
              name: 'Model 1',
              diagramType: SysmlDiagramType.blockDefinitionDiagram,
            ),
          ],
        ) {
    _history.add(_project.clone());
  }

  final List<Project> _history = [];
  int _historyIndex = 0;
  static const int _maxHistory = 50;

  void _saveHistoryState() {
    // If we're not at the end of the history, truncate the future
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    _history.add(_project.clone());

    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    } else {
      _historyIndex++;
    }
  }

  void undo() {
    if (_historyIndex > 0) {
      _historyIndex--;
      _project = _history[_historyIndex].clone();
      notifyListeners();
    }
  }

  void redo() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      _project = _history[_historyIndex].clone();
      notifyListeners();
    }
  }

  Project get project => _project;
  int get currentTabIndex => _currentTabIndex;
  DiagramTab get currentTab => _project.tabs[_currentTabIndex];

  void setProject(Project project) {
    _project = project;
    _currentTabIndex = 0;
    notifyListeners();
  }

  void setCurrentTabIndex(int index) {
    if (index >= 0 && index < _project.tabs.length) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  void addTab(String name, SysmlDiagramType type) {
    _saveHistoryState();
    final newTab = DiagramTab(id: _uuid.v4(), name: name, diagramType: type);
    _project.tabs.add(newTab);
    _currentTabIndex = _project.tabs.length - 1;
    notifyListeners();
  }

  void addConnection(String sourceId, String targetId, ConnectionType type) {
    if (sourceId == targetId) return;
    _saveHistoryState();
    final tab = currentTab;
    final exists = tab.connections.any((c) =>
        c.sourceElementId == sourceId &&
        c.targetElementId == targetId &&
        c.type == type);
    if (!exists) {
      final connection = Connection(
        id: _uuid.v4(),
        sourceElementId: sourceId,
        targetElementId: targetId,
        type: type,
      );
      tab.connections.add(connection);
      notifyListeners();
    }
  }

  void removeTab(int index) {
    if (_project.tabs.length > 1) {
      _saveHistoryState();
      _project.tabs.removeAt(index);
      if (_currentTabIndex >= _project.tabs.length) {
        _currentTabIndex = _project.tabs.length - 1;
      }
      notifyListeners();
    }
  }

  void addElement(int tabIndex, SysmlElement element) {
    _saveHistoryState();
    _project.tabs[tabIndex].elements.add(element);
    notifyListeners();
  }

  void updateElementPosition(String id, double x, double y) {
    for (var tab in _project.tabs) {
      final index = tab.elements.indexWhere((e) => e.id == id);
      if (index != -1) {
        tab.elements[index] = tab.elements[index].copyWith(x: x, y: y);
        notifyListeners();
        return;
      }
    }
  }

  void moveElements(Set<String> ids, Offset delta) {
    bool changed = false;
    // For movement, we normally want to save history ONCE at the start/end of a drag.
    // However, since moveElements is called continuously during drag in the current implementation,
    // we need to be careful.
    // For now, I'll implement it such that we save history BEFORE the change.
    // To avoid saving 60 steps per second, we'll need a "startMove/endMove" logic in the UI.
    // For now, let's keep it simple and just save before a nudge (ArrowKeys).
    
    for (var tab in _project.tabs) {
      for (int i = 0; i < tab.elements.length; i++) {
        if (ids.contains(tab.elements[i].id)) {
          tab.elements[i] = tab.elements[i].copyWith(
            x: tab.elements[i].x + delta.dx,
            y: tab.elements[i].y + delta.dy,
          );
          changed = true;
        }
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void nudgeElements(Set<String> ids, Offset delta) {
    _saveHistoryState();
    moveElements(ids, delta);
  }

  void removeElements(Set<String> ids) {
    if (ids.isEmpty) return;
    _saveHistoryState();
    bool changed = false;
    for (var tab in _project.tabs) {
      final beforeElements = tab.elements.length;
      tab.elements.removeWhere((e) => ids.contains(e.id));
      
      // Cascade delete connections
      final beforeConnections = tab.connections.length;
      tab.connections.removeWhere((c) => 
        ids.contains(c.sourceElementId) || ids.contains(c.targetElementId));

      if (tab.elements.length != beforeElements || tab.connections.length != beforeConnections) {
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  bool alignSelectedElements(Set<String> ids, AlignmentType type,
      {required double gap}) {
    if (ids.length < 2) return false;
    _saveHistoryState();

    final tab = currentTab;
    final selectedElements =
        tab.elements.where((e) => ids.contains(e.id)).toList();
    if (selectedElements.isEmpty) return false;

    // Sort to ensure predictable stacking order
    if (type == AlignmentType.left || type == AlignmentType.right) {
      selectedElements.sort((a, b) => a.y.compareTo(b.y));
    } else {
      selectedElements.sort((a, b) => a.x.compareTo(b.x));
    }

    double? targetValue;
    switch (type) {
      case AlignmentType.left:
        targetValue =
            selectedElements.map((e) => e.x).reduce((a, b) => a < b ? a : b);
        break;
      case AlignmentType.right:
        targetValue = selectedElements
            .map((e) => e.x + e.width)
            .reduce((a, b) => a > b ? a : b);
        break;
      case AlignmentType.top:
        targetValue =
            selectedElements.map((e) => e.y).reduce((a, b) => a < b ? a : b);
        break;
      case AlignmentType.bottom:
        targetValue = selectedElements
            .map((e) => e.y + e.height)
            .reduce((a, b) => a > b ? a : b);
        break;
    }

    // switch above covers all AlignmentType enums, so targetValue won't be null.

    bool itemsShifted = false;
    final List<Rect> placedRects = [];

    // Temporary map for quick updates
    final Map<String, SysmlElement> updatedElements = {
      for (var e in selectedElements) e.id: e
    };

    for (var element in selectedElements) {
      double newX = element.x;
      double newY = element.y;

      // Initial Alignment
      switch (type) {
        case AlignmentType.left:
          newX = targetValue;
          break;
        case AlignmentType.right:
          newX = targetValue - element.width;
          break;
        case AlignmentType.top:
          newY = targetValue;
          break;
        case AlignmentType.bottom:
          newY = targetValue - element.height;
          break;
      }

      // Overlap Resolution
      var currentRect = Rect.fromLTWH(newX, newY, element.width, element.height);

      while (placedRects.any((r) => r.overlaps(currentRect))) {
        itemsShifted = true;
        if (type == AlignmentType.left || type == AlignmentType.right) {
          // Resolve Vertically: Shift Down
          final overlapping =
              placedRects.where((r) => r.overlaps(currentRect)).toList();
          final bottomMost = overlapping
              .map((r) => r.bottom)
              .reduce((a, b) => a > b ? a : b);
          newY = bottomMost + gap;
        } else {
          // Resolve Horizontally: Shift Right
          final overlapping =
              placedRects.where((r) => r.overlaps(currentRect)).toList();
          final rightMost =
              overlapping.map((r) => r.right).reduce((a, b) => a > b ? a : b);
          newX = rightMost + gap;
        }
        currentRect = Rect.fromLTWH(newX, newY, element.width, element.height);
      }

      placedRects.add(currentRect);
      updatedElements[element.id] = element.copyWith(x: newX, y: newY);
    }

    // Apply updates to the actual project
    for (int i = 0; i < tab.elements.length; i++) {
      final updated = updatedElements[tab.elements[i].id];
      if (updated != null) {
        tab.elements[i] = updated;
      }
    }

    notifyListeners();
    return itemsShifted;
  }

  void updateGlobalSettings(ProjectSettings newSettings) {
    _saveHistoryState();
    _project.settings = newSettings;
    notifyListeners();
  }

  void updateTabSettings(int tabIndex, DiagramSettings newSettings) {
    _saveHistoryState();
    _project.tabs[tabIndex].settings = newSettings;
    notifyListeners();
  }

  void updateTabName(int index, String newName) {
    _project.tabs[index].name = newName;
    notifyListeners();
  }

  String exportProjectJson() {
    _project.modifiedAt = DateTime.now();
    return jsonEncode(_project.toJson());
  }

  void importProjectJson(String jsonStr) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonStr);
      _project = Project.fromJson(data);
      _history.clear();
      _historyIndex = -1;
      _currentTabIndex = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error importing project: $e');
      rethrow;
    }
  }

  void updateProjectMetadata({
    String? name,
    String? author,
    String? description,
  }) {
    if (name != null) _project.name = name;
    if (author != null) _project.author = author;
    if (description != null) _project.description = description;
    _project.modifiedAt = DateTime.now();
    notifyListeners();
  }
}
