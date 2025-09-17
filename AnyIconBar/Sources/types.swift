import Foundation

enum IconType {
    case single(symbol: ColoredSymbol)
    case multiple(symbols: [ColoredSymbol], mode: DisplayMode)
    case image(NSImage)
}



enum DisplayMode: Hashable, Equatable {
    case single
    case rotating(interval: TimeInterval)
    case sideBySide
}

struct ColoredSymbol {
    let name: String
    let color: NSColor
}