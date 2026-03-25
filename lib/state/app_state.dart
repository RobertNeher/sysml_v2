import 'package:flutter/foundation.dart';
import 'package:sysml_v2/models/sysml_element.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/sysml_types.dart';

class AppState extends ChangeNotifier {
  Project _project;
  int _currentTabIndex = 0;
  final _uuid = const Uuid();

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
        );

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
    final newTab = DiagramTab(
      id: _uuid.v4(),
      name: name,
      diagramType: type,
    );
    _project.tabs.add(newTab);
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

  void addElement(int tabIndex, SysmlElement element) {
    _project.tabs[tabIndex].elements.add(element);
    notifyListeners();
  }

  void updateTabName(int index, String newName) {
    _project.tabs[index].name = newName;
    notifyListeners();
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
