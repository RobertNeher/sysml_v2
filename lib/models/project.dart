import 'package:json_annotation/json_annotation.dart';
import 'sysml_element.dart';
import 'connection.dart';
import 'sysml_types.dart';
import 'settings.dart';

part 'project.g.dart';

@JsonSerializable()
class DiagramTab {
  final String id;
  String name;
  SysmlDiagramType diagramType;
  List<SysmlElement> elements;
  List<Connection> connections;

  DiagramTab({
    required this.id,
    required this.name,
    required this.diagramType,
    List<SysmlElement>? elements,
    List<Connection>? connections,
    this.settings,
  })  : elements = elements ?? [],
        connections = connections ?? [];

  factory DiagramTab.fromJson(Map<String, dynamic> json) =>
      _$DiagramTabFromJson(json);

  Map<String, dynamic> toJson() => _$DiagramTabToJson(this);

  DiagramTab clone() {
    return DiagramTab(
      id: id,
      name: name,
      diagramType: diagramType,
      elements: elements.map((e) => e.copyWith()).toList(),
      connections:
          connections.map((c) => c).toList(), // TODO: Connection clone
      settings: settings?.copyWith(),
    );
  }

  DiagramSettings? settings;

  DiagramTab updateElement(String id, SysmlElement Function(SysmlElement) updater) {
    final newElements = elements.map((e) => e.id == id ? updater(e) : e).toList();
    return DiagramTab(
      id: id,
      name: name,
      diagramType: diagramType,
      elements: newElements,
      connections: connections,
      settings: settings,
    );
  }
}

@JsonSerializable()
class Project {
  String name;
  String author;
  DateTime createdAt;
  DateTime modifiedAt;
  String description; // Markdown
  List<DiagramTab> tabs;

  Project({
    required this.name,
    this.author = '',
    DateTime? createdAt,
    DateTime? modifiedAt,
    this.description = '',
    List<DiagramTab>? tabs,
    ProjectSettings? settings,
  })  : createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now(),
        tabs = tabs ?? [],
        settings = settings ?? ProjectSettings();

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  Project clone() {
    return Project(
      name: name,
      author: author,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      description: description,
      tabs: tabs.map((t) => t.clone()).toList(),
      settings: settings.copyWith(),
    );
  }

  Project updateElement(int tabIndex, String elementId, SysmlElement Function(SysmlElement) updater) {
    final newTabs = List<DiagramTab>.from(tabs);
    newTabs[tabIndex] = newTabs[tabIndex].updateElement(elementId, updater);
    return Project(
      name: name,
      author: author,
      createdAt: createdAt,
      modifiedAt: DateTime.now(),
      description: description,
      tabs: newTabs,
      settings: settings,
    );
  }

  Project updateTabSettings(int tabIndex, DiagramSettings settings) {
    final newTabs = List<DiagramTab>.from(tabs);
    newTabs[tabIndex].settings = settings;
    return Project(
      name: name,
      author: author,
      createdAt: createdAt,
      modifiedAt: DateTime.now(),
      description: description,
      tabs: newTabs,
      settings: this.settings,
    );
  }

  ProjectSettings settings;
}
