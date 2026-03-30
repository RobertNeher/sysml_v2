import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../state/app_state.dart';
import '../../state/canvas_state.dart';
import '../../models/sysml_types.dart';
import '../../models/sysml_element.dart';
import '../../models/alignment_types.dart';
import '../sysml_elements/block_widget.dart';
import '../../models/settings.dart';
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

          // Sync settings from AppState to CanvasState
          final diagramSettings = appState.currentTab.settings;
          final projectSettings = appState.project.settings;
          final typeDefaults =
              DiagramSettings.defaultsFor(appState.currentTab.diagramType);

          final effectiveGridSize = diagramSettings?.gridSize ??
              typeDefaults.gridSize ??
              projectSettings.gridSize;
          final effectiveShowGrid = diagramSettings?.showGrid ??
              typeDefaults.showGrid ??
              projectSettings.showGrid;

          canvasState.updateFromSettings(effectiveGridSize, effectiveShowGrid);

          return Focus(
            autofocus: true,
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) return KeyEventResult.ignored;

              final bool isControlPressed =
                  HardwareKeyboard.instance.isControlPressed;

              if (isControlPressed) {
                if (event.logicalKey == LogicalKeyboardKey.keyA) {
                  final ids = appState.currentTab.elements.map((e) => e.id);
                  canvasState.selectAll(ids);
                  return KeyEventResult.handled;
                }
                void showShiftMessage() {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Items were moved to avoid overlap'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }

                if (event.logicalKey == LogicalKeyboardKey.keyL) {
                  final moved = appState.alignSelectedElements(
                      canvasState.selectedIds, AlignmentType.left,
                      gap: canvasState.gridSize);
                  if (moved) showShiftMessage();
                  return KeyEventResult.handled;
                }
                if (event.logicalKey == LogicalKeyboardKey.keyR) {
                  final moved = appState.alignSelectedElements(
                      canvasState.selectedIds, AlignmentType.right,
                      gap: canvasState.gridSize);
                  if (moved) showShiftMessage();
                  return KeyEventResult.handled;
                }
                if (event.logicalKey == LogicalKeyboardKey.keyT) {
                  final moved = appState.alignSelectedElements(
                      canvasState.selectedIds, AlignmentType.top,
                      gap: canvasState.gridSize);
                  if (moved) showShiftMessage();
                  return KeyEventResult.handled;
                }
                if (event.logicalKey == LogicalKeyboardKey.keyB) {
                  final moved = appState.alignSelectedElements(
                      canvasState.selectedIds, AlignmentType.bottom,
                      gap: canvasState.gridSize);
                  if (moved) showShiftMessage();
                  return KeyEventResult.handled;
                }
                if (event.logicalKey == LogicalKeyboardKey.keyZ) {
                  appState.undo();
                  return KeyEventResult.handled;
                }
                if (event.logicalKey == LogicalKeyboardKey.keyY) {
                  appState.redo();
                  return KeyEventResult.handled;
                }
              }

              if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                if (canvasState.selectedIds.isNotEmpty) {
                  appState.nudgeElements(
                      canvasState.selectedIds, const Offset(0, -20));
                }
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                if (canvasState.selectedIds.isNotEmpty) {
                  appState.nudgeElements(
                      canvasState.selectedIds, const Offset(0, 20));
                }
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                if (canvasState.selectedIds.isNotEmpty) {
                  appState.nudgeElements(
                      canvasState.selectedIds, const Offset(-20, 0));
                }
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                if (canvasState.selectedIds.isNotEmpty) {
                  appState.nudgeElements(
                      canvasState.selectedIds, const Offset(20, 0));
                }
                return KeyEventResult.handled;
              }
              if (event.logicalKey == LogicalKeyboardKey.delete ||
                  event.logicalKey == LogicalKeyboardKey.backspace) {
                if (canvasState.selectedIds.isNotEmpty) {
                  appState.removeElements(canvasState.selectedIds);
                  canvasState.clearSelection();
                }
                return KeyEventResult.handled;
              }

              return KeyEventResult.ignored;
            },
            child: DragTarget<SysmlElementType>(
              onWillAcceptWithDetails: (details) => true,
              onAcceptWithDetails: (details) {
                final RenderBox renderBox =
                    context.findRenderObject() as RenderBox;
                final localOffset = renderBox.globalToLocal(details.offset);

                final worldX = (localOffset.dx - translation.x) / scale;
                final worldY = (localOffset.dy - translation.y) / scale;

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
                return Listener(
                  onPointerDown: (event) {
                    final bool isCtrlPressed =
                        HardwareKeyboard.instance.isControlPressed;
                    if (isCtrlPressed) {
                      final worldPos = Offset(
                        (event.localPosition.dx - translation.x) / scale,
                        (event.localPosition.dy - translation.y) / scale,
                      );
                      canvasState.startSelection(worldPos);
                    } else {
                      canvasState.clearSelection();
                    }
                  },
                  onPointerMove: (event) {
                    if (canvasState.selectionStart != null) {
                      final worldPos = Offset(
                        (event.localPosition.dx - translation.x) / scale,
                        (event.localPosition.dy - translation.y) / scale,
                      );
                      canvasState.updateSelectionEnd(worldPos);
                    }
                  },
                  onPointerUp: (event) {
                    if (canvasState.selectionStart != null &&
                        canvasState.selectionEnd != null) {
                      // Perform selection logic
                      final rect = Rect.fromPoints(
                        canvasState.selectionStart!,
                        canvasState.selectionEnd!,
                      );
                      final elements = appState.currentTab.elements;
                      final selectedIds = elements
                          .where((e) => rect.overlaps(
                              Rect.fromLTWH(e.x, e.y, e.width, e.height)))
                          .map((e) => e.id);
                      canvasState.selectAll(selectedIds);
                    }
                    canvasState.clearSelectionBox();
                  },
                  child: ClipRect(
                    child: InteractiveViewer(
                      transformationController: _transformationController,
                      boundaryMargin: const EdgeInsets.all(double.infinity),
                      minScale: 0.1,
                      maxScale: 5.0,
                      // Disable IV handles if Ctrl is pressed to allow selection box
                      panEnabled: !HardwareKeyboard.instance.isControlPressed,
                      scaleEnabled: !HardwareKeyboard.instance.isControlPressed,
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
                                selectionStart: canvasState.selectionStart,
                                selectionEnd: canvasState.selectionEnd,
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
                  ),
                );
              },
            ),
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
    final canvasState = context.watch<CanvasState>();
    final appState = context.read<AppState>();

    return Stack(
      children: elements.map((element) {
        final isSelected = canvasState.isSelected(element.id);
        return Positioned(
          left: element.x,
          top: element.y,
          child: GestureDetector(
            onTapDown: (_) {
              final bool isMulti = HardwareKeyboard.instance.isControlPressed ||
                  HardwareKeyboard.instance.isShiftPressed;
              canvasState.selectElement(element.id, multi: isMulti);
            },
            onPanUpdate: (details) {
              if (isSelected) {
                // Move all selected elements
                final delta = details.delta / scale;
                appState.moveElements(canvasState.selectedIds, delta);
              }
            },
            child: BlockWidget(
              element: element,
              isSelected: isSelected,
            ),
          ),
        );
      }).toList(),
    );
  }
}
