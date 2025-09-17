# AnyIconBar: Modern macOS Menubar Status Indicator

AnyIconBar is a modern, SwiftUI-based menubar status indicator for macOS that displays SF Symbols or custom images. It's a complete rewrite of the classic AnyBar application with enhanced features and modern macOS integration.

## Features

- **SF Symbols Support**: Display any SF Symbol from Apple's extensive symbol library
- **Color Customization**: Customize symbol colors through the settings interface
- **Touch Bar Integration**: Display icons in macOS Touch Bar when available
- **Legacy Compatibility**: Maintains backward compatibility with original AnyBar color commands
- **Custom Images**: Support for custom images stored in `~/.AnyIconBar` directory
- **UDP Control**: Remote control via UDP messages (default port 1738)
- **Multiple Instances**: Run multiple instances on different ports
- **Modern UI**: Built with SwiftUI and Swift 6.0
- **Symbol Picker**: Integrated SF Symbol picker for easy symbol selection

## Installation

### Building from Source

1. Clone the repository:
```bash
git clone https://github.com/ryh/AnyIconBar.git
cd AnyIconBar
```

2. Install Tuist (if not already installed):
```bash
brew install tuist
```

3. Generate and build the project:
```bash
tuist generate
tuist build
```

4. Run the application:
```bash
open AnyIconBar.xcworkspace
```

## Usage

### Launching AnyIconBar

```bash
open -a AnyIconBar
```

### UDP Control

AnyIconBar listens for UDP messages on port 1738 (configurable). Send messages to change the displayed icon:

```bash
# Using netcat
echo -n "star.fill" | nc -4u -w0 localhost 1738

# Using Python script
python test_udp.py star.fill

# Using bash
echo -n "star.fill" > /dev/udp/localhost/1738
```

### Supported Commands

#### SF Symbols
Send any valid SF Symbol name:
```bash
echo -n "heart.fill" | nc -4u -w0 localhost 1738
echo -n "checkmark.circle" | nc -4u -w0 localhost 1738
echo -n "exclamationmark.triangle" | nc -4u -w0 localhost 1738
```

#### SF Symbols with Custom Colors
Send symbols with custom colors using the format `symbol#color`:
```bash
# Named colors
echo -n "star.fill#red" | nc -4u -w0 localhost 1738
echo -n "heart.fill#blue" | nc -4u -w0 localhost 1738

# Hex colors (3-digit)
echo -n "star.fill#fff" | nc -4u -w0 localhost 1738
echo -n "star.fill#f00" | nc -4u -w0 localhost 1738

# Hex colors (6-digit)
echo -n "star.fill#ffffff" | nc -4u -w0 localhost 1738
echo -n "star.fill#e20808" | nc -4u -w0 localhost 1738
```

#### Multiple Symbols
Send multiple symbols separated by commas. Display mode can be configured in settings:
```bash
echo -n "star.fill#red, star.circle.fill#e20808" | nc -4u -w0 localhost 1738
echo -n "checkmark.circle#green, xmark.circle#red" | nc -4u -w0 localhost 1738
```

#### Legacy Color Commands (Mapped to SF Symbols)
| Command       | SF Symbol Equivalent                          | Description |
|---------------|-----------------------------------------------|-------------|
| `white`       | `smallcircle.filled.circle` (white)          | White circle |
| `red`         | `smallcircle.filled.circle.fill` (red)       | Red filled circle |
| `orange`      | `smallcircle.filled.circle.fill` (orange)    | Orange filled circle |
| `yellow`      | `smallcircle.filled.circle.fill` (yellow)    | Yellow filled circle |
| `green`       | `smallcircle.filled.circle.fill` (green)     | Green filled circle |
| `cyan`        | `smallcircle.filled.circle.fill` (cyan)      | Cyan filled circle |
| `blue`        | `smallcircle.filled.circle.fill` (blue)      | Blue filled circle |
| `purple`      | `smallcircle.filled.circle.fill` (purple)    | Purple filled circle |
| `black`       | `smallcircle.filled.circle.fill` (black)     | Black filled circle |
| `hollow`      | `circle` (gray)                              | Hollow circle |
| `filled`      | `smallcircle.filled.circle.fill` (gray)      | Filled circle |
| `exclamation` | `exclamationmark.circle.fill` (red)          | Exclamation mark |
| `question`    | `questionmark.circle.fill` (blue)            | Question mark |

