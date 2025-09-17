import SwiftUI

@main
struct AnyIconBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Settings scene for the app
        Settings {
            SettingsView()
                .environmentObject(appDelegate)
        }
    }
}
