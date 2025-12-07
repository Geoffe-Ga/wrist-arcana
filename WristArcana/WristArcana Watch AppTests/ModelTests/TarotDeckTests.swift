//
//  TarotDeckTests.swift
//  WristArcana Watch AppTests
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation
import Testing
@testable import WristArcana_Watch_App

struct TarotDeckTests {
    // MARK: - Initialization Tests

    @Test func deckInitialization() async throws {
        // Given
        let cards = [
            TarotCard(
                name: "The Fool",
                imageName: "major_00",
                suit: .majorArcana,
                number: 0,
                upright: "Beginning",
                reversed: "Reckless"
            ),
            TarotCard(
                name: "The Magician",
                imageName: "major_01",
                suit: .majorArcana,
                number: 1,
                upright: "Power",
                reversed: "Manipulation"
            )
        ]

        // When
        let deck = TarotDeck(name: "Test Deck", cards: cards)

        // Then
        #expect(deck.name == "Test Deck")
        #expect(deck.cards.count == 2)
        #expect(deck.cardCount == 2)
    }

    @Test func emptyDeck() async throws {
        // When
        let deck = TarotDeck(name: "Empty Deck", cards: [])

        // Then
        #expect(deck.cardCount == 0)
        #expect(deck.cards.isEmpty)
    }

    @Test func fullRiderWaiteDeck() async throws {
        // Given - A complete 78 card deck
        var cards: [TarotCard] = []

        // Major Arcana (22 cards)
        for index in 0 ... 21 {
            cards.append(TarotCard(
                name: "Major \(index)",
                imageName: "major_\(String(format: "%02d", index))",
                suit: .majorArcana,
                number: index,
                upright: "Upright",
                reversed: "Reversed"
            ))
        }

        // Minor Arcana (56 cards) - simplified for test
        for _ in 0 ..< 56 {
            cards.append(TarotCard(
                name: "Minor Card",
                imageName: "minor",
                suit: .swords,
                number: 1,
                upright: "Upright",
                reversed: "Reversed"
            ))
        }

        // When
        let deck = TarotDeck(name: "Rider-Waite", cards: cards)

        // Then
        #expect(deck.cardCount == 78)
        #expect(deck.cards.count == 78)
    }

    // MARK: - Codable Tests

    @Test func deckCodable() async throws {
        // Given
        let cards = [
            TarotCard(
                name: "The Fool",
                imageName: "major_00",
                suit: .majorArcana,
                number: 0,
                upright: "Beginning",
                reversed: "Reckless"
            )
        ]
        let deck = TarotDeck(name: "Test Deck", cards: cards)

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(deck)
        let decoder = JSONDecoder()
        let decodedDeck = try decoder.decode(TarotDeck.self, from: data)

        // Then
        #expect(decodedDeck.name == deck.name)
        #expect(decodedDeck.cards.count == deck.cards.count)
        #expect(decodedDeck.cards.first?.name == "The Fool")
    }

    // MARK: - Equatable Tests

    @Test func deckEquality() async throws {
        // Given
        let id = UUID().uuidString
        let cards = [
            TarotCard(
                name: "The Fool",
                imageName: "major_00",
                suit: .majorArcana,
                number: 0,
                upright: "Beginning",
                reversed: "Reckless"
            )
        ]

        let deck1 = TarotDeck(id: id, name: "Deck", cards: cards)
        let deck2 = TarotDeck(id: id, name: "Deck", cards: cards)

        // Then
        #expect(deck1 == deck2)
    }

    // MARK: - Static Properties Tests

    @Test func riderWaite_hasAtLeastOneCard() async throws {
        // When
        let deck = TarotDeck.riderWaite

        // Then - Must have at least 1 card to prevent crashes in getRandomCard
        #expect(deck.cards.count >= 1, "TarotDeck.riderWaite must have at least 1 card to prevent crashes")
    }

    @Test func riderWaite_neverReturnsEmptyDeck() async throws {
        // When
        let deck = TarotDeck.riderWaite

        // Then - Used as fallback, so must never be empty
        #expect(!deck.cards.isEmpty, "TarotDeck.riderWaite is used as fallback and must never be empty")
    }

    @Test func riderWaite_hasValidCardData() async throws {
        // When
        let deck = TarotDeck.riderWaite

        // Then - First card should have valid data
        let firstCard = deck.cards.first!
        #expect(!firstCard.name.isEmpty, "Card must have a name")
        #expect(!firstCard.imageName.isEmpty, "Card must have an image name")
        #expect(!firstCard.upright.isEmpty, "Card must have upright meaning")
        #expect(!firstCard.reversed.isEmpty, "Card must have reversed meaning")
    }
}
