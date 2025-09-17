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
  
    // Label
  var label:String{
    switch self {
    case .single:
      return "single"
    case .rotating:
      return "rotating"
    case .sideBySide:
      return "side-by-side"
    }
  }
    // Description
    var description:String{
      switch self {
      case .single:
          return "Single"
      case .rotating:
          return "Rotating"
      case .sideBySide:
          return "Side by side"
      }
  }
}

struct ColoredSymbol {
    let name: String
    let color: NSColor
}
