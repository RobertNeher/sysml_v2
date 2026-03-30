import 'package:json_annotation/json_annotation.dart';
import 'sysml_types.dart';

part 'settings.g.dart';

@JsonSerializable()
class ProjectSettings {
  final double gridSize;
  final bool showGrid;
  final bool snapToGrid;

  ProjectSettings({
    this.gridSize = 20.0,
    this.showGrid = true,
    this.snapToGrid = true,
  });

  ProjectSettings copyWith({
    double? gridSize,
    bool? showGrid,
    bool? snapToGrid,
  }) {
    return ProjectSettings(
      gridSize: gridSize ?? this.gridSize,
      showGrid: showGrid ?? this.showGrid,
      snapToGrid: snapToGrid ?? this.snapToGrid,
    );
  }

  factory ProjectSettings.fromJson(Map<String, dynamic> json) =>
      _$ProjectSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectSettingsToJson(this);
}

@JsonSerializable()
class DiagramSettings {
  final double? gridSize;
  final bool? showGrid;
  final bool? snapToGrid;

  DiagramSettings({
    this.gridSize,
    this.showGrid,
    this.snapToGrid,
  });

  DiagramSettings copyWith({
    double? gridSize,
    bool? showGrid,
    bool? snapToGrid,
  }) {
    return DiagramSettings(
      gridSize: gridSize ?? this.gridSize,
      showGrid: showGrid ?? this.showGrid,
      snapToGrid: snapToGrid ?? this.snapToGrid,
    );
  }

  factory DiagramSettings.fromJson(Map<String, dynamic> json) =>
      _$DiagramSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$DiagramSettingsToJson(this);

  static DiagramSettings defaultsFor(SysmlDiagramType type) {
    switch (type) {
      case SysmlDiagramType.internalBlockDiagram:
        return DiagramSettings(gridSize: 15.0);
      case SysmlDiagramType.parametricDiagram:
        return DiagramSettings(gridSize: 15.0);
      case SysmlDiagramType.blockDefinitionDiagram:
      default:
        return DiagramSettings(gridSize: 20.0);
    }
  }
}
