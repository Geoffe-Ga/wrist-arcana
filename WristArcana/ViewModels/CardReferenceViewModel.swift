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
        self.loadSuits()
    }

    func loadSuits() {
        self.suits = self.cardRepository.getSuits()
    }

    func selectSuit(_ suit: TarotCard.Suit) {
        self.selectedSuit = suit
        self.cardsInSuit = self.cardRepository.getCards(for: suit)
    }

    func selectCard(_ card: TarotCard) {
        self.selectedCard = card
    }

    func deselectCard() {
        self.selectedCard = nil
    }

    func cardCount(for suit: TarotCard.Suit) -> Int {
        self.cardRepository.getCards(for: suit).count
    }
}
