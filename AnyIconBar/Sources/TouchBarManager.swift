import AppKit

class TouchBarManager: NSObject, NSTouchBarProvider, NSTouchBarDelegate {
    private let touchBarIconItem = NSTouchBarItem.Identifier("com.AnyIconBar.touchBarIcon")
    private let touchBarCustomizationId = NSTouchBar.CustomizationIdentifier("com.AnyIconBar.touchBar")

    // Invisible window to host Touch Bar globally
    private var touchBarHostWindow: NSWindow?

    // Control Strip
    private let controlStripItem = NSTouchBarItem.Identifier("com.AnyIconBar.controlStrip")
    private var controlStripTouchBarItem: NSCustomTouchBarItem?

    // NSTouchBarProvider
    var touchBar: NSTouchBar?

    private var currentIcon: IconType = .single(symbol: ColoredSymbol(name: "star.fill", color: .gray))
    private var currentRotationIndex: Int = 0

    init(currentIcon: IconType, currentRotationIndex: Int) {
        self.currentIcon = currentIcon
        self.currentRotationIndex = currentRotationIndex
        super.init()
        setupTouchBar()
    }

    func updateCurrentIcon(_ icon: IconType, rotationIndex: Int) {
        currentIcon = icon
        currentRotationIndex = rotationIndex
        updateTouchBar()
        updateControlStripItem()
    }

    private func setupTouchBar() {
        // Enable Touch Bar customization menu item
        NSApplication.shared.isAutomaticCustomizeTouchBarMenuItemEnabled = true

        // Create invisible window to host Touch Bar globally
        createTouchBarHostWindow()

        // Set the app delegate as the touch bar provider for the application
        NSApplication.shared.touchBar = touchBar

        // Observe key window changes to ensure Touch Bar is set on new windows
        NSApplication.shared.addObserver(self, forKeyPath: "keyWindow", options: [.new], context: nil)

        // Control Strip setup
        setupControlStripPresence()
    }

