# FRICKbits Overview

FRICKbits transforms a location dataset into an animated digital artwork by analyzing where a user travels and rendering stylized “bits” and clusters on a minimalist Mapbox map. The app runs completely on-device.

## High-level Flow
1. Dataset input: CSV or JSON (OpenPaths) parsed by `FBDataset` into `FBLocation`s.
2. Grid/Indexing: `FBSparseMapGrid` maps locations into `FBMapGridCell`s; `FBCoordinateQuadTree` is used for clustering/annotations.
3. Connectivity: `FBSparseMapGrid` identifies connections between cells based on consecutive dataset records and simplifies connections (shortcut detection, remove diagonals/inverse connections).
4. Rendering: `FBFrickView` uses `FBRecipeFactory` to produce `FBFrickBitLayer` and `FBJoineryBitLayer` variants to render and animate the joining of cells.
5. Map Controller: `FBMapViewController` orchestrates dataset loading and view updates when zoom and gestures change.

## Key Components
- `FBDataset` — dataset loader and filterer.
- `FBLocation` — represents a single location.
- `FBSparseMapGrid` — sparse grid, cells, and connections.
- `FBMapGridCell` — holds locations, connections, and average coordinate.
- `FBMapGridCellConnection` — a direct connection between two cells.
- `FBCoordinateQuadTree` — quad-tree for clustering.
- `FBFrickView` — converts grid/cell graph to CAShapeLayers and animates them.
- `FBJoineryBitLayer`, `FBFrickBitLayer`, `FBClusterBitLayer` — layers used to draw bits.

## Special Notes
- Grid cell size is pegged in pixels: the cell size is 64 screen pixels at a given zoomScale; see `FBCellSizeForZoomScale()` in `FBSparseMapGrid.m`.
- `FBSparseMapGrid` simplification includes a shortcut hit detection that can be CPU heavy for large distances; there's a performance cutoff in the code.
- Animations are scheduled in `FBFrickView` via `NSOperationQueue` with operations for join node animate-in and for connection bit animations.

---

For details about building, running, and architecture diagrams, see the Build_Instructions.md and Architecture.md files in the same folder.