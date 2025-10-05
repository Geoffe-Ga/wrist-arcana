//
//  DrawCardUseCase.swift
//  WristArcana
//
//  Created by OpenAI Assistant on 2024-05-23.
//

import Foundation
import SwiftData

struct DrawCardUseCase {
    struct Result {
        let card: TarotCard
        let deck: TarotDeck
        let pull: CardPull
        let shouldResetSession: Bool
        let showsStorageWarning: Bool
    }

    typealias ModelContextProvider = () throws -> ModelContext

    private let repository: DeckRepositoryProtocol
    private let storageMonitor: StorageMonitorProtocol
    private let modelContextProvider: ModelContextProvider

    init(
        repository: DeckRepositoryProtocol,
        storageMonitor: StorageMonitorProtocol,
        modelContextProvider: @escaping ModelContextProvider
    ) {
        self.repository = repository
        self.storageMonitor = storageMonitor
        self.modelContextProvider = modelContextProvider
    }

    init(
        repository: DeckRepositoryProtocol,
        storageMonitor: StorageMonitorProtocol,
        modelContext: ModelContext
    ) {
        self.init(
            repository: repository,
            storageMonitor: storageMonitor,
            modelContextProvider: { modelContext }
        )
    }

    @MainActor
    func execute(excluding excludedCardIDs: Set<UUID>) throws -> Result {
        let deck = self.repository.getCurrentDeck()
        let selection = self.selectCard(from: deck, excluding: excludedCardIDs)
        let context = try self.modelContextProvider()

        let pull = CardPull(
            date: Date(),
            cardName: selection.card.name,
            deckName: deck.name,
            cardImageName: selection.card.imageName,
            cardDescription: selection.card.upright
        )

        context.insert(pull)
        try context.save()

        return Result(
            card: selection.card,
            deck: deck,
            pull: pull,
            shouldResetSession: selection.shouldResetSession,
            showsStorageWarning: self.storageMonitor.isNearCapacity()
        )
    }

    private func selectCard(
        from deck: TarotDeck,
        excluding excludedCardIDs: Set<UUID>
    ) -> (card: TarotCard, shouldResetSession: Bool) {
        let filteredCards = deck.cards.filter { !excludedCardIDs.contains($0.id) }
        let shouldReset = excludedCardIDs.count >= deck.cards.count || filteredCards.isEmpty
        let availableCards = shouldReset ? deck.cards : filteredCards

        var generator = SystemRandomNumberGenerator()
        guard let card = availableCards.randomElement(using: &generator) ?? deck.cards.randomElement(using: &generator) else {
            preconditionFailure("Deck must contain at least one card")
        }

        return (card: card, shouldResetSession: shouldReset)
    }
}
