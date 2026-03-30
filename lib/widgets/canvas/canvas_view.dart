import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../state/app_state.dart';
import '../../state/canvas_state.dart';
import '../../models/sysml_types.dart';
import '../../models/sysml_element.dart';
import '../sysml_elements/block_widget.dart';
import 'canvas_painter.dart';

class CanvasView extends StatefulWidget {
  const CanvasView({super.key});

  @override
  State<CanvasView> createState() => _CanvasViewState();
}

class _CanvasViewState extends State<CanvasView> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformationChanged() {
    // Re-render when transformation changes to keep grid in sync
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return ChangeNotifierProvider(
      create: (_) => CanvasState(),
      child: Consumer<CanvasState>(
        builder: (context, canvasState, child) {
          final matrix = _transformationController.value;
          final scale = matrix.getMaxScaleOnAxis();
          final translation = matrix.getTranslation();

          return DragTarget<SysmlElementType>(
            onWillAcceptWithDetails: (details) => true,
            onAcceptWithDetails: (details) {
              // Calculate world coordinates from screen coordinates
              final RenderBox renderBox =
                  context.findRenderObject() as RenderBox;
              final localOffset = renderBox.globalToLocal(details.offset);

              // Apply inverse transform to get canvas coordinates
              final viewportOffset = Offset(translation.x, translation.y);
              final worldX = (localOffset.dx - viewportOffset.dx) / scale;
              final worldY = (localOffset.dy - viewportOffset.dy) / scale;

              final snappedX = canvasState.snap(worldX);
              final snappedY = canvasState.snap(worldY);

              appState.addElement(
                appState.currentTabIndex,
                SysmlElement(
                  id: const Uuid().v4(),
                  type: details.data,
                  x: snappedX,
                  y: snappedY,
                  label: 'New ${details.data.name}',
                ),
              );
            },
            builder: (context, candidateData, rejectedData) {
              return ClipRect(
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  minScale: 0.1,
                  maxScale: 5.0,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: CanvasPainter(
                            zoom: scale,
                            panOffset: Offset(translation.x, translation.y),
                            showGrid: canvasState.showGrid,
                            gridSize: canvasState.gridSize,
                            gridColor: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      _ElementsLayer(
                        elements: appState.currentTab.elements,
                        scale: scale,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ElementsLayer extends StatelessWidget {
  final List<SysmlElement> elements;
  final double scale;

  const _ElementsLayer({required this.elements, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: elements.map((element) {
        return Positioned(
          left: element.x,
          top: element.y,
          child: BlockWidget(
            element: element,
            isSelected: false,
          ),
        );
      }).toList(),
    );
  }
}
