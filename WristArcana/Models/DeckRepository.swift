//
//  DeckRepository.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation

// MARK: - Protocol Definition

protocol DeckRepositoryProtocol {
    func loadDecks() throws -> [TarotDeck]
    func getCurrentDeck() -> TarotDeck
    func getRandomCard(from deck: TarotDeck) -> TarotCard?
}

// MARK: - Repository Implementation

final class DeckRepository: DeckRepositoryProtocol {
    // MARK: - Private Properties

    private var loadedDecks: [TarotDeck] = []
    private var currentDeckId: String?

    // MARK: - Initialization

    init() {
        do {
            self.loadedDecks = try self.loadDecksFromJSON()
            self.currentDeckId = self.loadedDecks.first?.id
        } catch {
            // CRITICAL: Load fallback deck with at least 1 card to prevent crashes
            self.loadedDecks = [TarotDeck.fallback]
            self.currentDeckId = TarotDeck.fallback.id
            print("⚠️ Failed to load decks: \(error). Using fallback deck.")
        }
    }

    // MARK: - Public Methods

    func loadDecks() throws -> [TarotDeck] {
        self.loadedDecks
    }

    func getCurrentDeck() -> TarotDeck {
        guard let currentId = currentDeckId,
              let deck = loadedDecks.first(where: { $0.id == currentId })
        else {
            return self.loadedDecks.first ?? TarotDeck.fallback
        }
        return deck
    }

    func getRandomCard(from deck: TarotDeck) -> TarotCard? {
        var generator = SystemRandomNumberGenerator()
        return deck.cards.randomElement(using: &generator)
    }

    // MARK: - Private Methods

    private func loadDecksFromJSON() throws -> [TarotDeck] {
        guard let url = Bundle.main.url(forResource: "DecksData", withExtension: "json") else {
            throw DeckError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let decksData = try decoder.decode(DecksDataContainer.self, from: data)

        // Validate: Decks array must not be empty
        guard !decksData.decks.isEmpty else {
            throw DeckError.noDeckFound
        }

        // Validate: Each deck must have exactly 78 cards with valid data
        for deckData in decksData.decks {
            guard deckData.cards.count == 78 else {
                throw DeckError.invalidDeckSize(expected: 78, actual: deckData.cards.count)
            }

            // Validate: Each card must have required fields
            for card in deckData.cards {
                if card.name.isEmpty {
                    throw DeckError.invalidCardData(cardId: card.id.uuidString, reason: "Card name is empty")
                }
                if card.imageName.isEmpty {
                    throw DeckError.invalidCardData(cardId: card.id.uuidString, reason: "Image name is empty")
                }
                if card.upright.isEmpty {
                    throw DeckError.invalidCardData(cardId: card.id.uuidString, reason: "Upright meaning is empty")
                }
                if card.reversed.isEmpty {
                    throw DeckError.invalidCardData(cardId: card.id.uuidString, reason: "Reversed meaning is empty")
                }
            }
        }

        return decksData.decks.map { deckData in
            TarotDeck(
                id: deckData.id,
                name: deckData.name,
                cards: deckData.cards
            )
        }
    }
}

// MARK: - Supporting Types

enum DeckError: Error {
    case fileNotFound
    case loadFailed
    case notFound
    case noDeckFound
    case invalidDeckSize(expected: Int, actual: Int)
    case invalidCardData(cardId: String, reason: String)
}

private struct DecksDataContainer: Codable {
    let decks: [DeckData]
}

private struct DeckData: Codable {
    let id: String
    let name: String
    let cards: [TarotCard]
}
