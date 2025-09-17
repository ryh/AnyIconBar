import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @Environment(\.openSettings) private var openSettings
    @State private var selectedSymbol: String?
    @State private var selectedColor: Color = .accentColor
    @State private var showingSymbolPicker = false
    @State private var selectedModeIndex: Int = 1
    @State private var rotationInterval: TimeInterval = 2.0

    var body: some View {
        TabView {
            iconSettingsTab
            networkSettingsTab
            aboutTab
        }
        .frame(width: 500, height: 460)
        .sheet(isPresented: $showingSymbolPicker) {
            SymbolPicker(symbol: $selectedSymbol)
        }
        .onAppear {
            // Set initial values from appDelegate
            switch appDelegate.displayMode {
            case .single: selectedModeIndex = 0
            case .rotating: selectedModeIndex = 1
            case .sideBySide: selectedModeIndex = 2
            }
            rotationInterval = appDelegate.rotationInterval

            SettingsCoordinator.shared.setOpenSettingsAction {
                self.openSettings()
            }

            // Ensure Touch Bar is set when settings window appears
            DispatchQueue.main.async {
                if let window = NSApplication.shared.keyWindow {
                    window.touchBar = self.appDelegate.touchBar
                }
            }
        }
        .onChange(of: selectedSymbol) { oldValue, newSymbol in
            if let symbol = newSymbol {
                appDelegate.currentIcon = .single(symbol: ColoredSymbol(name: symbol, color: NSColor(selectedColor)))
                appDelegate.updateStatusItem()
                appDelegate.updateTouchBar()
            }
        }
    }

    private var iconSettingsTab: some View {
        Form {
            Section(header: Text("Current Icon")) {
                HStack {
                    switch appDelegate.currentIcon {
                    case .single(let symbol):
                        Image(systemName: symbol.name)
                            .foregroundColor(Color(symbol.color))
                            .font(.system(size: 24))
                        Text(symbol.name)
                    case .multiple(let symbols, let mode):
                        HStack(spacing: 4) {
                            ForEach(symbols, id: \.name) { symbol in
                                Image(systemName: symbol.name)
                                    .foregroundColor(Color(symbol.color))
                                    .font(.system(size: 20))
                            }
                        }
                        Text("\(symbols.count) symbols (\(modeDescription(mode)))")
                    case .image(let image):
                        Image(nsImage: image)
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("Custom Image")
                    }
                }
            }

            Section(header: Text("SF Symbol Settings")) {
                ColorPicker("Symbol Color", selection: $selectedColor)
                    .onChange(of: selectedColor) { oldValue, newColor in
                        if case .single(let symbol) = appDelegate.currentIcon {
                            appDelegate.currentIcon = .single(symbol: ColoredSymbol(name: symbol.name, color: NSColor(newColor)))
                            appDelegate.updateStatusItem()
                            appDelegate.updateTouchBar()
                        }
                    }

                Button("Choose Symbol") {
                    showingSymbolPicker = true
                }
            }

            Section(header: Text("Display Mode")) {
                Picker("Mode", selection: $selectedModeIndex) {
                    Text("Single").tag(0)
                    Text("Rotating").tag(1)
                    Text("Side by Side").tag(2)
                }
                .onChange(of: selectedModeIndex) { oldValue, newIndex in
                    let newMode: DisplayMode
                    switch newIndex {
                    case 0: newMode = .single
                    case 1: newMode = .rotating(interval: rotationInterval)
                    case 2: newMode = .sideBySide
                    default: newMode = .single
                    }
                    appDelegate.displayMode = newMode
                    UserDefaults.standard.set(newIndex == 1 ? "rotating" : newIndex == 2 ? "sideBySide" : "single", forKey: "displayMode")
                    // Update current icon if it's multiple symbols
                    if case .multiple(let symbols, _) = appDelegate.currentIcon {
                        appDelegate.currentIcon = .multiple(symbols: symbols, mode: newMode)
                        appDelegate.startDisplayMode()
                    }
                }

                if selectedModeIndex == 1 {
                    HStack {
                        Text("Interval:")
                        Slider(value: $rotationInterval, in: 0.5...10.0, step: 0.5)
                        Text("\(rotationInterval, specifier: "%.1f")s")
                    }
                    .onChange(of: rotationInterval) { oldValue, newInterval in
                        appDelegate.rotationInterval = newInterval
                        UserDefaults.standard.set(newInterval, forKey: "rotationInterval")
                        if case .rotating = appDelegate.displayMode {
                            appDelegate.displayMode = .rotating(interval: newInterval)
                            if case .multiple(let symbols, _) = appDelegate.currentIcon {
                                appDelegate.currentIcon = .multiple(symbols: symbols, mode: appDelegate.displayMode)
                                appDelegate.startDisplayMode()
                            }
                        }
                    }
                }
            }

            Section(header: Text("Legacy Color Mapping")) {
                Text("Send these commands via UDP to change to legacy colors:")
                VStack(alignment: .leading, spacing: 4) {
                    Text("• white, red, orange, yellow")
                    Text("• green, cyan, blue, purple")
                    Text("• black, hollow, filled")
                    Text("• exclamation, question")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .tabItem {
            Label("Icon", systemImage: "paintbrush")
        }
    }

    private var networkSettingsTab: some View {
        Form {
            Section(header: Text("UDP Configuration")) {
                HStack {
                    Text("Port:")
                    TextField("", value: .constant(appDelegate.udpPort), formatter: NumberFormatter())
                        .disabled(true)
                    Text("(Set via ANYBAR_PORT environment variable)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Status:")
                    Circle()
                        .fill(appDelegate.isConnected ? Color.green : Color.red)
                        .frame(width: 12, height: 12)
                    Text(appDelegate.isConnected ? "Connected" : "Disconnected")
                }
            }

            Section(header: Text("Usage")) {
                Text("Send UDP messages to port \(appDelegate.udpPort) to change the icon:")
                VStack(alignment: .leading, spacing: 4) {
                    Text("• SF Symbol name (e.g., 'star.fill')")
                    Text("• Legacy color name (e.g., 'red')")
                    Text("• 'quit' to terminate the app")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .tabItem {
            Label("Network", systemImage: "network")
        }
    }

    private var aboutTab: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.circle")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)

            Text("AnyIconBar")
                .font(.title)
                .bold()

            Text("A modern menubar icon indicator for macOS")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Text("Ported from AnyBar with SF Symbols support")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()

            Text("© 2024 AnyIconBar")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .tabItem {
            Label("About", systemImage: "info.circle")
        }
    }

    private func modeDescription(_ mode: DisplayMode) -> String {
        switch mode {
        case .single:
            return "single"
        case .rotating:
            return "rotating"
        case .sideBySide:
            return "side-by-side"
        }
    }
}
