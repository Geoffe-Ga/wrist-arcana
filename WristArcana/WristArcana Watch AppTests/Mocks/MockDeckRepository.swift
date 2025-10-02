//
//  MockDeckRepository.swift
//  WristArcana Watch AppTests
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation
@testable import WristArcana_Watch_App

final class MockDeckRepository: DeckRepositoryProtocol {
    // MARK: - Mock Properties

    var decks: [TarotDeck] = []
    var shouldFail = false
    var currentDeckOverride: TarotDeck?

    // MARK: - Protocol Implementation

    func loadDecks() throws -> [TarotDeck] {
        if self.shouldFail {
            throw DeckError.loadFailed
        }
        return self.decks
    }

    func getCurrentDeck() -> TarotDeck {
        if let override = currentDeckOverride {
            return override
        }
        return self.decks.first ?? TarotDeck.riderWaite
    }

    func getRandomCard(from deck: TarotDeck) -> TarotCard {
        guard let card = deck.cards.first else {
            fatalError("Mock deck has no cards")
        }
        return card
    }
}
