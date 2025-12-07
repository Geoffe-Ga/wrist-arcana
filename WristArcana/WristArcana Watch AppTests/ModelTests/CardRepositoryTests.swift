//
//  CardRepositoryTests.swift
//  WristArcana Watch AppTests
//
//  Created by OpenAI on 10/1/25.
//

import Foundation
import Testing
@testable import WristArcana_Watch_App

struct CardRepositoryTests {
    @Test func getAllCardsReturns78Cards() async throws {
        let repository = CardRepository()
        let cards = repository.getAllCards()
        #expect(cards.count == 78)
    }

    @Test func getAllCardsSortedBySuitThenNumber() async throws {
        let repository = CardRepository()
        let cards = repository.getAllCards()

        #expect(cards.first?.suit == .majorArcana)
        #expect(cards.first?.number == 0)
        #expect(cards[22].suit == .swords)
        #expect(cards[22].number == 1)
    }

    @Test func getCardsForSuitReturnsExpectedCount() async throws {
        let repository = CardRepository()
        let majorCards = repository.getCards(for: .majorArcana)
        let swordsCards = repository.getCards(for: .swords)

        #expect(majorCards.count == 22)
        #expect(swordsCards.count == 14)
    }

    @Test func getCardsSortedByNumber() async throws {
        let repository = CardRepository()
        let cards = repository.getCards(for: .swords)

        for index in 0 ..< cards.count - 1 {
            #expect(cards[index].number <= cards[index + 1].number)
        }
    }

    @Test func getCardByIdReturnsCard() async throws {
        let repository = CardRepository()
        let cards = repository.getAllCards()
        guard let firstCard = cards.first else {
            #expect(Bool(false), "Cards should not be empty")
            return
        }

        let retrieved = repository.getCard(by: firstCard.id)
        #expect(retrieved == firstCard)
    }

    @Test func getCardByInvalidIdReturnsNil() async throws {
        let repository = CardRepository()
        let card = repository.getCard(by: UUID())
        #expect(card == nil)
    }

    @Test func getSuitsReturnsOrderedSuits() async throws {
        let repository = CardRepository()
        let suits = repository.getSuits()
        #expect(suits == [.majorArcana, .swords, .wands, .pentacles, .cups])
    }

    // MARK: - Error Handling Tests (BUG-006)

    @Test func init_alwaysHasAtLeastOneCard() async throws {
        // Given / When - Initialize repository (even if JSON loading fails)
        let repository = CardRepository()

        // Then - Must have at least one card (either loaded or fallback)
        let cards = repository.getAllCards()
        #expect(
            !cards.isEmpty,
            "CardRepository must never have empty cards - should use fallback if JSON fails"
        )
    }

    @Test func getAllCards_neverReturnsEmptyArray() async throws {
        // Given
        let repository = CardRepository()

        // When
        let cards = repository.getAllCards()

        // Then - Used throughout app, so must never be empty
        #expect(
            cards.count >= 1,
            "getAllCards() must return at least 1 card to prevent crashes in CardReferenceView"
        )
    }

    @Test func getCards_returnsAtLeastOneCardForMajorArcana() async throws {
        // Given
        let repository = CardRepository()

        // When
        let majorCards = repository.getCards(for: .majorArcana)

        // Then - Fallback should include at least one Major Arcana card
        #expect(
            !majorCards.isEmpty,
            "Should have at least one Major Arcana card (The Fool fallback)"
        )
    }
}
