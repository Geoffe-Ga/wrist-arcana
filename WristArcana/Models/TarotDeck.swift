//
//  TarotDeck.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation

struct TarotDeck: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let cards: [TarotCard]

    var cardCount: Int {
        self.cards.count
    }

    init(id: String = UUID().uuidString, name: String, cards: [TarotCard]) {
        self.id = id
        self.name = name
        self.cards = cards
    }

    // Static helper for Rider-Waite deck
    static var riderWaite: TarotDeck {
        TarotDeck(
            id: UUID().uuidString,
            name: "Rider-Waite",
            cards: []
        )
    }

    // Minimal fallback deck with one card to prevent crashes
    static var fallback: TarotDeck {
        TarotDeck(
            id: "fallback",
            name: "Emergency Deck",
            cards: [
                TarotCard(
                    name: "The Fool",
                    imageName: "major_00",
                    suit: .majorArcana,
                    number: 0,
                    upright: "New beginnings, optimism, trust in life. The universe is ready to support your journey.",
                    reversed: "Recklessness, taken advantage of, inconsideration. Pause before leaping.",
                    keywords: ["beginnings", "innocence", "spontaneity", "free spirit"]
                )
            ]
        )
    }
}
