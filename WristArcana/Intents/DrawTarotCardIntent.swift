//
//  DrawTarotCardIntent.swift
//  WristArcana
//
//  Created by OpenAI Assistant on 2024-05-23.
//

import AppIntents
import SwiftData
import SwiftUI

@available(watchOS 10.0, *)
struct DrawTarotCardIntent: AppIntent {
    static var title: LocalizedStringResource = "Draw Tarot Card"
    static var description = IntentDescription("Draws a tarot card and saves the reading to your history.")
    static var openAppWhenRun = false
    static var parameterSummary: some ParameterSummary {
        Summary("Draw a tarot card")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        let contextProvider = IntentModelContextProvider()
        let useCase = DrawCardUseCase(
            repository: DeckRepository(),
            storageMonitor: StorageMonitor(),
            modelContextProvider: contextProvider.makeModelContext
        )

        let result = try await MainActor.run {
            try useCase.execute(excluding: [])
        }

        let dialog = IntentDialog("You drew \(result.card.name) from the \(result.deck.name) deck.")
        let snippet = DrawTarotCardResultView(result: result)
        return .result(dialog: dialog, view: snippet)
    }
}

@available(watchOS 10.0, *)
struct DrawTarotShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        let shortcut = AppShortcut(
            intent: DrawTarotCardIntent(),
            phrases: [
                AppShortcutInvocationPhrase("Draw a tarot card"),
                AppShortcutInvocationPhrase("Draw a tarot card in \(.applicationName)"),
                AppShortcutInvocationPhrase("Pull a tarot card")
            ],
            shortTitle: "Draw Card",
            systemImageName: "sparkles",
            categories: [.watch]
        )
        return [shortcut]
    }
}

private struct IntentModelContextProvider {
    private static var cachedContainer: ModelContainer?

    func makeModelContext() throws -> ModelContext {
        if let container = Self.cachedContainer {
            return container.mainContext
        }

        let container = try ModelContainer(for: CardPull.self)
        Self.cachedContainer = container
        return container.mainContext
    }
}

private struct DrawTarotCardResultView: View, AppIntentSnippetView {
    let cardName: String
    let deckName: String
    let description: String

    init(result: DrawCardUseCase.Result) {
        self.cardName = result.card.name
        self.deckName = result.deck.name
        self.description = result.card.upright
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(self.cardName)
                .font(.title)
                .fontWeight(.semibold)
            Text("Deck: \(self.deckName)")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(self.description)
                .font(.body)
                .lineLimit(3)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
