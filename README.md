# Multiverse of Madness 🌌

A Conway's Game of Life implementation in Flutter, demonstrating **multi-window support** across different approaches.

![Flutter](https://img.shields.io/badge/Flutter-Desktop-blue)

## What is this?

This repo accompanies a talk on Flutter's multi-window capabilities. It showcases the same Game of Life simulation ("Multiverse") using three different UI approaches:

| Branch | Approach | Description |
|--------|----------|-------------|
| `main` | **Tabs** | Multiple universes in a single window using tabs |
| `talk-old` | **desktop_multi_window** | Separate OS windows using the community [desktop_multi_window](https://pub.dev/packages/desktop_multi_window) package |
| `talk-new` | **Native Flutter Multi-Window** | Separate OS windows using Flutter's built-in `RegularWindow` API |

## Branches

### `main` - Tabbed Multiverse

The baseline implementation. Spawn multiple Game of Life universes as tabs within a single window.

```bash
git checkout main
flutter run -d macos
```

### `talk-old` - Community Package Approach

Uses `desktop_multi_window` package to spawn actual OS-level windows. Each window runs in a separate Flutter engine.

```bash
git checkout talk-old
flutter run -d macos
```

**Key concepts:**
- `WindowController.create()` to spawn new windows
- `setWindowMethodHandler` for inter-window communication
- Each window is a separate engine with its own `main()`

### `talk-new` - Native Flutter Multi-Window

Uses Flutter's new built-in multi-window APIs (`RegularWindow`, `RegularWindowController`, `ViewAnchor`). Windows share the same Flutter engine.

```bash
git checkout talk-new
flutter run -d macos
```

**Key concepts:**
- `runWidget()` instead of `runApp()`
- `RegularWindowController` for window management
- `ViewAnchor` to attach windows to the widget tree
- Shared state across windows (same engine)

## Running the Demo

```bash
# Clone and run
git clone <repo-url>
cd gol_multi_window

# Try each branch
git checkout main && flutter run -d macos
git checkout talk-old && flutter run -d macos
git checkout talk-new && flutter run -d macos
```

## Features

- Conway's Game of Life with famous patterns (Gliders, Pulsars, R-pentomino, etc.)
- Interactive drawing on the grid
- Adjustable simulation speed ("Chaos Velocity")
- Spawn multiple universes
- Pause/resume simulation
- Reset with random patterns

## Requirements

- Flutter SDK (3.11+ for `talk-new` branch)
- macOS (or other desktop platform)
