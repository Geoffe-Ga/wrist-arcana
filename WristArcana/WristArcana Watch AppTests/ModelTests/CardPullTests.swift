//
//  CardPullTests.swift
//  WristArcana Watch AppTests
//
//  Created by Geoff Gallinger on 10/2/25.
//

import Foundation
import Testing
@testable import WristArcana_Watch_App

struct CardPullTests {
    // MARK: - Initialization Tests

    @Test func initWithAllParameters() async throws {
        // Given
        let id = UUID()
        let date = Date()
        let cardName = "The Fool"
        let deckName = "Rider-Waite"
        let imageName = "major_00"

        // When
        let pull = CardPull(
            id: id,
            date: date,
            cardName: cardName,
            deckName: deckName,
            cardImageName: imageName
        )

        // Then
        #expect(pull.id == id)
        #expect(pull.date == date)
        #expect(pull.cardName == cardName)
        #expect(pull.deckName == deckName)
        #expect(pull.cardImageName == imageName)
    }

    @Test func initWithDefaultParameters() async throws {
        // Given/When
        let pull = CardPull(
            cardName: "The Magician",
            deckName: "Rider-Waite",
            cardImageName: "major_01"
        )

        // Then
        #expect(pull.id != UUID()) // Has a UUID
        #expect(pull.date.timeIntervalSinceNow < 1) // Recent date
        #expect(pull.cardName == "The Magician")
        #expect(pull.deckName == "Rider-Waite")
        #expect(pull.cardImageName == "major_01")
    }

    @Test func initCreatesUniqueIds() async throws {
        // When
        let pull1 = CardPull(
            cardName: "Card 1",
            deckName: "Deck",
            cardImageName: "image1"
        )
        let pull2 = CardPull(
            cardName: "Card 2",
            deckName: "Deck",
            cardImageName: "image2"
        )

        // Then
        #expect(pull1.id != pull2.id)
    }

    @Test func initWithEmptyStrings() async throws {
        // When
        let pull = CardPull(
            cardName: "",
            deckName: "",
            cardImageName: ""
        )

        // Then
        #expect(pull.cardName == "")
        #expect(pull.deckName == "")
        #expect(pull.cardImageName == "")
    }

    @Test func initWithLongStrings() async throws {
        // Given
        let longName = String(repeating: "a", count: 1_000)

        // When
        let pull = CardPull(
            cardName: longName,
            deckName: longName,
            cardImageName: longName
        )

        // Then
        #expect(pull.cardName.count == 1_000)
        #expect(pull.deckName.count == 1_000)
        #expect(pull.cardImageName.count == 1_000)
    }

    @Test func initWithSpecialCharacters() async throws {
        // Given
        let specialName = "Card 🃏 Name"
        let specialDeck = "Deck ✨ Name"
        let specialImage = "image-🎴_name"

        // When
        let pull = CardPull(
            cardName: specialName,
            deckName: specialDeck,
            cardImageName: specialImage
        )

        // Then
        #expect(pull.cardName == specialName)
        #expect(pull.deckName == specialDeck)
        #expect(pull.cardImageName == specialImage)
    }
}
