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
    @Test func displayNumberMajorArcanaZero() async throws {
        let card = TarotCard(
            name: "The Fool",
            imageName: "major_00",
            suit: .majorArcana,
            number: 0,
            upright: "New beginnings",
            reversed: "Recklessness",
            keywords: ["Beginnings"]
        )

        #expect(card.displayNumber == "0")
    }

    @Test func displayNumberMajorArcanaRoman() async throws {
        let card = TarotCard(
            name: "The Magician",
            imageName: "major_01",
            suit: .majorArcana,
            number: 1,
            upright: "Manifestation",
            reversed: "Manipulation",
            keywords: ["Manifestation"]
        )

        #expect(card.displayNumber == "I")
    }

    @Test func displayNumberMinorArcanaAce() async throws {
        let card = TarotCard(
            name: "Ace of Swords",
            imageName: "swords_01",
            suit: .swords,
            number: 1,
            upright: "Clarity",
            reversed: "Confusion",
            keywords: ["Clarity"]
        )

        #expect(card.displayNumber == "Ace")
    }

    @Test func displayNumberMinorArcanaCourtCards() async throws {
        let page = TarotCard(
            name: "Page of Swords",
            imageName: "swords_page",
            suit: .swords,
            number: 11,
            upright: "Curiosity",
            reversed: "Gossip",
            keywords: ["Messages"]
        )

        let king = TarotCard(
            name: "King of Swords",
            imageName: "swords_king",
            suit: .swords,
            number: 14,
            upright: "Authority",
            reversed: "Tyranny",
            keywords: ["Authority"]
        )

        #expect(page.displayNumber == "Page")
        #expect(king.displayNumber == "King")
    }

    @Test func fullDisplayNameForMajorArcana() async throws {
        let card = TarotCard(
            name: "The Fool",
            imageName: "major_00",
            suit: .majorArcana,
            number: 0,
            upright: "New beginnings",
            reversed: "Recklessness",
            keywords: ["Beginnings"]
        )

        #expect(card.fullDisplayName == "0 - The Fool")
    }

    @Test func fullDisplayNameForMinorArcana() async throws {
        let card = TarotCard(
            name: "Ace of Swords",
            imageName: "swords_01",
            suit: .swords,
            number: 1,
            upright: "Clarity",
            reversed: "Confusion",
            keywords: ["Clarity"]
        )

        #expect(card.fullDisplayName == "Ace of Swords")
    }

    @Test func suitSortOrder() async throws {
        #expect(TarotCard.Suit.majorArcana.sortOrder == 0)
        #expect(TarotCard.Suit.swords.sortOrder == 1)
        #expect(TarotCard.Suit.wands.sortOrder == 2)
        #expect(TarotCard.Suit.pentacles.sortOrder == 3)
        #expect(TarotCard.Suit.cups.sortOrder == 4)
    }

    @Test func suitCardCounts() async throws {
        #expect(TarotCard.Suit.majorArcana.cardCount == 22)
        #expect(TarotCard.Suit.swords.cardCount == 14)
        #expect(TarotCard.Suit.wands.cardCount == 14)
        #expect(TarotCard.Suit.pentacles.cardCount == 14)
        #expect(TarotCard.Suit.cups.cardCount == 14)
    }
}
