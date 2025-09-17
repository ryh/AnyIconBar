import AppKit

extension NSImage {
    func tinted(with color: NSColor) -> NSImage? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }

        let width = cgImage.width
        let height = cgImage.height

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let context = CGContext(data: nil,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: 0,
                                    space: colorSpace,
                                    bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }

        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        context.clip(to: rect, mask: cgImage)

        context.setFillColor(color.cgColor)
        context.fill(rect)

        guard let tintedCGImage = context.makeImage() else {
            return nil
        }

        let tintedImage = NSImage(cgImage: tintedCGImage, size: self.size)
        return tintedImage
    }
}