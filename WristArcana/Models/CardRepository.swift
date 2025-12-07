//
//  CardRepository.swift
//  WristArcana
//
//  Created by OpenAI on 10/1/25.
//

import Foundation
import OSLog

protocol CardRepositoryProtocol {
    func getAllCards() -> [TarotCard]
    func getCards(for suit: TarotCard.Suit) -> [TarotCard]
    func getCard(by id: UUID) -> TarotCard?
    func getSuits() -> [TarotCard.Suit]
}

final class CardRepository: CardRepositoryProtocol {
    private var allCards: [TarotCard] = []

    init() {
        self.loadCards()
    }

    func getAllCards() -> [TarotCard] {
        self.allCards.sorted { card1, card2 in
            if card1.suit.sortOrder != card2.suit.sortOrder {
                return card1.suit.sortOrder < card2.suit.sortOrder
            }

            if card1.suit == .majorArcana, card2.suit == .majorArcana {
                return card1.number < card2.number
            }

            if card1.suit == card2.suit {
                return card1.number < card2.number
            }

            return card1.suit.sortOrder < card2.suit.sortOrder
        }
    }

    func getCards(for suit: TarotCard.Suit) -> [TarotCard] {
        self.allCards
            .filter { $0.suit == suit }
            .sorted { $0.number < $1.number }
    }

    func getCard(by id: UUID) -> TarotCard? {
        self.allCards.first { $0.id == id }
    }

    func getSuits() -> [TarotCard.Suit] {
        TarotCard.Suit.allCases.sorted { $0.sortOrder < $1.sortOrder }
    }

    /// Loads cards from DecksData.json with graceful error handling.
    /// If loading fails, falls back to emergency card array to prevent empty state.
    /// - Note: See Issue #35 (BUG-006) - prevents silent initialization failure
    private func loadCards() {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WristArcana", category: "CardRepository")

        do {
            // STEP 1: Locate DecksData.json
            guard let url = Bundle.main.url(forResource: "DecksData", withExtension: "json") else {
                throw CardLoadError.resourceNotFound
            }

            // STEP 2: Load and decode JSON
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let decksData = try decoder.decode(DecksDataContainer.self, from: data)

            // STEP 3: Extract first deck
            guard let firstDeck = decksData.decks.first else {
                throw CardLoadError.noDeckFound
            }

            // STEP 4: Validate cards array
            guard !firstDeck.cards.isEmpty else {
                throw CardLoadError.emptyDeck
            }

            self.allCards = firstDeck.cards
            logger.info("Successfully loaded \(self.allCards.count) cards from DecksData.json")
        } catch {
            // STEP 5: Fallback to emergency card array
            logger.error("Failed to load cards: \(error.localizedDescription)")
            logger.warning("Using emergency fallback card to prevent empty state")
            self.allCards = TarotCard.emergencyFallback
        }
    }
}

// MARK: - Error Types

private enum CardLoadError: Error {
    case resourceNotFound
    case noDeckFound
    case emptyDeck
}

// MARK: - Private Data Structures

private struct DecksDataContainer: Codable {
    let decks: [DeckData]
}

private struct DeckData: Codable {
    let id: String
    let name: String
    let cards: [TarotCard]
}
