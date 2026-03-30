// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiagramTab _$DiagramTabFromJson(Map<String, dynamic> json) => DiagramTab(
  id: json['id'] as String,
  name: json['name'] as String,
  diagramType: $enumDecode(_$SysmlDiagramTypeEnumMap, json['diagramType']),
  elements: (json['elements'] as List<dynamic>?)
      ?.map((e) => SysmlElement.fromJson(e as Map<String, dynamic>))
      .toList(),
  connections: (json['connections'] as List<dynamic>?)
      ?.map((e) => Connection.fromJson(e as Map<String, dynamic>))
      .toList(),
  settings: json['settings'] == null
      ? null
      : DiagramSettings.fromJson(json['settings'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DiagramTabToJson(DiagramTab instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'diagramType': _$SysmlDiagramTypeEnumMap[instance.diagramType]!,
      'elements': instance.elements,
      'connections': instance.connections,
      'settings': instance.settings,
    };

const _$SysmlDiagramTypeEnumMap = {
  SysmlDiagramType.blockDefinitionDiagram: 'blockDefinitionDiagram',
  SysmlDiagramType.internalBlockDiagram: 'internalBlockDiagram',
  SysmlDiagramType.useCaseDiagram: 'useCaseDiagram',
  SysmlDiagramType.sequenceDiagram: 'sequenceDiagram',
  SysmlDiagramType.stateMachineDiagram: 'stateMachineDiagram',
  SysmlDiagramType.activityDiagram: 'activityDiagram',
  SysmlDiagramType.requirementDiagram: 'requirementDiagram',
  SysmlDiagramType.parametricDiagram: 'parametricDiagram',
};

Project _$ProjectFromJson(Map<String, dynamic> json) => Project(
  name: json['name'] as String,
  author: json['author'] as String? ?? '',
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  modifiedAt: json['modifiedAt'] == null
      ? null
      : DateTime.parse(json['modifiedAt'] as String),
  description: json['description'] as String? ?? '',
  tabs: (json['tabs'] as List<dynamic>?)
      ?.map((e) => DiagramTab.fromJson(e as Map<String, dynamic>))
      .toList(),
  settings: json['settings'] == null
      ? null
      : ProjectSettings.fromJson(json['settings'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
  'name': instance.name,
  'author': instance.author,
  'createdAt': instance.createdAt.toIso8601String(),
  'modifiedAt': instance.modifiedAt.toIso8601String(),
  'description': instance.description,
  'tabs': instance.tabs,
  'settings': instance.settings,
};
