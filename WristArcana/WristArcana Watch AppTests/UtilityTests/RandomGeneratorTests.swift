//
//  RandomGeneratorTests.swift
//  WristArcana Watch AppTests
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation
import Testing
@testable import WristArcana_Watch_App

struct RandomGeneratorTests {
    // MARK: - CryptoRandomGenerator Tests

    @Test func randomCardFromNonEmptyArray() async throws {
        // Given
        let generator = CryptoRandomGenerator()
        let cards = [
            TarotCard(name: "Card 1", imageName: "card1", arcana: .major, upright: "Up", reversed: "Rev"),
            TarotCard(name: "Card 2", imageName: "card2", arcana: .major, upright: "Up", reversed: "Rev"),
            TarotCard(name: "Card 3", imageName: "card3", arcana: .major, upright: "Up", reversed: "Rev")
        ]

        // When
        let selectedCard = generator.randomCard(from: cards)

        // Then
        #expect(selectedCard != nil)
        #expect(cards.contains(where: { $0.id == selectedCard?.id }))
    }

    @Test func randomCardFromEmptyArray() async throws {
        // Given
        let generator = CryptoRandomGenerator()
        let cards: [TarotCard] = []

        // When
        let selectedCard = generator.randomCard(from: cards)

        // Then
        #expect(selectedCard == nil)
    }

    @Test func randomnessDistribution() async throws {
        // Given
        let generator = CryptoRandomGenerator()
        let cards = [
            TarotCard(name: "Card 1", imageName: "card1", arcana: .major, upright: "Up", reversed: "Rev"),
            TarotCard(name: "Card 2", imageName: "card2", arcana: .major, upright: "Up", reversed: "Rev"),
            TarotCard(name: "Card 3", imageName: "card3", arcana: .major, upright: "Up", reversed: "Rev")
        ]

        var drawnCardIds: Set<UUID> = []

        // When - Draw 20 times
        for _ in 0 ..< 20 {
            if let card = generator.randomCard(from: cards) {
                drawnCardIds.insert(card.id)
            }
        }

        // Then - Should have drawn at least 2 different cards (very high probability)
        #expect(drawnCardIds.count >= 2, "Generator appears to be non-random")
    }

    @Test func singleCardArray() async throws {
        // Given
        let generator = CryptoRandomGenerator()
        let card = TarotCard(name: "Only Card", imageName: "card", arcana: .major, upright: "Up", reversed: "Rev")
        let cards = [card]

        // When
        let selectedCard = generator.randomCard(from: cards)

        // Then
        #expect(selectedCard?.id == card.id)
    }
}
