import AppKit

class MenuBarManager: NSObject {
    private var statusItem: NSStatusItem!
    private var udpPort: Int
    private var appTitle: String?

    // Current state
    private var currentIcon: IconType = .single(symbol: ColoredSymbol(name: "star.fill", color: .gray))
    private var currentRotationIndex: Int = 0

    init(udpPort: Int, appTitle: String?) {
        self.udpPort = udpPort
        self.appTitle = appTitle
        super.init()
        setupStatusBarItem()
    }

    private func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.imagePosition = .imageOnly
        statusItem.button?.action = #selector(statusItemClicked)
        statusItem.button?.target = self

        // Create menu
        let menu = NSMenu()
        menu.addItem(withTitle: "AnyIconBar", action: nil, keyEquivalent: "")

        let portItem = NSMenuItem(title: "UDP Port: \(udpPort)", action: nil, keyEquivalent: "")
        menu.addItem(portItem)

        if let title = appTitle {
            let titleItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            menu.addItem(titleItem)
        }

        menu.addItem(.separator())

        // Use the action approach for NSMenu
        let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func updateCurrentIcon(_ icon: IconType, rotationIndex: Int) {
        currentIcon = icon
        currentRotationIndex = rotationIndex
        updateStatusItem()
    }

    private func updateStatusItem() {
        switch currentIcon {
        case .single(let symbol):
            updateStatusItem(with: symbol)
        case .multiple(let symbols, let mode):
            switch mode {
            case .single:
                if let firstSymbol = symbols.first {
                    updateStatusItem(with: firstSymbol)
                }
            case .rotating:
                let symbol = symbols[currentRotationIndex % symbols.count]
                updateStatusItem(with: symbol)
            case .sideBySide:
                updateStatusItemSideBySide(with: symbols)
            }
        case .image(let image):
            statusItem.button?.image = image
        }
    }

    private func updateStatusItem(with symbol: ColoredSymbol) {
        if let image = IconManager.createImage(for: symbol) {
            statusItem.button?.image = image
        }
    }

    private func updateStatusItemSideBySide(with symbols: [ColoredSymbol]) {
        let imageSize = NSSize(width: 19, height: 19) // Standard menubar icon size
        if let compositeImage = IconManager.createCompositeImage(for: symbols, size: imageSize) {
            statusItem.button?.image = compositeImage
        } else {
            statusItem.button?.image = NSImage(systemSymbolName: "questionmark.circle.fill", accessibilityDescription: nil)
        }
    }

    @objc private func statusItemClicked() {
        // Handle status item click if needed
    }

    @objc private func openSettings() {
        SettingsCoordinator.shared.openSettings()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}