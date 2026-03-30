import 'package:flutter/material.dart';
import '../../models/sysml_element.dart';

class BlockWidget extends StatelessWidget {
  final SysmlElement element;
  final bool isSelected;
  final bool isConnectionSource;

  const BlockWidget({
    super.key,
    required this.element,
    this.isSelected = false,
    this.isConnectionSource = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: element.width,
      height: element.height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: isConnectionSource
              ? Colors.orange
              : (isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline),
          width: (isSelected || isConnectionSource) ? 2.0 : 1.0,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stereotype/Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            child: Column(
              children: [
                Text(
                  '«block»',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
                Text(
                  element.label.isEmpty ? 'New Block' : element.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Compartment
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                'parts\nvalues',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
