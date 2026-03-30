// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sysml_element.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SysmlElement _$SysmlElementFromJson(Map<String, dynamic> json) => SysmlElement(
  id: json['id'] as String,
  type: $enumDecode(_$SysmlElementTypeEnumMap, json['type']),
  x: (json['x'] as num).toDouble(),
  y: (json['y'] as num).toDouble(),
  width: (json['width'] as num?)?.toDouble() ?? 150.0,
  height: (json['height'] as num?)?.toDouble() ?? 100.0,
  label: json['label'] as String? ?? '',
  properties: json['properties'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$SysmlElementToJson(SysmlElement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SysmlElementTypeEnumMap[instance.type]!,
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'label': instance.label,
      'properties': instance.properties,
    };

const _$SysmlElementTypeEnumMap = {
  SysmlElementType.block: 'block',
  SysmlElementType.partProperty: 'partProperty',
  SysmlElementType.port: 'port',
  SysmlElementType.actor: 'actor',
  SysmlElementType.useCase: 'useCase',
  SysmlElementType.requirement: 'requirement',
  SysmlElementType.constraintBlock: 'constraintBlock',
  SysmlElementType.comment: 'comment',
};