#### Special Commands
- `quit` - Terminate the application

### Custom Images

AnyIconBar supports custom images stored in `~/.AnyIconBar/` directory:

```bash
mkdir -p ~/.AnyIconBar
# Copy your 19x19 (or 38x38 @2x) pixel images here
cp myicon.png ~/.AnyIconBar/
echo -n "myicon" | nc -4u -w0 localhost 1738
```

## Configuration

### Environment Variables

- `ANYBAR_PORT`: UDP port to listen on (default: 1738)
- `ANYBAR_INIT`: Initial icon to display on startup

### Examples

```bash
# Run on custom port
ANYBAR_PORT=1739 open -a AnyIconBar

# Start with specific icon
ANYBAR_INIT=green open -a AnyIconBar

# Multiple instances
ANYBAR_PORT=1738 open -na AnyIconBar
ANYBAR_PORT=1739 open -na AnyIconBar
```

## Client Libraries

AnyIconBar is compatible with existing AnyBar client libraries. Here are some examples:

### Bash Function
```bash
function anyiconbar { echo -n $1 | nc -4u -w0 localhost ${2:-1738}; }

# Usage
anyiconbar star.fill
anyiconbar red 1739
```

### Python
```python
import socket

def send_to_anyiconbar(message, port=1738):
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.sendto(message.encode('utf-8'), ('127.0.0.1', port))
    sock.close()

# Usage
send_to_anyiconbar('heart.fill')
send_to_anyiconbar('green')
```

### Node.js
```javascript
const dgram = require('dgram');

function sendToAnyIconBar(message, port = 1738) {
    const client = dgram.createSocket('udp4');
    client.send(message, port, '127.0.0.1', (err) => {
        client.close();
    });
}

// Usage
sendToAnyIconBar('checkmark.circle.fill');
```

## Settings

Access settings by:
1. Clicking the menubar icon
2. Selecting "Settings" from the dropdown menu
3. Or using `Cmd + ,` keyboard shortcut

### Settings Options
- **Current Icon**: View the currently displayed icon
- **SF Symbol Settings**: Change symbol color
- **Symbol Picker**: Browse and select SF Symbols
- **Display Mode**: Configure how multiple symbols are displayed
  - **Single**: Show first symbol only
  - **Rotating**: Cycle through symbols at configurable intervals
  - **Side-by-side**: Display all symbols horizontally in the menubar
- **Network Settings**: View connection status and port information

## Development

### Requirements
- macOS 13.0+
- Xcode 15.0+
- Swift 6.0
- Tuist

### Project Structure
```
AnyIconBar/
├── Project.swift              # Tuist project configuration
├── Tuist/
│   └── Package.swift          # Swift Package dependencies
├── AnyIconBar/
│   └── Sources/
│       ├── AnyIconBarApp.swift    # Main app entry point
│       ├── AppDelegate.swift      # App coordination (refactored)
│       ├── SettingsView.swift     # Settings interface
│       ├── MenuBarManager.swift   # Menu bar functionality
│       ├── TouchBarManager.swift  # Touch Bar & Control Strip
│       ├── UDPManager.swift       # UDP communication
│       ├── IconManager.swift      # Icon creation & management
│       ├── ColorUtilities.swift   # Color parsing utilities
│       ├── StringExtensions.swift # String processing utilities
│       ├── NSImageExtensions.swift # Image utilities
│       └── SymbolPicker/          # SF Symbol picker library
└── test_udp.py                # UDP testing script
```

### Building

```bash
# Generate project files
tuist generate

# Build
tuist build

# Run tests
tuist test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

Copyright © 2025 ryh
Copyright © 2015 Nikita Prokopov

Licensed under Eclipse Public License (see LICENSE).

## Acknowledgments

- **Original AnyBar**: Based on [AnyBar](https://github.com/tonsky/AnyBar/) by Nikita Prokopov
- **Touch Bar**: Implementation copied from [MTMR](https://github.com/Toxblh/MTMR) (Licensed under MIT)
  - `CBridge/` directory (Touch Bar private APIs)
  - `SupportNSTouchBar.swift` (Touch Bar management)
- **SymbolPicker Library**: SF Symbol picker integration
- **Apple**: SF Symbols and macOS frameworks