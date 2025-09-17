import AppKit

class ColorUtilities {
    /// Parse color from string (supports hex colors with/without #, named colors)
    static func parseColor(_ colorString: String) -> NSColor? {
        // Handle hex colors (with # prefix)
        if colorString.hasPrefix("#") {
            // Extract just the hex part before any additional #
            let hexPart = String(colorString.split(separator: "#", maxSplits: 1)[0])
            return hexPart.parseHexColor()
        }

        // Check if it looks like a hex color (3 or 6 hex digits), possibly with extra characters
        let hexChars = CharacterSet(charactersIn: "0123456789abcdefABCDEF")
        if let hexRange = colorString.rangeOfCharacter(from: hexChars),
           hexRange.lowerBound == colorString.startIndex {
            // Extract the hex part from the beginning
            let hexPart = String(colorString.prefix { hexChars.contains($0.unicodeScalars.first!) })
            if hexPart.count == 3 || hexPart.count == 6 {
                return hexPart.parseHexColor()
            }
        }

        // Handle named colors
        return colorString.parseNamedColor()
    }

    /// Parse symbol string in format "symbol#color" or just "symbol"
    static func parseSymbolString(_ symbolString: String) -> ColoredSymbol? {
        print("Parsing symbol string: '\(symbolString)'")

        // Check if it's symbol#color format
        if symbolString.contains("#") {
            let parts = symbolString.split(separator: "#", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
            if parts.count == 2 {
                let symbolName = parts[0]
                let colorString = parts[1]

                print("Symbol: '\(symbolName)', Color: '\(colorString)'")

                // Validate symbol exists
                if NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) != nil {
                    if let color = parseColor(colorString) {
                        print("Successfully parsed: \(symbolName) with color \(color)")
                        return ColoredSymbol(name: symbolName, color: color)
                    } else {
                        print("Failed to parse color: \(colorString)")
                    }
                } else {
                    print("Symbol not found: \(symbolName)")
                }
            }
            return nil
        }

        // Check if it's a valid SF Symbol (no color specified)
        if NSImage(systemSymbolName: symbolString, accessibilityDescription: nil) != nil {
            print("Found valid SF Symbol: \(symbolString)")
            return ColoredSymbol(name: symbolString, color: .controlAccentColor)
        }

        print("Symbol not recognized as SF Symbol: \(symbolString)")

        // Handle legacy color names
        switch symbolString {
        case "white":
            return ColoredSymbol(name: "smallcircle.filled.circle", color: .white)
        case "red":
            return ColoredSymbol(name: "smallcircle.filled.circle.fill", color: .red)
        case "orange":
            return ColoredSymbol(name: "smallcircle.filled.circle.fill", color: .orange)
        case "yellow":
            return ColoredSymbol(name: "smallcircle.filled.circle.fill", color: .yellow)
        case "green":
            return ColoredSymbol(name: "smallcircle.filled.circle.fill", color: .green)
        case "cyan":
            return ColoredSymbol(name: "smallcircle.filled.circle.fill", color: .cyan)
        case "blue":
            return ColoredSymbol(name: "smallcircle.filled.circle.fill", color: .blue)
        case "purple":
            return ColoredSymbol(name: "smallcircle.filled.circle.fill", color: .purple)
        case "black":
            return ColoredSymbol(name: "smallcircle.filled.circle.fill", color: .black)
        case "hollow":
            return ColoredSymbol(name: "circle", color: .gray)
        case "filled":
            return ColoredSymbol(name: "smallcircle.filled.circle.fill", color: .gray)
        case "exclamation":
            return ColoredSymbol(name: "exclamationmark.circle.fill", color: .red)
        case "question":
            return ColoredSymbol(name: "questionmark.circle.fill", color: .blue)
        default:
            print("No match found for: \(symbolString), using fallback")
            return ColoredSymbol(name: "circle", color: .red)
        }
    }
}