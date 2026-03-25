import 'package:json_annotation/json_annotation.dart';

enum SysmlDiagramType {
  blockDefinitionDiagram,
  internalBlockDiagram,
  useCaseDiagram,
  sequenceDiagram,
  stateMachineDiagram,
  activityDiagram,
  requirementDiagram,
  parametricDiagram,
}

enum SysmlElementType {
  block,
  partProperty,
  port,
  actor,
  useCase,
  requirement,
  constraintBlock,
  comment,
}

enum ConnectionType {
  association,
  dependency,
  generalization,
  composition,
  aggregation,
  refinement,
}
