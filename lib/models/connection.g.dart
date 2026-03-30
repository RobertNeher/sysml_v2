// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Connection _$ConnectionFromJson(Map<String, dynamic> json) => Connection(
  id: json['id'] as String,
  sourceElementId: json['sourceElementId'] as String,
  targetElementId: json['targetElementId'] as String,
  type: $enumDecode(_$ConnectionTypeEnumMap, json['type']),
  label: json['label'] as String? ?? '',
  waypoints:
      (json['waypoints'] as List<dynamic>?)
          ?.map(
            (e) =>
                (e as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
          )
          .toList() ??
      const [],
);

Map<String, dynamic> _$ConnectionToJson(Connection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceElementId': instance.sourceElementId,
      'targetElementId': instance.targetElementId,
      'type': _$ConnectionTypeEnumMap[instance.type]!,
      'label': instance.label,
      'waypoints': instance.waypoints,
    };

const _$ConnectionTypeEnumMap = {
  ConnectionType.association: 'association',
  ConnectionType.dependency: 'dependency',
  ConnectionType.generalization: 'generalization',
  ConnectionType.composition: 'composition',
  ConnectionType.aggregation: 'aggregation',
  ConnectionType.refinement: 'refinement',
};
