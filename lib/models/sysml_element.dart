import 'package:json_annotation/json_annotation.dart';
import 'sysml_types.dart';

part 'sysml_element.g.dart';

@JsonSerializable()
class SysmlElement {
  final String id;
  final SysmlElementType type;
  double x;
  double y;
  double width;
  double height;
  String label;
  Map<String, dynamic> properties;

  SysmlElement({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.width = 150.0,
    this.height = 100.0,
    this.label = '',
    Map<String, dynamic>? properties,
  }) : properties = properties ?? {};

  factory SysmlElement.fromJson(Map<String, dynamic> json) =>
      _$SysmlElementFromJson(json);

  Map<String, dynamic> toJson() => _$SysmlElementToJson(this);

  SysmlElement copyWith({
    String? id,
    SysmlElementType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    String? label,
    Map<String, dynamic>? properties,
  }) {
    return SysmlElement(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      label: label ?? this.label,
      properties: properties ?? Map.from(this.properties),
    );
  }
}
