import 'package:flutter/material.dart';
import '../../models/sysml_element.dart';
import '../../models/sysml_types.dart';
import '../../theme/coad_colors.dart';
import 'requirement_painter.dart';

class ElementWidget extends StatelessWidget {
  final SysmlElement element;
  final bool isSelected;
  final bool isConnectionSource;

  const ElementWidget({
    super.key,
    required this.element,
    this.isSelected = false,
    this.isConnectionSource = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorArchetype = _getColorArchetype(element.type);
    final stereotype = _getStereotype(element.type);
    
    final borderColor = isConnectionSource
        ? Colors.orange
        : (isSelected
            ? Theme.of(context).colorScheme.primary
            : _getDarkerArchetype(element.type));

    final borderWidth = (isSelected || isConnectionSource) ? 2.0 : 1.0;

    Widget content = _buildContent(context, stereotype);

    if (element.type == SysmlElementType.requirement) {
      return SizedBox(
        width: element.width,
        height: element.height,
        child: CustomPaint(
          painter: RequirementPainter(
            color: colorArchetype,
            borderColor: borderColor,
            borderWidth: borderWidth,
          ),
          child: content,
        ),
      );
    }

    if (element.type == SysmlElementType.port) {
      return Container(
        width: element.width,
        height: element.height,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: CoadColors.blueDark, width: 1.5),
        ),
        child: Center(
          child: Container(
            width: 4,
            height: 4,
            color: CoadColors.blueDark,
          ),
        ),
      );
    }

    return Container(
      width: element.width,
      height: element.height,
      decoration: BoxDecoration(
        color: colorArchetype,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: (isSelected || isConnectionSource)
            ? [
                BoxShadow(
                  color: (isConnectionSource ? Colors.orange : Theme.of(context).colorScheme.primary)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: content,
    );
  }

  Widget _buildContent(BuildContext context, String stereotype) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _getDarkerArchetype(element.type).withOpacity(0.3),
              ),
            ),
          ),
          child: Column(
            children: [
              Text(
                '«$stereotype»',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      fontSize: 10,
                      color: Colors.black54,
                    ),
              ),
              // Peter Coad Archetype Label
              Text(
                _getArchetypeLabel(element.type),
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: _getDarkerArchetype(element.type),
                ),
              ),
              if (element.type == SysmlElementType.requirement && element.properties['reqId'] != null)
                Text(
                  'ID: ${element.properties['reqId']}',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              Text(
                element.label.isEmpty ? _getDefaultLabel(element.type) : element.label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // Compartment
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildCompartmentContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCompartmentContent(BuildContext context) {
    if (element.type == SysmlElementType.requirement) {
      final text = element.properties['statement'] ?? 'No requirement text defined.';
      return Text(
        text,
        style: const TextStyle(fontSize: 10, color: Colors.black87),
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      );
    }
    
    // Default compartment placeholder
    return const SizedBox.shrink();
  }

  Color _getColorArchetype(SysmlElementType type) {
    switch (type) {
      case SysmlElementType.requirement:
      case SysmlElementType.constraintBlock:
      case SysmlElementType.port:
        return CoadColors.blue;
      case SysmlElementType.useCase:
        return CoadColors.pink;
      case SysmlElementType.block:
        return CoadColors.green;
      case SysmlElementType.partProperty:
      case SysmlElementType.actor:
        return CoadColors.yellow;
      default:
        return Colors.white;
    }
  }

  Color _getDarkerArchetype(SysmlElementType type) {
    switch (type) {
      case SysmlElementType.requirement:
      case SysmlElementType.constraintBlock:
      case SysmlElementType.port:
        return CoadColors.blueDark;
      case SysmlElementType.useCase:
        return CoadColors.pinkDark;
      case SysmlElementType.block:
        return CoadColors.greenDark;
      case SysmlElementType.partProperty:
      case SysmlElementType.actor:
        return CoadColors.yellowDark;
      default:
        return Colors.grey;
    }
  }

  String _getStereotype(SysmlElementType type) {
    switch (type) {
      case SysmlElementType.block: return 'block';
      case SysmlElementType.partProperty: return 'part';
      case SysmlElementType.port: return 'port';
      case SysmlElementType.actor: return 'actor';
      case SysmlElementType.useCase: return 'useCase';
      case SysmlElementType.requirement: return 'requirement';
      case SysmlElementType.constraintBlock: return 'constraintBlock';
      case SysmlElementType.comment: return 'comment';
    }
  }

  String _getDefaultLabel(SysmlElementType type) {
    switch (type) {
      case SysmlElementType.block: return 'New Block';
      case SysmlElementType.requirement: return 'New Requirement';
      case SysmlElementType.useCase: return 'New Use Case';
      default: return 'New Element';
    }
  }

  String _getArchetypeLabel(SysmlElementType type) {
    switch (type) {
      case SysmlElementType.requirement:
      case SysmlElementType.constraintBlock: return 'Description';
      case SysmlElementType.useCase: return 'Moment-Interval';
      case SysmlElementType.block: return 'Thing';
      case SysmlElementType.actor:
      case SysmlElementType.partProperty: return 'Role';
      case SysmlElementType.port: return 'Interface';
      default: return '';
    }
  }
}
