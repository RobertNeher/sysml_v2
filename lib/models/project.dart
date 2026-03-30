import 'package:json_annotation/json_annotation.dart';
import 'sysml_element.dart';
import 'connection.dart';
import 'sysml_types.dart';

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
  })  : elements = elements ?? [],
        connections = connections ?? [];

  factory DiagramTab.fromJson(Map<String, dynamic> json) =>
      _$DiagramTabFromJson(json);

  Map<String, dynamic> toJson() => _$DiagramTabToJson(this);
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
  })  : createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now(),
        tabs = tabs ?? [];

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
