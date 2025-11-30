# Build & Run Instructions

This document describes how to build, test, and run FRICKbits locally.

## Requirements
- macOS with Xcode installed (support in code for iOS 7+; use latest Xcode that supports iOS simulators/targets used)
- CocoaPods
- `xctool` (optional; Makefile uses xctool; Xcode `xcodebuild` also works)

## Setup
1. Install Cocoa dependencies:

```bash
brew install cocoapods
pod install
```

2. Install `xctool` if you want to use the Makefile's test/build commands:

```bash
brew install -v --HEAD xctool
```

3. Open the workspace in Xcode:

```bash
open FRICKbits.xcworkspace
```

## Build
- Open the workspace and press Cmd+B, or:

```bash
make build
```

Note: The `Makefile` uses `xctool`. If you prefer, run Xcode directly using the workspace.

## Run in Simulator
- Run the app from Xcode (choose the Simulator and press Run).
- Alternatively:

```bash
# Choose a simulator (e.g., iPhone 8) and run with xctool
xctool -workspace FRICKbits.xcworkspace -scheme FRICKbits -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 8,OS=latest' build run
```

## Testing
- Unit tests are included in the `FRICKbitsTests` target.
- Run via Xcode's Test navigator or:

```bash
make test
```

## Dataset files
- Default dataset: configured in `FBConstants.h` (`FBLocationCSVFileName` or `FBLocationOverrideDatasetFileName`).
- Test data is in `testdata/`.

## Notes
- Runtime: the app runs entirely on-device with no backend.
- Mapbox setup: MBXMapKit overlay is configured; Mapbox keys may be required in `FBConstants`.
- If you need to switch to an alternative dataset, use `FBLocationOverrideDatasetFileName` or pass the filename to the `FBMapViewController` loader.

---
If you'd like I can add a `scripts/` helper for developers to automate running the app with sample datasets or to run tests in CI.