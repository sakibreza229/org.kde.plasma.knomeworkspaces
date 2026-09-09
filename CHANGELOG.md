# Changelog

All notable changes to the **Knome Workspace Switcher** project will be documented in this file.

## [1.0] - 2024-05-22
### Added
- **Core Logic**: Full implementation of virtual desktop switching using `TaskManager.VirtualDesktopInfo`.
- **Customization**: Added configuration interface for dot sizes, active width/height, and spacing.
- **Hex Color Support**: Users can now input custom Hex codes or color names for active/inactive dots.
- **Animations**: Smooth `NumberAnimation` and `ColorAnimation` transitions between desktop states.
- **Mouse Interaction**: 
    - Click to switch desktop.
    - Mouse wheel scrolling with optional wrap-around logic.
- **Context Menu**: Added actions to add/remove virtual desktops and open System Settings.
- **Packaging**: Standard Plasma 6 directory structure with `metadata.json` in root.
- **Developer Tools**: Included `install.sh` for easy local deployment.

---

## [2.0] - 2026-09-10
### Changed
- **Renamed**: Widget renamed from **Spatium** to **Knome Workspace Switcher** (`org.kde.plasma.spatium` → `org.kde.plasma.knomeworkspaces`).

### Added
- **KGlobalAccel**: Configurable global keyboard shortcuts for switching to next/previous desktop, set via the widget's configuration dialog.
- **Middle Click**: Middle-click on the widget now runs a configurable shell command.

### Fixed
- **Desktop Management**: Corrected `addDesktop`/`removeDesktop` to use the Plasma 6 `/VirtualDesktopManager` D-Bus API (the old `/KWin` methods were removed in Plasma 6).

---

## [Planned for 3.0]
- **Drag & Drop**: Support moving windows between desktops via the dots.
- **Multi-screen Support**: Improved behavior for multi-monitor setups.