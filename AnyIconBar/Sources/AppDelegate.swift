import AppKit
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem!
    var udpPort: Int = 1738
    private var appTitle: String?
    private var cancellables = Set<AnyCancellable>()

    @Published var currentIcon: IconType = .single(symbol: ColoredSymbol(name: "star.fill", color: .gray))
    @Published var displayMode: DisplayMode = .single
    @Published var rotationInterval: TimeInterval = 2.0
    @Published var isConnected: Bool = false

    private var rotationTimer: Timer?
    private var currentRotationIndex: Int = 0

    // Managers
    private var udpManager: UDPManager?
    private var touchBarManager: TouchBarManager?
    private var menuBarManager: MenuBarManager?

    // Touch Bar provider
    var touchBar: NSTouchBar? {
        return touchBarManager?.touchBar
    }

    override init() {
        super.init()
        setupEnvironment()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBarManager()
        setupUDPManager()
        setupTouchBarManager()
        updateStatusItem()
    }

    func applicationWillTerminate(_ notification: Notification) {
        udpManager?.stop()
        touchBarManager?.cleanup()
    }

    private func setupEnvironment() {
        // Read environment variables
        if let portStr = ProcessInfo.processInfo.environment["ANYBAR_PORT"],
            let port = Int(portStr), port > 0 && port <= 65535 {
            udpPort = port
        }

        appTitle = ProcessInfo.processInfo.environment["ANYBAR_TITLE"]

        // Load persisted settings
        if let modeRaw = UserDefaults.standard.string(forKey: "displayMode") {
            switch modeRaw {
            case "rotating":
                let interval = UserDefaults.standard.double(forKey: "rotationInterval")
                displayMode = .rotating(interval: interval > 0 ? interval : 2.0)
                rotationInterval = interval > 0 ? interval : 2.0
            case "sideBySide":
                displayMode = .sideBySide
            default:
                displayMode = .single
            }
        }

        if let initIcon = ProcessInfo.processInfo.environment["ANYBAR_INIT"] {
            setIcon(from: initIcon)
        }
    }


    private func setupMenuBarManager() {
        menuBarManager = MenuBarManager(udpPort: udpPort, appTitle: appTitle)
    }

    private func setupUDPManager() {
        udpManager = UDPManager(port: udpPort) { [weak self] message in
            self?.processMessage(message)
        }
    }

    private func setupTouchBarManager() {
        touchBarManager = TouchBarManager(currentIcon: currentIcon, currentRotationIndex: currentRotationIndex)
    }



    private func processMessage(_ message: String) {
        if message == "quit" {
            NSApplication.shared.terminate(nil)
        } else {
            setIcon(from: message)
        }
    }

    private func setIcon(from message: String) {
        // Stop any existing rotation timer
        rotationTimer?.invalidate()
        rotationTimer = nil

        // Check if message contains multiple symbols (comma-separated)
        if message.contains(",") {
            let symbolStrings = message.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            var coloredSymbols: [ColoredSymbol] = []

            for symbolString in symbolStrings {
                if let coloredSymbol = ColorUtilities.parseSymbolString(symbolString) {
                    coloredSymbols.append(coloredSymbol)
                }
            }

            if !coloredSymbols.isEmpty {
                currentIcon = .multiple(symbols: coloredSymbols, mode: displayMode)
                startDisplayMode()
            } else {
                // Fallback to question mark
                currentIcon = .single(symbol: ColoredSymbol(name: "questionmark.circle.fill", color: .gray))
            }
        } else {
            // Single symbol or legacy format
            if let coloredSymbol = ColorUtilities.parseSymbolString(message) {
                currentIcon = .single(symbol: coloredSymbol)
            } else {
                // Try to load as custom image
                if let image = IconManager.loadCustomImage(named: message) {
                    currentIcon = .image(image)
                } else {
                    currentIcon = .single(symbol: ColoredSymbol(name: "questionmark.circle.fill", color: .gray))
                }
            }
        }

        menuBarManager?.updateCurrentIcon(currentIcon, rotationIndex: currentRotationIndex)
        touchBarManager?.updateCurrentIcon(currentIcon, rotationIndex: currentRotationIndex)
    }



    func startDisplayMode() {
        rotationTimer?.invalidate()

        switch currentIcon {
        case .multiple(_, let mode):
            switch mode {
            case .rotating(let interval):
                rotationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
                    self?.rotateToNextIcon()
                }
                // Start immediately
                rotateToNextIcon()
            case .sideBySide:
                updateStatusItem()
            case .single:
                updateStatusItem()
            }
        default:
            updateStatusItem()
        }
    }

    private func rotateToNextIcon() {
        guard case .multiple(let symbols, _) = currentIcon, !symbols.isEmpty else { return }

        currentRotationIndex = (currentRotationIndex + 1) % symbols.count
        menuBarManager?.updateCurrentIcon(currentIcon, rotationIndex: currentRotationIndex)
        touchBarManager?.updateCurrentIcon(currentIcon, rotationIndex: currentRotationIndex)
    }

    func updateStatusItem() {
        menuBarManager?.updateCurrentIcon(currentIcon, rotationIndex: currentRotationIndex)
        touchBarManager?.updateCurrentIcon(currentIcon, rotationIndex: currentRotationIndex)
    }

    func updateTouchBar() {
        touchBarManager?.updateTouchBar()
    }

}

