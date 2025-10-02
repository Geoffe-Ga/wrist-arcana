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
                arcana: .major,
                upright: "Beginning",
                reversed: "Reckless"
            ),
            TarotCard(
                name: "The Magician",
                imageName: "major_01",
                arcana: .major,
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
                arcana: .major,
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
                arcana: .minor,
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
                arcana: .major,
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
        let id = UUID()
        let cards = [
            TarotCard(
                name: "The Fool",
                imageName: "major_00",
                arcana: .major,
                upright: "Beginning",
                reversed: "Reckless"
            )
        ]

        let deck1 = TarotDeck(id: id, name: "Deck", cards: cards)
        let deck2 = TarotDeck(id: id, name: "Deck", cards: cards)

        // Then
        #expect(deck1 == deck2)
    }
}
