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
}
