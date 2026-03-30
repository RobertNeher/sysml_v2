# SysML v2 Modeler

A professional-grade, high-performance modeling tool for **SysML v2**, built with Flutter. This modeler focuses on visual clarity, semantic intelligence, and a fluid user experience.

![SysML v2 Modeler](https://img.shields.io/badge/System-SysML%20v2-blue?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?style=for-the-badge&logo=flutter)

## 🚀 Key Features

### 🎨 Modeling in Colors (Semantic Archetypes)
Integrated **Peter Coad's "Modeling in Colors"** methodology to enhance model readability:
- **Pink (Moment-Interval)**: capturing events and activities.
- **Yellow (Role)**: defining how entities participate.
- **Green (Thing)**: representing physical or logical entities (Blocks).
- **Blue (Description)**: catalog-like data (Requirements, Ports, Constraints).

### 📐 Intelligent Orthogonal Routing
Connections are no longer messy lines. Our router uses **Manhattan-style orthogonal paths**:
- **rounded corners (8px fillets)** for a modern, high-end look.
- **Deterministic 3-segment routing** (Z-shapes) for clean layouts.
- **Directional Arrowheads**: Specialized rendering for Generalization (hollow triangle) and Dependency (dashed line + open arrow).

### 📄 Advanced Requirement Modeling
Specialized support for SysML Requirements:
- **Visual Identity**: Distinct "folded-corner" page shape.
- **Deep Metadata**: Dedicated fields for **Requirement ID**, **Statement**, and **Rationale**, accessible via the Properties Inspector.

### ⚡ Professional Workspace
- **Multi-Tab Interface**: Organize your models into multiple diagrams within a single project.
- **Smart Palette**: Drag-and-drop elements with real-time feedback.
- **Undo/Redo & History**: Full transactional history for every action.
- **Infinite Canvas**: Support for high-performance panning, zooming, and grid-snapping.
- **Local Persistence**: Save and load your projects as standardized JSON files.

---

## 🛠️ Tech Stack
- **Flutter**: Cross-platform UI framework for high-fidelity graphics.
- **Provider**: Clean and predictable reactive state management.
- **Custom Painters**: Low-level canvas rendering for pixel-perfect orthogonal paths and custom shapes.
- **JSON Serializable**: Robust project data modeling and serialization.

---

## 🏁 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel recommended)
- Dart SDK

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-repo/sysml-v2-modeler.git
   ```
2. Navigate to the project directory:
   ```bash
   cd sysml_v2
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

---

## 📅 Roadmap (Completed Phases)
- [x] **Phase 1-4**: Basic Element & Connection logic.
- [x] **Phase 5**: Canvas View & Transformation (Zooming/Panning).
- [x] **Phase 6**: Property Inspector & Labels.
- [x] **Phase 7**: Relationship Types (Generalization, Dependency).
- [x] **Phase 8**: Persistence & JSON Export.
- [x] **Phase 9**: Enhanced Connectivity (Orthogonal Routing).
- [x] **Phase 10**: Requirements, Ports & Modeling in Colors.
- [ ] **Phase 11-12**: Auto-Alignment & Advanced Layout Algorithms.

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.