//
//  DeckRepositoryTests.swift
//  WristArcana Watch AppTests
//
//  Created by Geoff Gallinger on 10/2/25.
//

import Foundation
import Testing
@testable import WristArcana_Watch_App

struct DeckRepositoryTests {
    // MARK: - Initialization Tests

    @Test func init_loadsDecksFromJSON() async throws {
        // When
        let sut = DeckRepository()

        // Then
        let decks = try sut.loadDecks()
        #expect(!decks.isEmpty)
    }

    @Test func init_setsFirstDeckAsCurrent() async throws {
        // When
        let sut = DeckRepository()

        // Then
        let currentDeck = sut.getCurrentDeck()
        #expect(currentDeck.name == "Rider-Waite")
    }

    // MARK: - Load Decks Tests

    @Test func loadDecks_returnsNonEmptyArray() async throws {
        // Given
        let sut = DeckRepository()

        // When
        let decks = try sut.loadDecks()

        // Then
        #expect(!decks.isEmpty)
    }

    @Test func loadDecks_returnsRiderWaiteDeck() async throws {
        // Given
        let sut = DeckRepository()

        // When
        let decks = try sut.loadDecks()

        // Then
        let riderWaite = decks.first { $0.name == "Rider-Waite" }
        #expect(riderWaite != nil)
    }

    @Test func loadDecks_deckHasCards() async throws {
        // Given
        let sut = DeckRepository()

        // When
        let decks = try sut.loadDecks()

        // Then
        let firstDeck = decks.first!
        #expect(!firstDeck.cards.isEmpty)
    }

    @Test func loadDecks_deckHas78Cards() async throws {
        // Given
        let sut = DeckRepository()

        // When
        let decks = try sut.loadDecks()

        // Then
        let riderWaite = decks.first { $0.name == "Rider-Waite" }
        #expect(riderWaite?.cards.count == 78)
    }

    @Test func loadDecks_cardsHaveValidData() async throws {
        // Given
        let sut = DeckRepository()

        // When
        let decks = try sut.loadDecks()
        let firstDeck = decks.first!
        let firstCard = firstDeck.cards.first!

        // Then
        #expect(!firstCard.name.isEmpty)
        #expect(!firstCard.imageName.isEmpty)
        #expect(!firstCard.upright.isEmpty)
        #expect(!firstCard.reversed.isEmpty)
    }

    @Test func loadDecks_hasMajorArcana() async throws {
        // Given
        let sut = DeckRepository()

        // When
        let decks = try sut.loadDecks()
        let firstDeck = decks.first!

        // Then
        let majorArcana = firstDeck.cards.filter { $0.suit == .majorArcana }
        #expect(majorArcana.count == 22)
    }

    @Test func loadDecks_hasMinorArcana() async throws {
        // Given
        let sut = DeckRepository()

        // When
        let decks = try sut.loadDecks()
        let firstDeck = decks.first!

        // Then
        let minorArcana = firstDeck.cards.filter { $0.suit != .majorArcana }
        #expect(minorArcana.count == 56)
    }

    // MARK: - Get Current Deck Tests

    @Test func getCurrentDeck_returnsValidDeck() async throws {
        // Given
        let sut = DeckRepository()

        // When
        let deck = sut.getCurrentDeck()

        // Then
        #expect(!deck.id.isEmpty)
        #expect(!deck.name.isEmpty)
        #expect(!deck.cards.isEmpty)
    }

    @Test func getCurrentDeck_returnsRiderWaiteByDefault() async throws {
        // Given
        let sut = DeckRepository()

        // When
        let deck = sut.getCurrentDeck()

        // Then
        #expect(deck.name == "Rider-Waite")
    }

    @Test func getCurrentDeck_returnsConsistentDeck() async throws {
        // Given
        let sut = DeckRepository()

        // When
        let deck1 = sut.getCurrentDeck()
        let deck2 = sut.getCurrentDeck()

        // Then
        #expect(deck1.id == deck2.id)
        #expect(deck1.name == deck2.name)
    }

    // MARK: - Get Random Card Tests

    @Test func getRandomCard_returnsCard() async throws {
        // Given
        let sut = DeckRepository()
        let deck = sut.getCurrentDeck()

        // When
        let card = sut.getRandomCard(from: deck)

        // Then
        #expect(!card.name.isEmpty)
    }

    @Test func getRandomCard_returnsCardFromDeck() async throws {
        // Given
        let sut = DeckRepository()
        let deck = sut.getCurrentDeck()

        // When
        let card = sut.getRandomCard(from: deck)

        // Then
        let cardInDeck = deck.cards.contains { $0.id == card.id }
        #expect(cardInDeck)
    }

    @Test func getRandomCard_hasRandomDistribution() async throws {
        // Given
        let sut = DeckRepository()
        let deck = sut.getCurrentDeck()
        var drawnCardIds: Set<UUID> = []

        // When - Draw 20 cards
        for _ in 0 ..< 20 {
            let card = sut.getRandomCard(from: deck)
            drawnCardIds.insert(card.id)
        }

        // Then - Should have drawn multiple different cards
        #expect(drawnCardIds.count >= 10)
    }

    @Test func getRandomCard_worksWithSmallDeck() async throws {
        // Given
        let sut = DeckRepository()
        let smallDeck = TarotDeck(
            name: "Small",
            cards: [
                TarotCard(
                    name: "Only Card",
                    imageName: "card",
                    suit: .majorArcana,
                    number: 0,
                    upright: "Up",
                    reversed: "Rev"
                )
            ]
        )

        // When
        let card = sut.getRandomCard(from: smallDeck)

        // Then
        #expect(card.name == "Only Card")
    }

    @Test func getRandomCard_worksWithMultipleCards() async throws {
        // Given
        let sut = DeckRepository()
        let deck = TarotDeck(
            name: "Test Deck",
            cards: [
                TarotCard(
                    name: "Card 1",
                    imageName: "card1",
                    suit: .majorArcana,
                    number: 0,
                    upright: "Up",
                    reversed: "Rev"
                ),
                TarotCard(
                    name: "Card 2",
                    imageName: "card2",
                    suit: .majorArcana,
                    number: 1,
                    upright: "Up",
                    reversed: "Rev"
                )
            ]
        )

        var cardNames: Set<String> = []

        // When - Draw multiple times
        for _ in 0 ..< 10 {
            let card = sut.getRandomCard(from: deck)
            cardNames.insert(card.name)
        }

        // Then - Should see both cards
        #expect(cardNames.count == 2)
        #expect(cardNames.contains("Card 1"))
        #expect(cardNames.contains("Card 2"))
    }

    // MARK: - Integration Tests

    @Test func fullWorkflow_loadsAndDrawsCards() async throws {
        // Given
        let sut = DeckRepository()

        // When
        let decks = try sut.loadDecks()
        let currentDeck = sut.getCurrentDeck()
        let card = sut.getRandomCard(from: currentDeck)

        // Then
        #expect(!decks.isEmpty)
        #expect(currentDeck.cards.count == 78)
        #expect(!card.name.isEmpty)
    }

    @Test func deckData_hasValidStructure() async throws {
        // Given
        let sut = DeckRepository()

        // When
        let decks = try sut.loadDecks()
        let deck = decks.first!

        // Then - Verify deck structure
        #expect(deck.id.starts(with: "r"))
        #expect(deck.name.contains("Waite"))
        #expect(deck.cardCount == 78)

        // Verify card structure
        let fool = deck.cards.first { $0.name.contains("Fool") }
        #expect(fool != nil)
        #expect(fool?.suit == .majorArcana)
        #expect(fool?.imageName.contains("major") == true)
    }
}
