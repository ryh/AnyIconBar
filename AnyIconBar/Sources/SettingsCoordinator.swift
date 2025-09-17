//
//  SettingsCoordinator.swift
//  AnyIconBar
//
//  Created by Ricki on 9/17/25.
//
import AppKit

class SettingsCoordinator {
    static let shared = SettingsCoordinator()
    private var openSettingsAction: (() -> Void)?

    func setOpenSettingsAction(_ action: @escaping () -> Void) {
        self.openSettingsAction = action
    }

    func openSettings() {
        if let action = openSettingsAction {
            action()
        } else {
            // Fallback: use the private selector to create the window
            NSApp.sendAction(Selector(("_showSettingsWindow:")), to: nil, from: nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

