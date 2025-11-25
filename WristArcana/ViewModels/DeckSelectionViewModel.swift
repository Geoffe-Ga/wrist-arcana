//
//  DeckSelectionViewModel.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation

@MainActor
final class DeckSelectionViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var availableDecks: [TarotDeck] = []
    @Published var selectedDeckId: String?
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private let repository: DeckRepositoryProtocol

    // MARK: - Initialization

    init(repository: DeckRepositoryProtocol) {
        self.repository = repository
        self.loadDecks()
    }

    // MARK: - Public Methods

    func loadDecks() {
        do {
            self.availableDecks = try self.repository.loadDecks()
            self.selectedDeckId = self.repository.getCurrentDeck().id
            self.errorMessage = nil // Clear error on success
        } catch {
            self.availableDecks = [] // Clear decks on error
            self.errorMessage = "Failed to load decks"
            print("⚠️ Failed to load decks: \(error)")
        }
    }

    func selectDeck(_ deckId: String) {
        self.selectedDeckId = deckId
        // In future, this would persist selection to UserDefaults or SwiftData
    }
}
