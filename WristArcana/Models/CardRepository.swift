//
//  CardRepository.swift
//  WristArcana
//
//  Created by OpenAI on 10/1/25.
//

import Foundation

protocol CardRepositoryProtocol {
    func getAllCards() -> [TarotCard]
    func getCards(for suit: TarotCard.Suit) -> [TarotCard]
    func getCard(by id: UUID) -> TarotCard?
    func getSuits() -> [TarotCard.Suit]
}

final class CardRepository: CardRepositoryProtocol {
    private var allCards: [TarotCard] = []

    init() {
        loadCards()
    }

    func getAllCards() -> [TarotCard] {
        return allCards.sorted { card1, card2 in
            if card1.suit.sortOrder != card2.suit.sortOrder {
                return card1.suit.sortOrder < card2.suit.sortOrder
            }

            if card1.suit == .majorArcana && card2.suit == .majorArcana {
                return card1.number < card2.number
            }

            if card1.suit == card2.suit {
                return card1.number < card2.number
            }

            return card1.suit.sortOrder < card2.suit.sortOrder
        }
    }

    func getCards(for suit: TarotCard.Suit) -> [TarotCard] {
        return allCards
            .filter { $0.suit == suit }
            .sorted { $0.number < $1.number }
    }

    func getCard(by id: UUID) -> TarotCard? {
        return allCards.first { $0.id == id }
    }

    func getSuits() -> [TarotCard.Suit] {
        return TarotCard.Suit.allCases.sorted { $0.sortOrder < $1.sortOrder }
    }

    private func loadCards() {
        let candidateBundles = [Bundle.main] + Bundle.allBundles

        guard let url = candidateBundles.compactMap({ $0.url(forResource: "DecksData", withExtension: "json") }).first else {
            print("⚠️ DecksData.json not found")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let decksData = try decoder.decode(DecksDataContainer.self, from: data)

            if let firstDeck = decksData.decks.first {
                allCards = firstDeck.cards
            }
        } catch {
            print("⚠️ Failed to load cards: \(error)")
        }
    }
}

private struct DecksDataContainer: Codable {
    let decks: [DeckData]
}

private struct DeckData: Codable {
    let id: String
    let name: String
    let cards: [TarotCard]
}
