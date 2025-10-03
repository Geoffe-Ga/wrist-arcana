//
//  MockCardRepository.swift
//  WristArcana Watch AppTests
//
//  Created by OpenAI on 10/1/25.
//

import Foundation
@testable import WristArcana_Watch_App

final class MockCardRepository: CardRepositoryProtocol {
    var suits: [TarotCard.Suit] = TarotCard.Suit.allCases
    var cardsBySuit: [TarotCard.Suit: [TarotCard]] = [:]

    init() {
        let sampleCard = TarotCard(
            name: "The Fool",
            imageName: "major_00",
            suit: .majorArcana,
            number: 0,
            upright: "New beginnings",
            reversed: "Recklessness",
            keywords: ["Beginnings"]
        )
        cardsBySuit[.majorArcana] = [sampleCard]
    }

    func getAllCards() -> [TarotCard] {
        suits.flatMap { cardsBySuit[$0] ?? [] }
    }

    func getCards(for suit: TarotCard.Suit) -> [TarotCard] {
        cardsBySuit[suit] ?? []
    }

    func getCard(by id: UUID) -> TarotCard? {
        getAllCards().first { $0.id == id }
    }

    func getSuits() -> [TarotCard.Suit] {
        suits
    }
}