    private func createTouchBarHostWindow() {
        // Create a minimal invisible window to host the Touch Bar
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1, height: 1),
                              styleMask: .borderless,
                              backing: .buffered,
                              defer: false)

        window.isOpaque = false
        window.backgroundColor = .clear
        window.alphaValue = 0.0
        window.ignoresMouseEvents = true
        window.collectionBehavior = [.canJoinAllSpaces, .transient]
        window.level = .normal

        // Set Touch Bar on the window
        window.touchBar = touchBar

        touchBarHostWindow = window
    }

    private func setupControlStripPresence() {
        DFRSystemModalShowsCloseBoxWhenFrontMost(false)

        controlStripTouchBarItem = NSCustomTouchBarItem(identifier: controlStripItem)
        updateControlStripItem()

        NSTouchBarItem.addSystemTrayItem(controlStripTouchBarItem!)
        updateControlStripPresence()
    }

    private func updateControlStripPresence() {
        let showControlStripItem = touchBarContainsAnyItems()
        DFRElementSetControlStripPresenceForIdentifier(controlStripItem, showControlStripItem)
    }

    private func touchBarContainsAnyItems() -> Bool {
        return true
    }

    func updateControlStripItem() {
        // Remove existing Control Strip item
        if controlStripTouchBarItem != nil {
            NSTouchBarItem.removeSystemTrayItem(controlStripTouchBarItem!)
            controlStripTouchBarItem = nil
        }

        // Create new Control Strip item with updated icon
        controlStripTouchBarItem = NSCustomTouchBarItem(identifier: controlStripItem)

        let button = NSButton()
        button.bezelStyle = .regularSquare
        button.isBordered = false
        button.imagePosition = .imageOnly
        button.target = self
        button.action = #selector(presentTouchBar)

        // Set the current icon on the button
        switch currentIcon {
        case .single(let symbol):
            if let image = IconManager.createImage(for: symbol) {
                button.image = image
            }
        case .multiple(let symbols, let mode):
            switch mode {
            case .single:
                if let firstSymbol = symbols.first, let image = IconManager.createImage(for: firstSymbol) {
                    button.image = image
                }
            case .rotating:
                let symbol = symbols[currentRotationIndex % symbols.count]
                if let image = IconManager.createImage(for: symbol) {
                    button.image = image
                }
            case .sideBySide:
                // Create composite image for side-by-side display in Control Strip
                let symbolImages = symbols.compactMap { symbol -> NSImage? in
                    guard let image = NSImage(systemSymbolName: symbol.name, accessibilityDescription: nil) else { return nil }
                    image.isTemplate = false
                    return image.tinted(with: symbol.color) ?? image
                }

                if symbolImages.isEmpty {
                    button.image = NSImage(systemSymbolName: "questionmark.circle.fill", accessibilityDescription: nil)
                } else {
                    // Create composite image for Control Strip
                    let imageSize = NSSize(width: 16, height: 16) // Smaller size for Control Strip
                    let totalWidth = imageSize.width * CGFloat(symbolImages.count)
                    let compositeSize = NSSize(width: totalWidth, height: imageSize.height)

                    let compositeImage = NSImage(size: compositeSize)
                    compositeImage.lockFocus()

                    for (index, symbolImage) in symbolImages.enumerated() {
                        let x = imageSize.width * CGFloat(index)
                        let rect = NSRect(x: x, y: 0, width: imageSize.width, height: imageSize.height)
                        symbolImage.draw(in: rect)
                    }

                    compositeImage.unlockFocus()
                    button.image = compositeImage
                }
            }
        case .image(let image):
            button.image = image
        }

        controlStripTouchBarItem!.view = button

        // Add the updated item back to the system tray
        NSTouchBarItem.addSystemTrayItem(controlStripTouchBarItem!)
        updateControlStripPresence()
    }

    @objc private func presentTouchBar() {
        if let touchBar = makeTouchBar() {
            NSTouchBar.presentSystemModalTouchBar(touchBar, systemTrayItemIdentifier: controlStripItem)
        }
    }

    // MARK: - NSTouchBarProvider

    func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = touchBarCustomizationId
        touchBar.defaultItemIdentifiers = [touchBarIconItem]
        return touchBar
    }

    // MARK: - NSTouchBarDelegate

    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case touchBarIconItem:
            return createIconTouchBarItem()
        default:
            return nil
        }
    }

    private func createIconTouchBarItem() -> NSTouchBarItem? {
        let customItem = NSCustomTouchBarItem(identifier: touchBarIconItem)

        switch currentIcon {
        case .single(let symbol):
            if let image = IconManager.createImage(for: symbol) {
                let button = NSButton(image: image, target: nil, action: nil)
                button.imagePosition = .imageOnly
                customItem.view = button
            }
        case .multiple(let symbols, let mode):
            let containerView = createMultipleIconsView(symbols: symbols, mode: mode)
            customItem.view = containerView
        case .image(let image):
            let button = NSButton(image: image, target: nil, action: nil)
            button.imagePosition = .imageOnly
            customItem.view = button
        }

        return customItem
    }

    private func createMultipleIconsView(symbols: [ColoredSymbol], mode: DisplayMode) -> NSView {
        let container = NSView()

        switch mode {
        case .single:
            if let firstSymbol = symbols.first, let image = IconManager.createImage(for: firstSymbol) {
                let button = NSButton(image: image, target: nil, action: nil)
                button.imagePosition = .imageOnly
                container.addSubview(button)
                button.frame = NSRect(x: 0, y: 0, width: 30, height: 30)
                container.frame = NSRect(x: 0, y: 0, width: 30, height: 30)
            }
        case .rotating:
            let symbol = symbols[currentRotationIndex % symbols.count]
            if let image = IconManager.createImage(for: symbol) {
                let button = NSButton(image: image, target: nil, action: nil)
                button.imagePosition = .imageOnly
                container.addSubview(button)
                button.frame = NSRect(x: 0, y: 0, width: 30, height: 30)
                container.frame = NSRect(x: 0, y: 0, width: 30, height: 30)
            }
        case .sideBySide:
            let imageSize: CGFloat = 30
            let spacing: CGFloat = 4
            let totalWidth = CGFloat(symbols.count) * imageSize + CGFloat(symbols.count - 1) * spacing

            for (index, symbol) in symbols.enumerated() {
                if let image = IconManager.createImage(for: symbol) {
                    let button = NSButton(image: image, target: nil, action: nil)
                    button.imagePosition = .imageOnly
                    button.bezelStyle = .regularSquare
                    button.isBordered = false
                    container.addSubview(button)

                    let x = CGFloat(index) * (imageSize + spacing)
                    button.frame = NSRect(x: x, y: 0, width: imageSize, height: imageSize)
                }
            }
            container.frame = NSRect(x: 0, y: 0, width: totalWidth, height: imageSize)
        }

        return container
    }

    func updateTouchBar() {
        // Force Touch Bar to update by invalidating and recreating it
        touchBar = makeTouchBar()

        // Update Touch Bar on application
        NSApplication.shared.touchBar = touchBar

        // Update Touch Bar on host window
        touchBarHostWindow?.touchBar = touchBar

        // Ensure host window is positioned off-screen and shown
        if let window = touchBarHostWindow {
            window.setFrameOrigin(NSPoint(x: -1000, y: -1000))
            window.makeKeyAndOrderFront(nil)
            window.orderBack(nil) // Send to back so it's not visible
        }
    }

    // Handle window focus changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "keyWindow" {
            if let window = NSApplication.shared.keyWindow {
                window.touchBar = touchBar
            }
        }
    }

    func cleanup() {
        NSApplication.shared.removeObserver(self, forKeyPath: "keyWindow")
        if controlStripTouchBarItem != nil {
            NSTouchBarItem.removeSystemTrayItem(controlStripTouchBarItem!)
        }
    }
}