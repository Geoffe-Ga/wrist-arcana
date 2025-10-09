//
//  AppShortcutsProvider.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/7/25.
//

import AppIntents

/// Provides suggested shortcuts for Wrist Arcana that appear in the Shortcuts app
struct WristArcanaShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: DrawCardIntent(),
            phrases: [
                "Draw a tarot card in \(.applicationName)",
                "Pull a card in \(.applicationName)",
                "Get a tarot reading from \(.applicationName)",
                "Read my cards in \(.applicationName)"
            ],
            shortTitle: "Draw Card",
            systemImageName: "sparkles"
        )
    }
}
