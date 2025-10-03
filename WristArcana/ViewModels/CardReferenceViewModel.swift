//
//  CardReferenceViewModel.swift
//  WristArcana
//
//  Created by OpenAI on 10/1/25.
//

import Foundation
import SwiftUI

@MainActor
final class CardReferenceViewModel: ObservableObject {
    @Published var suits: [TarotCard.Suit] = []
    @Published var selectedSuit: TarotCard.Suit?
    @Published var cardsInSuit: [TarotCard] = []
    @Published var selectedCard: TarotCard?

    private let cardRepository: CardRepositoryProtocol

    init(cardRepository: CardRepositoryProtocol = CardRepository()) {
        self.cardRepository = cardRepository
        loadSuits()
    }

    func loadSuits() {
        suits = cardRepository.getSuits()
    }

    func selectSuit(_ suit: TarotCard.Suit) {
        selectedSuit = suit
        cardsInSuit = cardRepository.getCards(for: suit)
    }

    func selectCard(_ card: TarotCard) {
        selectedCard = card
    }

    func deselectCard() {
        selectedCard = nil
    }

    func cardCount(for suit: TarotCard.Suit) -> Int {
        return cardRepository.getCards(for: suit).count
    }
}
