//
//  DrawCardIntent.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/7/25.
//

import AppIntents
import SwiftData
import SwiftUI

/// App Intent that allows users to draw a tarot card via Siri and Shortcuts
struct DrawCardIntent: AppIntent {
    // MARK: - Intent Metadata

    static var title: LocalizedStringResource = "Draw Tarot Card"

    static var description: IntentDescription? = IntentDescription(
        "Draw a random tarot card and save it to your reading history.",
        categoryName: "Readings"
    )

    static var openAppWhenRun: Bool = false

    // MARK: - Intent Execution

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Initialize SwiftData container
        let container = try ModelContainer(for: CardPull.self)
        let modelContext = ModelContext(container)

        // Initialize dependencies
        let repository = DeckRepository()
        let storageMonitor = StorageMonitor()

        // Create ViewModel
        let viewModel = CardDrawViewModel(
            repository: repository,
            storageMonitor: storageMonitor,
            modelContext: modelContext
        )

        // Draw the card
        await viewModel.drawCard()

        // Check for errors
        if let errorMessage = viewModel.errorMessage {
            throw IntentError.drawFailed(message: errorMessage)
        }

        // Get the drawn card
        guard let card = viewModel.currentCard else {
            throw IntentError.noCardDrawn
        }

        // Create response dialog
        let dialog = IntentDialog(
            full: "You drew \(card.name). \(card.upright)",
            supporting: "You drew \(card.name)"
        )

        return .result(dialog: dialog)
    }
}

// MARK: - Intent Errors

enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case noCardDrawn
    case drawFailed(message: String)

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .noCardDrawn:
            "Failed to draw a card. Please try again."
        case let .drawFailed(message):
            LocalizedStringResource(stringLiteral: message)
        }
    }
}
