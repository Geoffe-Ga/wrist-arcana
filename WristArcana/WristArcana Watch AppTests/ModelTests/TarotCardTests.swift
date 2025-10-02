//
//  TarotCardTests.swift
//  WristArcana Watch AppTests
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation
import Testing
@testable import WristArcana_Watch_App

struct TarotCardTests {
    // MARK: - Initialization Tests

    @Test func cardInitialization() async throws {
        // Given
        let card = TarotCard(
            name: "The Fool",
            imageName: "major_00",
            arcana: .major,
            number: 0,
            upright: "New beginnings",
            reversed: "Recklessness"
        )

        // Then
        #expect(card.name == "The Fool")
        #expect(card.imageName == "major_00")
        #expect(card.arcana == .major)
        #expect(card.number == 0)
        #expect(card.upright == "New beginnings")
        #expect(card.reversed == "Recklessness")
    }

    // MARK: - Codable Tests

    @Test func cardCodable() async throws {
        // Given
        let card = TarotCard(
            name: "The Magician",
            imageName: "major_01",
            arcana: .major,
            number: 1,
            upright: "Manifestation",
            reversed: "Manipulation"
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(card)
        let decoder = JSONDecoder()
        let decodedCard = try decoder.decode(TarotCard.self, from: data)

        // Then
        #expect(decodedCard.name == card.name)
        #expect(decodedCard.imageName == card.imageName)
        #expect(decodedCard.arcana == card.arcana)
        #expect(decodedCard.number == card.number)
    }

    // MARK: - Equatable Tests

    @Test func cardEquality() async throws {
        // Given
        let id = UUID().uuidString
        let card1 = TarotCard(
            id: id,
            name: "Ace of Cups",
            imageName: "cups_01",
            arcana: .minor,
            number: 1,
            upright: "New feelings",
            reversed: "Emotional loss"
        )

        let card2 = TarotCard(
            id: id,
            name: "Ace of Cups",
            imageName: "cups_01",
            arcana: .minor,
            number: 1,
            upright: "New feelings",
            reversed: "Emotional loss"
        )

        // Then
        #expect(card1 == card2)
    }

    @Test func cardInequality() async throws {
        // Given
        let card1 = TarotCard(
            name: "Ace of Cups",
            imageName: "cups_01",
            arcana: .minor,
            number: 1,
            upright: "New feelings",
            reversed: "Emotional loss"
        )

        let card2 = TarotCard(
            name: "Two of Cups",
            imageName: "cups_02",
            arcana: .minor,
            number: 2,
            upright: "Partnership",
            reversed: "Imbalance"
        )

        // Then
        #expect(card1 != card2)
    }

    // MARK: - Arcana Type Tests

    @Test func majorArcana() async throws {
        let card = TarotCard(
            name: "The Fool",
            imageName: "major_00",
            arcana: .major,
            upright: "Beginning",
            reversed: "Recklessness"
        )

        #expect(card.arcana == .major)
    }

    @Test func minorArcana() async throws {
        let card = TarotCard(
            name: "Ace of Wands",
            imageName: "wands_01",
            arcana: .minor,
            number: 1,
            upright: "Inspiration",
            reversed: "Delays"
        )

        #expect(card.arcana == .minor)
    }
}
