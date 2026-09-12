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

### Fixed
- **Desktop Management**: Corrected `addDesktop`/`removeDesktop` to use the Plasma 6 `/VirtualDesktopManager` D-Bus API (the old `/KWin` methods were removed in Plasma 6).

---

## [2.3] - 2026-09-12
### Added
- **Side Margins**: Added configurable horizontal margin (0 to 10px) for the left and right sides in the appearance configuration.
- **Extended Spacing Factor**: Increased maximum spacing factor to `0.9` (from `0.6`) with bidirectional SpinBox binding.
- **Icon Appearance**: New shape mode that displays a symbolic desktop workspace icon for each virtual desktop with active/inactive theme tinting.
- **Desktop Number Appearance**: New shape mode that displays compact `D1`, `D2`, `D3`, … labels, bolded on the active desktop.

### Removed
- **Middle Click**: Completely removed the middle-click command execution feature and configuration.
- **Install Script**: Removed `install.sh` in favor of standard KDE Plasma packaging (`kpackagetool6`).

### Fixed
- **Mouse Click Capture**: Ensured the wheel scroll area does not steal left-click events from desktop indicators.
- **Theme Color Fallbacks**: Added proper Plasma/Kirigami theme color inheritance and fallbacks to prevent dark theme contrast issues.
- **Config Dialog Warnings**: Cleaned up undefined QColor and property alias warnings in the configuration dialog.

---

## [Planned for 3.0]
- **Drag & Drop**: Support moving windows between desktops via the dots.
- **Multi-screen Support**: Improved behavior for multi-monitor setups.