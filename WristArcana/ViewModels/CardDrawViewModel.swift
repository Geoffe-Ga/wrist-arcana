//
//  CardDrawViewModel.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import AppIntents
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

    private let drawCardUseCase: DrawCardUseCase
    private let shouldDonateShortcut: Bool
    private var drawnCardsThisSession: Set<UUID> = []

    // MARK: - Initialization

    init(drawCardUseCase: DrawCardUseCase, donateShortcut: Bool = true) {
        self.drawCardUseCase = drawCardUseCase
        self.shouldDonateShortcut = donateShortcut
    }

    convenience init(
        repository: DeckRepositoryProtocol,
        storageMonitor: StorageMonitorProtocol,
        modelContext: ModelContext,
        donateShortcut: Bool = true
    ) {
        let useCase = DrawCardUseCase(
            repository: repository,
            storageMonitor: storageMonitor,
            modelContext: modelContext
        )
        self.init(drawCardUseCase: useCase, donateShortcut: donateShortcut)
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
            let result = try self.drawCardUseCase.execute(excluding: self.drawnCardsThisSession)

            if result.shouldResetSession {
                self.drawnCardsThisSession.removeAll()
            }

            self.currentCard = result.card
            self.currentCardPull = result.pull
            self.drawnCardsThisSession.insert(result.card.id)
            self.showsStorageWarning = result.showsStorageWarning

            // Haptic feedback
            WKInterfaceDevice.current().play(.click)

            self.donateShortcut()
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

    private func donateShortcut() {
        guard self.shouldDonateShortcut, #available(watchOS 10.0, *), self.currentCard != nil else {
            return
        }

        Task {
            try? await DrawTarotCardIntent().donate()
        }
    }
}
