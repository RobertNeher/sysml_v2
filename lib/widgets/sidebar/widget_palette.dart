import 'package:flutter/material.dart';
import '../../models/sysml_types.dart';

class WidgetPalette extends StatelessWidget {
  const WidgetPalette({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _buildPaletteTile(
          context,
          'Block',
          SysmlElementType.block,
          Icons.rectangle_outlined,
        ),
        _buildPaletteTile(
          context,
          'Part',
          SysmlElementType.partProperty,
          Icons.reorder,
        ),
        _buildPaletteTile(
          context,
          'Port',
          SysmlElementType.port,
          Icons.adjust,
        ),
        const Divider(),
        _buildPaletteTile(
          context,
          'Actor',
          SysmlElementType.actor,
          Icons.person_outline,
        ),
        _buildPaletteTile(
          context,
          'Use Case',
          SysmlElementType.useCase,
          Icons.circle_outlined,
        ),
        const Divider(),
        _buildPaletteTile(
          context,
          'Requirement',
          SysmlElementType.requirement,
          Icons.assignment_outlined,
        ),
      ],
    );
  }

  Widget _buildPaletteTile(
    BuildContext context,
    String label,
    SysmlElementType type,
    IconData icon,
  ) {
    return Draggable<SysmlElementType>(
      data: type,
      feedback: Material(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(icon),
          title: Text(label),
          dense: true,
        ),
      ),
    );
  }
}
