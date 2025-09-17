import Foundation

extension String {
    /// Parse hex color from string (supports #RGB, #RRGGBB, RGB, and RRGGBB formats)
    func parseHexColor() -> NSColor? {
        let hex = self.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0

        guard Scanner(string: hex).scanHexInt64(&rgb) else { return nil }

        let r, g, b: CGFloat
        if hex.count == 3 {
            // 3-digit hex (RGB or #RGB)
            r = CGFloat((rgb >> 8) & 0xF) / 15.0
            g = CGFloat((rgb >> 4) & 0xF) / 15.0
            b = CGFloat(rgb & 0xF) / 15.0
        } else if hex.count == 6 {
            // 6-digit hex (RRGGBB or #RRGGBB)
            r = CGFloat((rgb >> 16) & 0xFF) / 255.0
            g = CGFloat((rgb >> 8) & 0xFF) / 255.0
            b = CGFloat(rgb & 0xFF) / 255.0
        } else {
            return nil
        }

        return NSColor(red: r, green: g, blue: b, alpha: 1.0)
    }

    /// Parse named color from string
    func parseNamedColor() -> NSColor? {
        switch self.lowercased() {
        case "white": return .white
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "cyan": return .cyan
        case "blue": return .blue
        case "purple": return .purple
        case "black": return .black
        case "gray": return .gray
        case "controlaccentcolor": return .controlAccentColor
        default: return nil
        }
    }
}