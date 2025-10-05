//
//  CardDrawViewModel.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation
import SwiftData
import WatchKit

@MainActor
final class CardDrawViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var currentCard: TarotCard?
    @Published var currentCardPull: CardPull?
    @Published var isDrawing: Bool = false
    @Published var showsStorageWarning: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private let repository: DeckRepositoryProtocol
    private let storageMonitor: StorageMonitorProtocol
    private let modelContext: ModelContext
    private var drawnCardsThisSession: Set<UUID> = []

    // MARK: - Initialization

    init(
        repository: DeckRepositoryProtocol,
        storageMonitor: StorageMonitorProtocol,
        modelContext: ModelContext
    ) {
        self.repository = repository
        self.storageMonitor = storageMonitor
        self.modelContext = modelContext
    }

    // MARK: - Public Methods

    /// Draws a random card from the current deck and saves to history.
    ///
    /// This method ensures no card repeats within a session until all cards are drawn.
    /// Uses cryptographically secure randomization for fairness.
    ///
    /// - Note: Includes minimum 0.5s delay for UX anticipation
    func drawCard() async {
        self.isDrawing = true
        self.errorMessage = nil

        // Add minimum 0.5s delay for anticipation/animation
        try? await Task.sleep(nanoseconds: AppConstants.minimumDrawDuration)

        do {
            let deck = self.repository.getCurrentDeck()
            let card = self.selectRandomCard(from: deck)

            self.currentCard = card
            self.drawnCardsThisSession.insert(card.id)

            // Save to history
            try await self.saveToHistory(card: card, deck: deck)

            // Check storage
            if self.storageMonitor.isNearCapacity() {
                self.showsStorageWarning = true
            }

            // Haptic feedback
            WKInterfaceDevice.current().play(.click)
        } catch {
            self.errorMessage = "Failed to draw card. Please try again."
        }

        self.isDrawing = false
    }

    func dismissCard() {
        self.currentCard = nil
        self.currentCardPull = nil
    }

    func acknowledgeStorageWarning() {
        self.showsStorageWarning = false
    }

    // MARK: - Private Methods

    private func selectRandomCard(from deck: TarotDeck) -> TarotCard {
        // If all cards drawn this session, reset
        if self.drawnCardsThisSession.count >= deck.cards.count {
            self.drawnCardsThisSession.removeAll()
        }

        // Get undrawn cards
        let availableCards = deck.cards.filter { !self.drawnCardsThisSession.contains($0.id) }

        // Use cryptographically secure randomization
        var generator = SystemRandomNumberGenerator()
        guard let card = availableCards.randomElement(using: &generator) else {
            // Fallback to any card if something goes wrong
            return deck.cards.randomElement(using: &generator) ?? deck.cards[0]
        }
        return card
    }

    private func saveToHistory(card: TarotCard, deck: TarotDeck) async throws {
        let pull = CardPull(
            date: Date(),
            cardName: card.name,
            deckName: deck.name,
            cardImageName: card.imageName,
            cardDescription: card.upright
        )

        self.modelContext.insert(pull)
        try self.modelContext.save()

        // Store reference to the saved pull for note-taking
        self.currentCardPull = pull

        NotificationCenter.default.post(name: .cardPullHistoryDidChange, object: nil)
    }
}
