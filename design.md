# AnyIconBar Multiple Icons with Colors Feature Design

## Overview
Add support for sending symbols with custom colors and displaying multiple symbols with configurable display modes.

## Message Format
New UDP message formats:
- `symbol#color` - Single symbol with color
- `symbol1#color1, symbol2#color2` - Multiple symbols with colors

### Color Formats
- Named colors: `red`, `blue`, `green`, etc.
- Hex colors: `#fff`, `#ffffff`, `#e20808`

### Examples
```bash
echo -n "star.fill#red" | nc -4u -w0 localhost 1738
echo -n "star.fill#fff" | nc -4u -w0 localhost 1738
echo -n "star.fill#red, star.circle.fill#e20808" | nc -4u -w0 localhost 1738
```

## Display Modes
1. **Rotating**: Cycle through icons at configurable intervals
2. **Side-by-side**: Display all icons horizontally in menubar

## Implementation Plan

### 1. Data Structures
```swift
enum DisplayMode {
    case single
    case rotating(interval: TimeInterval)
    case sideBySide
}

struct ColoredSymbol {
    let name: String
    let color: NSColor
}

enum IconType {
    case single(symbol: ColoredSymbol)
    case multiple(symbols: [ColoredSymbol], mode: DisplayMode)
    case image(Image)
}
```

### 2. Color Parsing
- Extend existing color mapping
- Add hex color parsing (#RGB and #RRGGBB)
- Support both 3-digit and 6-digit hex codes

### 3. Message Parsing
- Split by comma for multiple symbols
- Split by # for symbol and color
- Validate symbol names and colors
- Fallback to existing behavior for backward compatibility

### 4. Display Logic
- **Rotating**: Use Timer to cycle through symbols
- **Side-by-side**: Create composite NSImage with symbols arranged horizontally
- Update statusItem.button?.image accordingly

### 5. Settings UI
- Add display mode picker (Single/Rotating/Side-by-side)
- Add rotation interval slider (for rotating mode)
- Show current symbols list

### 6. Backward Compatibility
- Existing single symbols work unchanged
- Legacy color commands work unchanged
- Custom images work unchanged

## Files to Modify
1. `AppDelegate.swift` - Core logic, parsing, display
2. `SettingsView.swift` - UI for display mode settings
3. `test_udp.py` - Add examples for new formats
4. `README.md` - Document new features

## Testing
- Test single symbol with named color
- Test single symbol with hex color
- Test multiple symbols with mixed colors
- Test both display modes
- Test backward compatibility