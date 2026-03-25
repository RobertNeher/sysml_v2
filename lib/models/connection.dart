import 'package:json_annotation/json_annotation.dart';
import 'sysml_types.dart';

part 'connection.g.dart';

@JsonSerializable()
class Connection {
  final String id;
  final String sourceElementId;
  final String targetElementId;
  final ConnectionType type;
  String label;
  List<List<double>> waypoints; // [[x, y], [x, y], ...]

  Connection({
    required this.id,
    required this.sourceElementId,
    required this.targetElementId,
    required this.type,
    this.label = '',
    this.waypoints = const [],
  });

  factory Connection.fromJson(Map<String, dynamic> json) =>
      _$ConnectionFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionToJson(this);
}
