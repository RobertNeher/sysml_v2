import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/sysml_types.dart';
import '../models/sysml_element.dart';
import '../models/alignment_types.dart';
import '../models/settings.dart';
import '../models/connection.dart';

class AppState extends ChangeNotifier {
  Project _project;
  int _currentTabIndex = 0;
  final _uuid = const Uuid();

  ConnectionType? _activeConnectionType;
  String? _connectionSourceId;
  String? _selectedElementId;
  String? _selectedConnectionId;

  Project get project => _project;
  int get currentTabIndex => _currentTabIndex;
  DiagramTab get currentTab => _project.tabs[_currentTabIndex];
  ConnectionType? get activeConnectionType => _activeConnectionType;
  String? get connectionSourceId => _connectionSourceId;
  String? get selectedElementId => _selectedElementId;
  String? get selectedConnectionId => _selectedConnectionId;

  AppState()
      : _project = Project(
          name: 'New Project',
          tabs: [
            DiagramTab(
              id: 'initial-tab',
              name: 'Main Block Diagram',
              diagramType: SysmlDiagramType.blockDefinitionDiagram,
            )
          ],
        );

  void setProjectName(String name) {
    _project.name = name;
    _project.modifiedAt = DateTime.now();
    notifyListeners();
  }

  // Tab Management
  void addTab(String name, SysmlDiagramType type) {
    _project.tabs.add(DiagramTab(
      id: _uuid.v4(),
      name: name,
      diagramType: type,
    ));
    _currentTabIndex = _project.tabs.length - 1;
    notifyListeners();
  }

  void removeTab(int index) {
    if (_project.tabs.length > 1) {
      _project.tabs.removeAt(index);
      if (_currentTabIndex >= _project.tabs.length) {
        _currentTabIndex = _project.tabs.length - 1;
      }
      notifyListeners();
    }
  }

  void setCurrentTabIndex(int index) {
    _currentTabIndex = index;
    _selectedElementId = null;
    _selectedConnectionId = null;
    notifyListeners();
  }

  void updateTabName(int index, String name) {
    _project.tabs[index].name = name;
    notifyListeners();
  }

  // Element Management
  void addElement(int tabIndex, SysmlElement element) {
    _saveHistoryState();
    _project.tabs[tabIndex].elements.add(element);
    _selectedElementId = element.id;
    _selectedConnectionId = null;
    notifyListeners();
  }

  void setSelectedElementId(String? id) {
    if (_selectedElementId == id && _selectedConnectionId == null) return;
    _selectedElementId = id;
    _selectedConnectionId = null;
    notifyListeners();
  }

  void setSelectedConnectionId(String? id) {
    if (_selectedConnectionId == id && _selectedElementId == null) return;
    _selectedConnectionId = id;
    _selectedElementId = null;
    notifyListeners();
  }

  void moveElements(Set<String> ids, Offset delta) {
    bool changed = false;
    final tab = _project.tabs[_currentTabIndex];
    for (int i = 0; i < tab.elements.length; i++) {
      if (ids.contains(tab.elements[i].id)) {
        tab.elements[i] = tab.elements[i].copyWith(
          x: tab.elements[i].x + delta.dx,
          y: tab.elements[i].y + delta.dy,
        );
        changed = true;
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
    _saveHistoryState();
    final tab = _project.tabs[_currentTabIndex];
    bool changed = false;
    
    // Remove elements
    final initialCount = tab.elements.length;
    tab.elements.removeWhere((e) => ids.contains(e.id));
    if (tab.elements.length != initialCount) changed = true;

    // Cascade delete connections
    final initialConnCount = tab.connections.length;
    tab.connections.removeWhere((c) => 
      ids.contains(c.sourceElementId) || ids.contains(c.targetElementId));
    if (tab.connections.length != initialConnCount) changed = true;

    if (changed) {
      if (ids.contains(_selectedElementId)) {
        _selectedElementId = null;
      }
      notifyListeners();
    }
  }

  void updateElementLabel(String id, String newLabel) {
    _project = _project.updateElement(
      _currentTabIndex,
      id,
      (e) => e.copyWith(label: newLabel),
    );
    _saveHistoryState();
    notifyListeners();
  }

  void updateElementProperty(String id, String key, dynamic value) {
    _project = _project.updateElement(
      _currentTabIndex,
      id,
      (e) {
        final newProperties = Map<String, dynamic>.from(e.properties);
        newProperties[key] = value;
        return e.copyWith(properties: newProperties);
      },
    );
    _saveHistoryState();
    notifyListeners();
  }

  // Connection Management
  void setActiveConnectionType(ConnectionType? type) {
    _activeConnectionType = type;
    _connectionSourceId = null;
    notifyListeners();
  }

  void setConnectionSourceId(String? id) {
    _connectionSourceId = id;
    notifyListeners();
  }

  void addConnection(String sourceId, String targetId, ConnectionType type) {
    _saveHistoryState();
    final connection = Connection(
      id: _uuid.v4(),
      sourceElementId: sourceId,
      targetElementId: targetId,
      type: type,
    );
    _project.tabs[_currentTabIndex].connections.add(connection);
    _selectedConnectionId = connection.id;
    _selectedElementId = null;
    notifyListeners();
  }

  void updateConnectionLabel(String id, String newLabel) {
    _saveHistoryState();
    for (var tab in _project.tabs) {
      final index = tab.connections.indexWhere((c) => c.id == id);
      if (index != -1) {
        tab.connections[index].label = newLabel;
        notifyListeners();
        return;
      }
    }
  }

  // Alignment
  bool alignSelectedElements(Set<String> ids, AlignmentType type, {double gap = 20.0}) {
    if (ids.length < 2) return false;
    _saveHistoryState();
    // - [x] Create `lib/theme/coad_colors.dart` with archetype constants.
    // - [x] Add `updateElementProperty` to `AppState`.
    // - [ ] Implement `RequirementPainter` for the folded corner effect.
    return false;
  }

  // Settings Updates (Fixing missing methods from lint errors)
  void updateGlobalSettings(ProjectSettings settings) {
    _project.settings = settings;
    notifyListeners();
  }

  void updateTabSettings(int index, DiagramSettings settings) {
    _project.tabs[index].settings = settings;
    notifyListeners();
  }

  void updateProjectMetadata({String? name, String? author, String? description}) {
    if (name != null) _project.name = name;
    if (author != null) _project.author = author;
    if (description != null) _project.description = description;
    _project.modifiedAt = DateTime.now();
    notifyListeners();
  }

  // Persistence
  String exportProjectJson() {
    return jsonEncode(_project.toJson());
  }

  void importProjectJson(String json) {
    try {
      final Map<String, dynamic> data = jsonDecode(json);
      _project = Project.fromJson(data);
      _currentTabIndex = 0;
      _selectedElementId = null;
      _selectedConnectionId = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error importing project: $e');
    }
  }

  // History / Undo / Redo
  final List<String> _history = [];
  int _historyIndex = -1;

  void _saveHistoryState() {
    final snapshot = exportProjectJson();
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(snapshot);
    if (_history.length > 50) _history.removeAt(0);
    _historyIndex = _history.length - 1;
  }

  void undo() {
    if (_historyIndex > 0) {
      _historyIndex--;
      final data = jsonDecode(_history[_historyIndex]);
      _project = Project.fromJson(data);
      notifyListeners();
    }
  }

  void redo() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      final data = jsonDecode(_history[_historyIndex]);
      _project = Project.fromJson(data);
      notifyListeners();
    }
  }
}
