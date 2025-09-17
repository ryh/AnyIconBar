import AppKit

class IconManager {
    static func createImage(for symbol: ColoredSymbol) -> NSImage? {
        print("Creating image for symbol: \(symbol.name) with color: \(symbol.color)")
        guard let image = NSImage(systemSymbolName: symbol.name, accessibilityDescription: nil) else {
            print("Failed to create image for symbol: \(symbol.name)")
            return nil
        }
        image.isTemplate = false
        let tintedImage = image.tinted(with: symbol.color)
        print("Successfully created image for symbol: \(symbol.name)")
        return tintedImage
    }

    static func loadCustomImage(named name: String) -> NSImage? {
        // Try bundled images first
        if let bundledImage = NSImage(named: name) {
            return bundledImage
        }

        // Try custom directory ~/.AnyIconBar
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let customDir = homeDir.appendingPathComponent(".AnyIconBar")

        let imagePath = customDir.appendingPathComponent("\(name).png")
        if FileManager.default.fileExists(atPath: imagePath.path),
           let nsImage = NSImage(contentsOf: imagePath) {
            return nsImage
        }

        let retinaImagePath = customDir.appendingPathComponent("\(name)@2x.png")
        if FileManager.default.fileExists(atPath: retinaImagePath.path),
           let nsImage = NSImage(contentsOf: retinaImagePath) {
            return nsImage
        }

        return nil
    }

    static func createCompositeImage(for symbols: [ColoredSymbol], size: NSSize) -> NSImage? {
        let symbolImages = symbols.compactMap { symbol -> NSImage? in
            guard let image = NSImage(systemSymbolName: symbol.name, accessibilityDescription: nil) else { return nil }
            image.isTemplate = false
            return image.tinted(with: symbol.color) ?? image
        }

        if symbolImages.isEmpty {
            return NSImage(systemSymbolName: "questionmark.circle.fill", accessibilityDescription: nil)
        }

        // Calculate total width for side-by-side display
        let totalWidth = size.width * CGFloat(symbolImages.count)
        let compositeSize = NSSize(width: totalWidth, height: size.height)
        let compositeImage = NSImage(size: compositeSize)

        compositeImage.lockFocus()

        for (index, symbolImage) in symbolImages.enumerated() {
            let x = size.width * CGFloat(index)
            let rect = NSRect(x: x, y: 0, width: size.width, height: size.height)
            symbolImage.draw(in: rect)
        }

        compositeImage.unlockFocus()
        return compositeImage
    }
}