import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'sidebar/sidebar.dart';
import 'canvas/canvas_view.dart';
import 'settings/settings_dialog.dart';
import 'dialogs/tab_dialogs.dart';
import '../utils/file_helper.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _isSidebarVisible = true;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final project = appState.project;

    return Scaffold(
      appBar: AppBar(
        title: Text('${project.name} - SysML v2'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final json = appState.exportProjectJson();
              await FileHelper.saveProject(project.name, json);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Project saved')),
                );
              }
            },
            tooltip: 'Save Project (Ctrl+S)',
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () async {
              final json = await FileHelper.openProject();
              if (json != null) {
                appState.importProjectJson(json);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Project loaded')),
                  );
                }
              }
            },
            tooltip: 'Open Project (Ctrl+O)',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const SettingsDialog(),
              );
            },
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: _buildTabBar(appState),
        ),
      ),
      body: Row(
        children: [
          if (_isSidebarVisible)
            const Sidebar(),
          const VerticalDivider(width: 1),
          Expanded(
            child: Stack(
              children: [
                const CanvasView(),
                Positioned(
                  left: 8,
                  top: 8,
                  child: IconButton(
                    icon: Icon(_isSidebarVisible ? Icons.menu_open : Icons.menu),
                    onPressed: () {
                      setState(() {
                        _isSidebarVisible = !_isSidebarVisible;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(AppState appState) {
    return Container(
      height: 40,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: appState.project.tabs.length,
              itemBuilder: (context, index) {
                final tab = appState.project.tabs[index];
                final isSelected = appState.currentTabIndex == index;

                return GestureDetector(
                  onTap: () => appState.setCurrentTabIndex(index),
                  onDoubleTap: () async {
                    final newName = await showDialog<String>(
                      context: context,
                      builder: (context) => RenameTabDialog(initialName: tab.name),
                    );
                    if (newName != null && newName.isNotEmpty) {
                      appState.updateTabName(index, newName);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.surface
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tab.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (appState.project.tabs.length > 1) ...[
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () async {
                              final tab = appState.project.tabs[index];
                              if (tab.elements.isNotEmpty) {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Tab?'),
                                    content: Text('The tab "${tab.name}" contains elements. Are you sure you want to delete it?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'), style: TextButton.styleFrom(foregroundColor: Colors.red)),
                                    ],
                                  ),
                                );
                                if (confirm != true) return;
                              }
                              appState.removeTab(index);
                            },
                            child: const Icon(Icons.close, size: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: () async {
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) => NewDiagramDialog(
                  initialType: appState.currentTab.diagramType,
                ),
              );
              if (result != null) {
                appState.addTab(result['name'], result['type']);
              }
            },
            tooltip: 'New Tab (Ctrl+N)',
          ),
        ],
      ),
    );
  }
}
