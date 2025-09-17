import Testing
@testable import AnyIconBar
import AppKit

struct ColorUtilitiesTests {

    // MARK: - parseColor Tests

    @Test func testParseColor_withHexWithPrefix() {
        // Test 6-digit hex with #
        let color = ColorUtilities.parseColor("#ff0000")
        #expect(color != nil)
        #expect(color?.redComponent == 1.0)
        #expect(color?.greenComponent == 0.0)
        #expect(color?.blueComponent == 0.0)
    }

    @Test func testParseColor_withHexWithoutPrefix() {
        // Test 6-digit hex without #
        let color = ColorUtilities.parseColor("00ff00")
        #expect(color != nil)
        #expect(color?.redComponent == 0.0)
        #expect(color?.greenComponent == 1.0)
        #expect(color?.blueComponent == 0.0)
    }

    @Test func testParseColor_with3DigitHex() {
        // Test 3-digit hex
        let color = ColorUtilities.parseColor("f00")
        #expect(color != nil)
        #expect(color?.redComponent == 1.0)
        #expect(color?.greenComponent == 0.0)
        #expect(color?.blueComponent == 0.0)
    }

    @Test func testParseColor_withNamedColor() {
        let color = ColorUtilities.parseColor("red")
        #expect(color != nil)
        #expect(color == .red)
    }

    @Test func testParseColor_withInvalidHex() {
        // Test invalid hex (wrong length)
        let color = ColorUtilities.parseColor("ff00")
        #expect(color == nil)
    }

    @Test func testParseColor_withInvalidNamedColor() {
        let color = ColorUtilities.parseColor("invalidcolor")
        #expect(color == nil)
    }

    @Test func testParseColor_withNonHexString() {
        // Test string that contains non-hex characters
        let color = ColorUtilities.parseColor("gggggg")
        #expect(color == nil)
    }

    // MARK: - parseSymbolString Tests

    @Test func testParseSymbolString_withSymbolAndHexColor() {
        let result = ColorUtilities.parseSymbolString("star.fill#ff0000")
        #expect(result != nil)
        #expect(result?.name == "star.fill")
        #expect(result?.color.redComponent == 1.0)
        #expect(result?.color.greenComponent == 0.0)
        #expect(result?.color.blueComponent == 0.0)
    }

    @Test func testParseSymbolString_withSymbolAndNamedColor() {
        let result = ColorUtilities.parseSymbolString("heart.fill#blue")
        #expect(result != nil)
        #expect(result?.name == "heart.fill")
        #expect(result?.color == .blue)
    }

    @Test func testParseSymbolString_withSymbolOnly() {
        let result = ColorUtilities.parseSymbolString("checkmark.circle")
        #expect(result != nil)
        #expect(result?.name == "checkmark.circle")
        #expect(result?.color == .controlAccentColor)
    }

    @Test func testParseSymbolString_withLegacyColor() {
        let result = ColorUtilities.parseSymbolString("red")
        #expect(result != nil)
        #expect(result?.name == "smallcircle.filled.circle.fill")
        #expect(result?.color == .red)
    }

    @Test func testParseSymbolString_withInvalidSymbol() {
        let result = ColorUtilities.parseSymbolString("nonexistent.symbol#ff0000")
        #expect(result == nil)
    }

    @Test func testParseSymbolString_withInvalidColor() {
        let result = ColorUtilities.parseSymbolString("star.fill#invalidcolor")
        #expect(result == nil)
    }

    @Test func testParseSymbolString_withEmptyString() {
        let result = ColorUtilities.parseSymbolString("")
        // Empty string falls back to legacy color handling and returns red circle
        #expect(result != nil)
        #expect(result?.name == "circle")
        #expect(result?.color == .red)
    }

    @Test func testParseSymbolString_withMultipleHashes() {
        let result = ColorUtilities.parseSymbolString("star.fill#ff0000#extra")
        #expect(result != nil)
        #expect(result?.name == "star.fill")
        #expect(result?.color.redComponent == 1.0)
    }

    @Test func testParseSymbolString_withMultipleHashes2() {
        let result = ColorUtilities.parseSymbolString("star.fill##ff0000#extra")
        #expect(result != nil)
        #expect(result?.name == "star.fill")
        #expect(result?.color.redComponent == 1.0)
    }

    @Test func testParseSymbolString_withWhitespace() {
        let result = ColorUtilities.parseSymbolString(" star.fill # ff0000 ")
        #expect(result != nil)
        #expect(result?.name == "star.fill")
        #expect(result?.color.redComponent == 1.0)
    }

    // MARK: - Legacy Color Tests

    @Test func testParseSymbolString_legacyColors() {
        let legacyColors = [
            ("white", "smallcircle.filled.circle", NSColor.white),
            ("red", "smallcircle.filled.circle.fill", NSColor.red),
            ("orange", "smallcircle.filled.circle.fill", NSColor.orange),
            ("yellow", "smallcircle.filled.circle.fill", NSColor.yellow),
            ("green", "smallcircle.filled.circle.fill", NSColor.green),
            ("cyan", "smallcircle.filled.circle.fill", NSColor.cyan),
            ("blue", "smallcircle.filled.circle.fill", NSColor.blue),
            ("purple", "smallcircle.filled.circle.fill", NSColor.purple),
            ("black", "smallcircle.filled.circle.fill", NSColor.black),
            ("hollow", "circle", NSColor.gray),
            ("filled", "smallcircle.filled.circle.fill", NSColor.gray),
            ("exclamation", "exclamationmark.circle.fill", NSColor.red),
            ("question", "questionmark.circle.fill", NSColor.blue)
        ]

        for (input, expectedSymbol, expectedColor) in legacyColors {
            let result = ColorUtilities.parseSymbolString(input)
            #expect(result != nil, "Failed for legacy color: \(input)")
            #expect(result?.name == expectedSymbol, "Wrong symbol for \(input)")
            #expect(result?.color == expectedColor, "Wrong color for \(input)")
        }
    }

    @Test func testParseSymbolString_unknownLegacyColor() {
        let result = ColorUtilities.parseSymbolString("unknowncolor")
        #expect(result != nil)
        #expect(result?.name == "circle")
        #expect(result?.color == .red)
    }
}