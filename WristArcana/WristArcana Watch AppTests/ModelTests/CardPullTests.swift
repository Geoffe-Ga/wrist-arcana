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
        let description = "New beginnings"

        // When
        let pull = CardPull(
            id: id,
            date: date,
            cardName: cardName,
            deckName: deckName,
            cardImageName: imageName,
            cardDescription: description
        )

        // Then
        #expect(pull.id == id)
        #expect(pull.date == date)
        #expect(pull.cardName == cardName)
        #expect(pull.deckName == deckName)
        #expect(pull.cardImageName == imageName)
        #expect(pull.cardDescription == description)
    }

    @Test func initWithDefaultParameters() async throws {
        // Given/When
        let pull = CardPull(
            cardName: "The Magician",
            deckName: "Rider-Waite",
            cardImageName: "major_01",
            cardDescription: "Manifestation"
        )

        // Then
        #expect(pull.id != UUID()) // Has a UUID
        #expect(pull.date.timeIntervalSinceNow < 1) // Recent date
        #expect(pull.cardName == "The Magician")
        #expect(pull.deckName == "Rider-Waite")
        #expect(pull.cardImageName == "major_01")
        #expect(pull.cardDescription == "Manifestation")
    }

    @Test func initCreatesUniqueIds() async throws {
        // When
        let pull1 = CardPull(
            cardName: "Card 1",
            deckName: "Deck",
            cardImageName: "image1",
            cardDescription: "Description 1"
        )
        let pull2 = CardPull(
            cardName: "Card 2",
            deckName: "Deck",
            cardImageName: "image2",
            cardDescription: "Description 2"
        )

        // Then
        #expect(pull1.id != pull2.id)
    }

    @Test func initWithEmptyStrings() async throws {
        // When
        let pull = CardPull(
            cardName: "",
            deckName: "",
            cardImageName: "",
            cardDescription: ""
        )

        // Then
        #expect(pull.cardName == "")
        #expect(pull.deckName == "")
        #expect(pull.cardImageName == "")
        #expect(pull.cardDescription == "")
    }

    @Test func initWithLongStrings() async throws {
        // Given
        let longName = String(repeating: "a", count: 1_000)

        // When
        let pull = CardPull(
            cardName: longName,
            deckName: longName,
            cardImageName: longName,
            cardDescription: longName
        )

        // Then
        #expect(pull.cardName.count == 1_000)
        #expect(pull.deckName.count == 1_000)
        #expect(pull.cardImageName.count == 1_000)
        #expect(pull.cardDescription.count == 1_000)
    }

    @Test func initWithSpecialCharacters() async throws {
        // Given
        let specialName = "Card 🃏 Name"
        let specialDeck = "Deck ✨ Name"
        let specialImage = "image-🎴_name"
        let specialDescription = "Special ✨ meaning"

        // When
        let pull = CardPull(
            cardName: specialName,
            deckName: specialDeck,
            cardImageName: specialImage,
            cardDescription: specialDescription
        )

        // Then
        #expect(pull.cardName == specialName)
        #expect(pull.deckName == specialDeck)
        #expect(pull.cardImageName == specialImage)
        #expect(pull.cardDescription == specialDescription)
    }

    // MARK: - Note Property Tests

    @Test func initWithNoteParameter() async throws {
        // When
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: "Great reading!"
        )

        // Then
        #expect(pull.note == "Great reading!")
    }

    @Test func initWithoutNoteParameter() async throws {
        // When
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings"
        )

        // Then
        #expect(pull.note == nil)
    }

    @Test func hasNoteReturnsTrueWhenNoteExists() async throws {
        // When
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: "Great reading!"
        )

        // Then
        #expect(pull.hasNote == true)
    }

    @Test func hasNoteReturnsFalseWhenNoteIsNil() async throws {
        // When
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: nil
        )

        // Then
        #expect(pull.hasNote == false)
    }

    @Test func hasNoteReturnsFalseWhenNoteIsEmpty() async throws {
        // When
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: "   "
        )

        // Then
        #expect(pull.hasNote == false)
    }

    @Test func truncatedNoteReturnsFullNoteWhenShort() async throws {
        // Given
        let shortNote = "Short note"

        // When
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: shortNote
        )

        // Then
        #expect(pull.truncatedNote == shortNote)
    }

    @Test func truncatedNoteTruncatesLongNote() async throws {
        // Given
        let longNote = String(repeating: "a", count: 100)

        // When
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: longNote
        )

        // Then
        #expect(pull.truncatedNote != nil)
        #expect(pull.truncatedNote!.hasSuffix("..."))
        #expect(pull.truncatedNote!.count <= 83) // 80 + "..."
    }

    @Test func truncatedNoteReturnsNilWhenNoNote() async throws {
        // When
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: nil
        )

        // Then
        #expect(pull.truncatedNote == nil)
    }

    @Test func truncatedNoteReturnsNilWhenNoteIsEmpty() async throws {
        // When
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: ""
        )

        // Then
        #expect(pull.truncatedNote == nil)
    }
}
