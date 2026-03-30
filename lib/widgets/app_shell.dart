import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'sidebar/sidebar.dart';
import 'canvas/canvas_view.dart';
import 'settings/settings_dialog.dart';

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
            onPressed: () {
              // TODO: Implement save
            },
            tooltip: 'Save Project (Ctrl+S)',
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: () {
              // TODO: Implement open
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
                  onDoubleTap: () {
                    // TODO: Show rename dialog
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
                            onTap: () => appState.removeTab(index),
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
            onPressed: () {
              // TODO: Show new tab dialog
              appState.addTab('New Model', appState.currentTab.diagramType);
            },
            tooltip: 'New Tab (Ctrl+N)',
          ),
        ],
      ),
    );
  }
}
