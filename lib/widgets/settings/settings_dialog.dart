import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../../models/settings.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late double _globalGridSize;
  late bool _globalShowGrid;
  late bool _globalSnapToGrid;

  double? _tabGridSize;
  bool? _tabShowGrid;
  bool? _tabSnapToGrid;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    final global = appState.project.settings;
    final tab = appState.currentTab.settings;

    _globalGridSize = global.gridSize;
    _globalShowGrid = global.showGrid;
    _globalSnapToGrid = global.snapToGrid;

    _tabGridSize = tab?.gridSize;
    _tabShowGrid = tab?.showGrid;
    _tabSnapToGrid = tab?.snapToGrid;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AlertDialog(
        title: const Text('Settings'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Global'),
                  Tab(text: 'Current Diagram'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildGlobalSettings(),
                    _buildDiagramSettings(),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _saveSettings,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalSettings() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Grid Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildGridSizeField(
          value: _globalGridSize,
          onChanged: (val) => setState(() => _globalGridSize = val),
        ),
        SwitchListTile(
          title: const Text('Show Grid'),
          value: _globalShowGrid,
          onChanged: (val) => setState(() => _globalShowGrid = val),
        ),
        SwitchListTile(
          title: const Text('Snap to Grid'),
          value: _globalSnapToGrid,
          onChanged: (val) => setState(() => _globalSnapToGrid = val),
        ),
      ],
    );
  }

  Widget _buildDiagramSettings() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Override Global Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildOverrideField(
          label: 'Grid Size',
          value: _tabGridSize,
          onToggle: (enable) {
            setState(() => _tabGridSize = enable ? _globalGridSize : null);
          },
          child: _buildGridSizeField(
            value: _tabGridSize ?? _globalGridSize,
            enabled: _tabGridSize != null,
            onChanged: (val) => setState(() => _tabGridSize = val),
          ),
        ),
        _buildOverrideField(
          label: 'Show Grid',
          value: _tabShowGrid,
          onToggle: (enable) {
            setState(() => _tabShowGrid = enable ? _globalShowGrid : null);
          },
          child: SwitchListTile(
            title: const Text('Show Grid'),
            contentPadding: EdgeInsets.zero,
            value: _tabShowGrid ?? _globalShowGrid,
            onChanged: _tabShowGrid == null 
              ? null 
              : (val) => setState(() => _tabShowGrid = val),
          ),
        ),
      ],
    );
  }

  Widget _buildGridSizeField({
    required double value,
    required ValueChanged<double> onChanged,
    bool enabled = true,
  }) {
    return Row(
      children: [
        const Text('Grid Size: '),
        Expanded(
          child: Slider(
            min: 5,
            max: 50,
            divisions: 9,
            label: value.round().toString(),
            value: value,
            onChanged: enabled ? onChanged : null,
          ),
        ),
        Text(value.round().toString()),
      ],
    );
  }

  Widget _buildOverrideField({
    required String label,
    required dynamic value,
    required ValueChanged<bool> onToggle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: value != null,
              onChanged: (val) => onToggle(val ?? false),
            ),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: child,
        ),
      ],
    );
  }

  void _saveSettings() {
    final appState = context.read<AppState>();
    
    appState.updateGlobalSettings(ProjectSettings(
      gridSize: _globalGridSize,
      showGrid: _globalShowGrid,
      snapToGrid: _globalSnapToGrid,
    ));

    appState.updateTabSettings(
      appState.currentTabIndex,
      DiagramSettings(
        gridSize: _tabGridSize,
        showGrid: _tabShowGrid,
        snapToGrid: _tabSnapToGrid,
      ),
    );

    Navigator.of(context).pop();
  }
}
