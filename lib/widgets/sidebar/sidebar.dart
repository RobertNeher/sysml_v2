import 'package:flutter/material.dart';
import 'widget_palette.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Toolbox',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(),
          const Expanded(
            child: WidgetPalette(),
          ),
        ],
      ),
    );
  }
}
