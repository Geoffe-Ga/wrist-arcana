//
//  CardReferenceViewModelTests.swift
//  WristArcana Watch AppTests
//
//  Created by OpenAI on 10/1/25.
//

import Testing
@testable import WristArcana_Watch_App

@MainActor
struct CardReferenceViewModelTests {
    @Test func loadSuitsPopulatesPublishedArray() async throws {
        let repository = MockCardRepository()
        repository.suits = [.majorArcana, .swords]
        repository.cardsBySuit[.swords] = [
            TarotCard(
                name: "Ace of Swords",
                imageName: "swords_01",
                suit: .swords,
                number: 1,
                upright: "Clarity",
                reversed: "Confusion"
            )
        ]

        let viewModel = CardReferenceViewModel(cardRepository: repository)

        #expect(viewModel.suits == [.majorArcana, .swords])
    }

    @Test func selectingSuitLoadsCards() async throws {
        let repository = MockCardRepository()
        let aceOfSwords = TarotCard(
            name: "Ace of Swords",
            imageName: "swords_01",
            suit: .swords,
            number: 1,
            upright: "Clarity",
            reversed: "Confusion"
        )
        repository.suits = [.swords]
        repository.cardsBySuit[.swords] = [aceOfSwords]

        let viewModel = CardReferenceViewModel(cardRepository: repository)
        viewModel.selectSuit(.swords)

        #expect(viewModel.selectedSuit == .swords)
        #expect(viewModel.cardsInSuit == [aceOfSwords])
    }

    @Test func selectingCardUpdatesPublishedState() async throws {
        let repository = MockCardRepository()
        let card = TarotCard(
            name: "The Fool",
            imageName: "major_00",
            suit: .majorArcana,
            number: 0,
            upright: "New beginnings",
            reversed: "Recklessness"
        )
        repository.cardsBySuit[.majorArcana] = [card]

        let viewModel = CardReferenceViewModel(cardRepository: repository)
        viewModel.selectCard(card)

        #expect(viewModel.selectedCard == card)

        viewModel.deselectCard()
        #expect(viewModel.selectedCard == nil)
    }

    @Test func cardCountMatchesRepository() async throws {
        let repository = MockCardRepository()
        repository.cardsBySuit[.majorArcana] = [
            TarotCard(
                name: "The Fool",
                imageName: "major_00",
                suit: .majorArcana,
                number: 0,
                upright: "New beginnings",
                reversed: "Recklessness"
            ),
            TarotCard(
                name: "The Magician",
                imageName: "major_01",
                suit: .majorArcana,
                number: 1,
                upright: "Manifestation",
                reversed: "Manipulation"
            )
        ]

        let viewModel = CardReferenceViewModel(cardRepository: repository)
        #expect(viewModel.cardCount(for: .majorArcana) == 2)
    }
}
