// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProjectSettings _$ProjectSettingsFromJson(Map<String, dynamic> json) =>
    ProjectSettings(
      gridSize: (json['gridSize'] as num?)?.toDouble() ?? 20.0,
      showGrid: json['showGrid'] as bool? ?? true,
      snapToGrid: json['snapToGrid'] as bool? ?? true,
    );

Map<String, dynamic> _$ProjectSettingsToJson(ProjectSettings instance) =>
    <String, dynamic>{
      'gridSize': instance.gridSize,
      'showGrid': instance.showGrid,
      'snapToGrid': instance.snapToGrid,
    };

DiagramSettings _$DiagramSettingsFromJson(Map<String, dynamic> json) =>
    DiagramSettings(
      gridSize: (json['gridSize'] as num?)?.toDouble(),
      showGrid: json['showGrid'] as bool?,
      snapToGrid: json['snapToGrid'] as bool?,
    );

Map<String, dynamic> _$DiagramSettingsToJson(DiagramSettings instance) =>
    <String, dynamic>{
      'gridSize': instance.gridSize,
      'showGrid': instance.showGrid,
      'snapToGrid': instance.snapToGrid,
    };
