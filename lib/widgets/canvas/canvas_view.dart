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
import '../../utils/file_helper.dart';
import '../dialogs/tab_dialogs.dart';
import '../../utils/routing_utils.dart';
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
                  final ids = appState.currentTab.elements.map((e) => e.id).toSet();
                  canvasState.setSelectedIds(ids);
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
                if (event.logicalKey == LogicalKeyboardKey.escape) {
                  appState.setActiveConnectionType(null);
                  canvasState.clearSelection();
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
                if (event.logicalKey == LogicalKeyboardKey.keyS) {
                  final json = appState.exportProjectJson();
                  FileHelper.saveProject(appState.project.name, json).then((_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Project saved')),
                      );
                    }
                  });
                  return KeyEventResult.handled;
                }
                if (event.logicalKey == LogicalKeyboardKey.keyO) {
                  FileHelper.openProject().then((json) {
                    if (json != null) {
                      appState.importProjectJson(json);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Project loaded')),
                        );
                      }
                    }
                  });
                  return KeyEventResult.handled;
                }
                if (event.logicalKey == LogicalKeyboardKey.keyN) {
                  showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (context) => NewDiagramDialog(
                      initialType: appState.currentTab.diagramType,
                    ),
                  ).then((result) {
                    if (result != null) {
                      appState.addTab(result['name'], result['type']);
                    }
                  });
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
                    
                    final worldPos = Offset(
                      (event.localPosition.dx - translation.x) / scale,
                      (event.localPosition.dy - translation.y) / scale,
                    );

                    // Check for connection hit-test first
                    String? hitConnectionId;
                    for (var conn in appState.currentTab.connections) {
                      final source = appState.currentTab.elements.firstWhere((e) => e.id == conn.sourceElementId);
                      final target = appState.currentTab.elements.firstWhere((e) => e.id == conn.targetElementId);
                      
                      final pathPoints = RoutingUtils.calculateOrthogonalPath(source, target);
                      
                      for (int i = 1; i < pathPoints.length; i++) {
                        final start = pathPoints[i-1];
                        final end = pathPoints[i];
                        
                        // Distance from point to line segment
                        final lineLen = (start - end).distance;
                        if (lineLen == 0) continue;
                        
                        final dist = (worldPos - start).distance + (worldPos - end).distance;
                        if ((dist - lineLen).abs() < 5.0 / scale) {
                          hitConnectionId = conn.id;
                          break;
                        }
                      }
                      if (hitConnectionId != null) break;
                    }

                    if (hitConnectionId != null) {
                      appState.setSelectedConnectionId(hitConnectionId);
                      return;
                    }

                    if (isCtrlPressed) {
                      canvasState.startSelection(worldPos);
                    } else {
                      canvasState.clearSelection();
                      appState.setSelectedElementId(null);
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
                          .map((e) => e.id)
                          .toSet();
                      canvasState.setSelectedIds(selectedIds);
                    }
                    canvasState.clearSelectionBox();
                  },
                  child: MouseRegion(
                    onHover: (event) {
                      final worldX = (event.localPosition.dx - translation.x) / scale;
                      final worldY = (event.localPosition.dy - translation.y) / scale;
                      canvasState.updateMousePosition(Offset(worldX, worldY));
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
                                  elements: appState.currentTab.elements,
                                  connections: appState.currentTab.connections,
                                  connectionSourceId: appState.connectionSourceId,
                                  activeConnectionType: appState.activeConnectionType,
                                  selectedConnectionId: appState.selectedConnectionId,
                                  mousePosition: canvasState.mousePosition,
                                ),
                              ),
                            ),
                            _ElementsLayer(
                              elements: appState.currentTab.elements,
                              scale: scale,
                              connectionSourceId: appState.connectionSourceId,
                            ),
                          ],
                        ),
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
  final String? connectionSourceId;

  const _ElementsLayer({
    required this.elements,
    required this.scale,
    this.connectionSourceId,
  });

  @override
  Widget build(BuildContext context) {
    final canvasState = context.watch<CanvasState>();
    final appState = context.read<AppState>();

    void _handleElementTap(String id) {
      if (appState.activeConnectionType != null) {
        if (appState.connectionSourceId == null) {
          appState.setConnectionSourceId(id);
        } else {
          if (appState.connectionSourceId != id) {
            appState.addConnection(
              appState.connectionSourceId!,
              id,
              appState.activeConnectionType!,
            );
          }
          appState.setActiveConnectionType(null);
        }
        return;
      }

      if (HardwareKeyboard.instance.isShiftPressed) {
        final selected = Set<String>.from(canvasState.selectedIds);
        if (selected.contains(id)) {
          selected.remove(id);
        } else {
          selected.add(id);
        }
        canvasState.setSelectedIds(selected);
      } else {
        canvasState.setSelectedIds({id});
      }
    }

    return Stack(
      children: elements.map((element) {
        final isSelected = canvasState.isSelected(element.id);
        return Positioned(
          left: element.x,
          top: element.y,
          child: GestureDetector(
            onTapDown: (_) {
              _handleElementTap(element.id);
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
              isConnectionSource: connectionSourceId == element.id,
            ),
          ),
        );
      }).toList(),
    );
  }
}
