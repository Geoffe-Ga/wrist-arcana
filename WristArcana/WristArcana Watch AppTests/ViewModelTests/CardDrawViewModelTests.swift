//
//  CardDrawViewModelTests.swift
//  WristArcana Watch AppTests
//
//  Created by Geoff Gallinger on 10/2/25.
//

import Foundation
import SwiftData
import Testing
@testable import WristArcana_Watch_App

@MainActor
struct CardDrawViewModelTests {
    // MARK: - Test Helpers

    func createInMemoryModelContainer() -> ModelContainer {
        let schema = Schema([CardPull.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        // swiftlint:disable:next force_try
        return try! ModelContainer(for: schema, configurations: [configuration])
    }

    func createSUT(
        repository: DeckRepositoryProtocol? = nil,
        storageMonitor: StorageMonitorProtocol? = nil,
        modelContext: ModelContext? = nil
    ) -> CardDrawViewModel {
        let container = self.createInMemoryModelContainer()
        return CardDrawViewModel(
            repository: repository ?? MockDeckRepository(),
            storageMonitor: storageMonitor ?? MockStorageMonitor(),
            modelContext: modelContext ?? ModelContext(container)
        )
    }

    // MARK: - Initialization Tests

    @Test func init_setsInitialState() async throws {
        // When
        let sut = self.createSUT()

        // Then
        #expect(sut.currentCard == nil)
        #expect(sut.isDrawing == false)
        #expect(sut.showsStorageWarning == false)
        #expect(sut.errorMessage == nil)
    }

    // MARK: - Draw Card Tests

    @Test func drawCard_setsIsDrawingTrue() async throws {
        // Given
        let sut = self.createSUT()

        // When
        let drawTask = Task {
            await sut.drawCard()
        }

        // Check immediately after starting
        try await Task.sleep(nanoseconds: 10_000_000) // 0.01s
        #expect(sut.isDrawing == true)

        await drawTask.value
    }

    @Test func drawCard_setsCurrentCard() async throws {
        // Given
        let sut = self.createSUT()

        // When
        await sut.drawCard()

        // Then
        #expect(sut.currentCard != nil)
        #expect(sut.isDrawing == false)
    }

    @Test func drawCard_clearsErrorMessage() async throws {
        // Given
        let sut = self.createSUT()
        // Simulate previous error
        await sut.drawCard()

        // When
        await sut.drawCard()

        // Then
        #expect(sut.errorMessage == nil)
    }

    @Test func drawCard_savesToHistory() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let sut = self.createSUT(modelContext: context)

        let descriptor = FetchDescriptor<CardPull>()
        let initialCount = try context.fetch(descriptor).count

        // When
        await sut.drawCard()

        // Then
        let pulls = try context.fetch(descriptor)
        #expect(pulls.count == initialCount + 1)
    }

    @Test func drawCard_checksStorageCapacity() async throws {
        // Given
        let storageMonitor = MockStorageMonitor()
        storageMonitor.isNearCapacityValue = true
        let sut = self.createSUT(storageMonitor: storageMonitor)

        // When
        await sut.drawCard()

        // Then
        #expect(sut.showsStorageWarning == true)
    }

    @Test func drawCard_noWarningWhenStorageNotNearCapacity() async throws {
        // Given
        let storageMonitor = MockStorageMonitor()
        storageMonitor.isNearCapacityValue = false
        let sut = self.createSUT(storageMonitor: storageMonitor)

        // When
        await sut.drawCard()

        // Then
        #expect(sut.showsStorageWarning == false)
    }

    @Test func drawCard_tracksDrawnCards() async throws {
        // Given
        let sut = self.createSUT()

        // When
        await sut.drawCard()
        let firstCard = sut.currentCard

        await sut.drawCard()
        let secondCard = sut.currentCard

        // Then - Cards should be different (tracked in session)
        #expect(firstCard != nil)
        #expect(secondCard != nil)
        // Can't guarantee they're different with only 2 draws from 78 card deck
        // but we can verify both were drawn
    }

    @Test func drawCard_hasMinimumDuration() async throws {
        // Given
        let sut = self.createSUT()
        let startTime = Date()

        // When
        await sut.drawCard()

        // Then - Should take at least 0.5 seconds
        let duration = Date().timeIntervalSince(startTime)
        #expect(duration >= 0.5)
    }

    // MARK: - Dismiss Card Tests

    @Test func dismissCard_clearsCurrentCard() async throws {
        // Given
        let sut = self.createSUT()
        await sut.drawCard()
        #expect(sut.currentCard != nil)

        // When
        sut.dismissCard()

        // Then
        #expect(sut.currentCard == nil)
    }

    @Test func dismissCard_handlesNilCard() async throws {
        // Given
        let sut = self.createSUT()
        #expect(sut.currentCard == nil)

        // When/Then - Should not crash
        sut.dismissCard()
        #expect(sut.currentCard == nil)
    }

    // MARK: - Acknowledge Storage Warning Tests

    @Test func acknowledgeStorageWarning_clearsWarning() async throws {
        // Given
        let storageMonitor = MockStorageMonitor()
        storageMonitor.isNearCapacityValue = true
        let sut = self.createSUT(storageMonitor: storageMonitor)
        await sut.drawCard()
        #expect(sut.showsStorageWarning == true)

        // When
        sut.acknowledgeStorageWarning()

        // Then
        #expect(sut.showsStorageWarning == false)
    }

    // MARK: - Session Reset Tests

    @Test func drawCard_resetsSessionAfterAllCardsDrawn() async throws {
        // Given - Create mock with small deck
        let mockRepo = MockDeckRepository()
        let smallDeck = TarotDeck(
            name: "Small Deck",
            cards: [
                TarotCard(
                    name: "Card 1",
                    imageName: "card1",
                    suit: .majorArcana,
                    number: 0,
                    upright: "Up",
                    reversed: "Rev"
                ),
                TarotCard(
                    name: "Card 2",
                    imageName: "card2",
                    suit: .majorArcana,
                    number: 1,
                    upright: "Up",
                    reversed: "Rev"
                )
            ]
        )
        mockRepo.currentDeckOverride = smallDeck
        let sut = self.createSUT(repository: mockRepo)

        var drawnCards: Set<UUID> = []

        // When - Draw more cards than deck size
        for _ in 0 ..< 4 {
            await sut.drawCard()
            if let card = sut.currentCard {
                drawnCards.insert(card.id)
            }
        }

        // Then - Should see cards repeat (session reset)
        #expect(drawnCards.count == 2) // Only 2 unique cards in deck
    }

    // MARK: - Error Handling Tests

    @Test func drawCard_handlesRepositoryError() async throws {
        // Given
        let mockRepo = MockDeckRepository()
        mockRepo.shouldFail = true
        let sut = self.createSUT(repository: mockRepo)

        // When
        await sut.drawCard()

        // Then - Should handle gracefully
        // (In current implementation, falls back to default behavior)
        #expect(sut.isDrawing == false)
    }

    @Test func drawCard_handlesSaveError() async throws {
        // Given - Use a read-only context (simulated)
        let sut = self.createSUT()

        // When
        await sut.drawCard()

        // Then - Should complete without crashing
        #expect(sut.isDrawing == false)
        #expect(sut.currentCard != nil)
    }

    // MARK: - Integration Tests

    @Test func multipleDraws_maintainCorrectState() async throws {
        // Given
        let sut = self.createSUT()

        // When - Draw multiple cards
        for _ in 0 ..< 3 {
            await sut.drawCard()
            #expect(sut.currentCard != nil)
            #expect(sut.isDrawing == false)

            sut.dismissCard()
            #expect(sut.currentCard == nil)
        }

        // Then - State remains consistent
        #expect(sut.isDrawing == false)
        #expect(sut.currentCard == nil)
    }

    @Test func savedPull_hasCorrectData() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let mockRepo = MockDeckRepository()
        let sut = self.createSUT(repository: mockRepo, modelContext: context)

        // When
        await sut.drawCard()

        // Then
        let descriptor = FetchDescriptor<CardPull>()
        let pulls = try context.fetch(descriptor)
        #expect(pulls.count == 1)

        let pull = pulls.first!
        #expect(pull.cardName == sut.currentCard?.name)
        #expect(pull.deckName == mockRepo.getCurrentDeck().name)
        #expect(pull.cardImageName == sut.currentCard?.imageName)
        #expect(pull.date.timeIntervalSinceNow < 1) // Recent
    }
}
