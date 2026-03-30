import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class PropertyInspector extends StatefulWidget {
  const PropertyInspector({super.key});

  @override
  State<PropertyInspector> createState() => _PropertyInspectorState();
}

class _PropertyInspectorState extends State<PropertyInspector> {
  final TextEditingController _labelController = TextEditingController();
  String? _currentlyEditingId;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final selectedElementId = appState.selectedElementId;
    final selectedConnectionId = appState.selectedConnectionId;

    if (selectedElementId == null && selectedConnectionId == null) {
      return const Center(
        child: Text(
          'Select an item to view properties',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (selectedElementId != null) {
      final element = appState.currentTab.elements
          .firstWhere((e) => e.id == selectedElementId);
      
      if (_currentlyEditingId != selectedElementId) {
        _labelController.text = element.label;
        _currentlyEditingId = selectedElementId;
      }

      return _buildInspectorLayout(
        title: 'Element Properties',
        type: element.type.name.toUpperCase(),
        children: [
          _buildTextField(
            label: 'Name',
            controller: _labelController,
            onChanged: (val) => appState.updateElementLabel(element.id, val),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('ID', element.id),
          _buildInfoRow('Position', '(${element.x.toInt()}, ${element.y.toInt()})'),
        ],
      );
    }

    if (selectedConnectionId != null) {
      final connection = appState.currentTab.connections
          .firstWhere((c) => c.id == selectedConnectionId);

      if (_currentlyEditingId != selectedConnectionId) {
        _labelController.text = connection.label;
        _currentlyEditingId = selectedConnectionId;
      }

      return _buildInspectorLayout(
        title: 'Relationship Properties',
        type: connection.type.name.toUpperCase(),
        children: [
          _buildTextField(
            label: 'Label',
            controller: _labelController,
            onChanged: (val) => appState.updateConnectionLabel(connection.id, val),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('ID', connection.id),
          _buildInfoRow('Source', connection.sourceElementId),
          _buildInfoRow('Target', connection.targetElementId),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInspectorLayout({
    required String title,
    required String type,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              type,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 32),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
