import 'package:flutter/material.dart';
import '../../models/sysml_types.dart';

class RenameTabDialog extends StatefulWidget {
  final String initialName;

  const RenameTabDialog({super.key, required this.initialName});

  @override
  State<RenameTabDialog> createState() => _RenameTabDialogState();
}

class _RenameTabDialogState extends State<RenameTabDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Diagram'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Diagram Name'),
        onSubmitted: (val) => Navigator.of(context).pop(val),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Rename'),
        ),
      ],
    );
  }
}

class NewDiagramDialog extends StatefulWidget {
  final SysmlDiagramType initialType;

  const NewDiagramDialog({super.key, required this.initialType});

  @override
  State<NewDiagramDialog> createState() => _NewDiagramDialogState();
}

class _NewDiagramDialogState extends State<NewDiagramDialog> {
  late TextEditingController _controller;
  late SysmlDiagramType _selectedType;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: 'New Diagram');
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Diagram'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Diagram Name'),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<SysmlDiagramType>(
            value: _selectedType,
            decoration: const InputDecoration(labelText: 'Diagram Type'),
            items: SysmlDiagramType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_formatDiagramType(type)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedType = val);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'name': _controller.text,
              'type': _selectedType,
            });
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  String _formatDiagramType(SysmlDiagramType type) {
    switch (type) {
      case SysmlDiagramType.blockDefinitionDiagram: return 'Block Definition (BDD)';
      case SysmlDiagramType.internalBlockDiagram: return 'Internal Block (IBD)';
      case SysmlDiagramType.useCaseDiagram: return 'Use Case';
      case SysmlDiagramType.sequenceDiagram: return 'Sequence';
      case SysmlDiagramType.stateMachineDiagram: return 'State Machine';
      case SysmlDiagramType.activityDiagram: return 'Activity';
      case SysmlDiagramType.requirementDiagram: return 'Requirement';
      case SysmlDiagramType.parametricDiagram: return 'Parametric';
    }
  }
}
