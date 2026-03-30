# SysML v2 Modeler

1. # Goal

Building a modeling solution basing upon SysML V2 standard, including a SysML v2 compatible REST API.

2. # Technology to be used

- Flutter web app
- Dart  
- Persistence: a single JSON file per model

  1. ## Features

Let side of User Interface: Hideable selection bar from which SysML widgets may be dragged on to the unlimited canvas.

Canvas has unlimited size and provides a hideable grid which stays steady when widgets are dragged or the viewport is changed.

Canvas provides a snapping depending on grid’s distance.

The canvas provides zoom in and out.

Canvas supports “usual” mouse operations,

- Canvas consists of one or more tabs. Each tab contains a model. Tab’s label (model's name) may be modified anytime
- All tabs are kept under the project’s workspace.
- All tabs are stored in a single JSON file containing the project’s meta data and all tabs’ content.
- The workspace is a directory in the file system. Each folder represents a model (tab's content).
- Ctrl key and left mouse button in canvas draws a square for selection of widgets
- Right mouse button in canvas shows a menu with items of key controls below

but also key control

- Ctrl A: Selection of all widgets in canvas  
- Arrow keys: Moves selected widgets by 20 pixels on canvas (20 pixels jump scales with zoom factor)  
- Ctrl L: Align selected widgets along most left of selected widgets  
- Ctrl R: Align selected widgets along most right of selected widgets  
- Ctrl T: Align selected widgets along most top of selected widgets  
- Ctrl B: Align selected widgets along most bottom of selected widgets  
- Del:  Deletion of selected widgets  
- Backspace: Deletion of selected widgets  
- Ctrl C: Copy selected widgets  
- Ctrl V: Paste copied widgets  
- Ctrl Z: Undo last action (unlimited)  
- Ctrl Y: Redo last action (unlimited)  
- Ctrl S: Save canvas’ (workspace) content to a JSON file (the project). If the file name is not set, user defines the name in a "Save as…” dialogue.
- Ctrl O: Opens a dialogue to select a workspace file from underlying file system  
- Ctrl N: Creates a new tab (model) in canvas:
  - Before user may start modeling, user has to define the model’s nature (SysML diagram type)
  - The nature may be changed as long no model information exists in tab  
  - All tabs are kept under the project’s umbrella  
    - A project may have meta data, like author, creation date, last modification date, description. All formatted by Markdown syntax.

General topic

- The JSON-based persistence may be changed to NoSQL database

  2. ## File operations

