//
//  HistoryViewModelTests.swift
//  WristArcana Watch AppTests
//
//  Created by Geoff Gallinger on 10/2/25.
//

import Foundation
import SwiftData
import Testing
@testable import WristArcana_Watch_App

@MainActor
struct HistoryViewModelTests {
    // MARK: - Test Helpers

    func createInMemoryModelContainer() -> ModelContainer {
        let schema = Schema([CardPull.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        // swiftlint:disable:next force_try
        return try! ModelContainer(for: schema, configurations: [configuration])
    }

    func createSamplePull(
        date: Date = Date(),
        cardName: String = "The Fool",
        deckName: String = "Rider-Waite",
        imageName: String = "major_00"
    ) -> CardPull {
        CardPull(
            date: date,
            cardName: cardName,
            deckName: deckName,
            cardImageName: imageName
        )
    }

    // MARK: - Initialization Tests

    @Test func init_setsPropertiesCorrectly() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()

        // When
        let sut = HistoryViewModel(modelContext: context, storageMonitor: storageMonitor)

        // Allow initialization to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s

        // Then
        #expect(sut.pulls.isEmpty)
        #expect(sut.showsPruningAlert == false)
    }

    @Test func init_loadsExistingHistory() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()

        // Add some pulls to context
        let pull1 = self.createSamplePull(cardName: "Card 1")
        let pull2 = self.createSamplePull(cardName: "Card 2")
        context.insert(pull1)
        context.insert(pull2)
        try context.save()

        // When
        let sut = HistoryViewModel(modelContext: context, storageMonitor: storageMonitor)
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s

        // Then
        #expect(sut.pulls.count == 2)
    }

    // MARK: - Load History Tests

    @Test func loadHistory_fetchesPullsFromContext() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()
        let sut = HistoryViewModel(modelContext: context, storageMonitor: storageMonitor)

        // Add pulls
        let pull = self.createSamplePull()
        context.insert(pull)
        try context.save()

        // When
        await sut.loadHistory()

        // Then
        #expect(sut.pulls.count == 1)
        #expect(sut.pulls.first?.cardName == "The Fool")
    }

    @Test func loadHistory_sortsNewestFirst() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()
        let sut = HistoryViewModel(modelContext: context, storageMonitor: storageMonitor)

        let oldDate = Date().addingTimeInterval(-86_400) // 1 day ago
        let newDate = Date()

        let oldPull = self.createSamplePull(date: oldDate, cardName: "Old Card")
        let newPull = self.createSamplePull(date: newDate, cardName: "New Card")
        context.insert(oldPull)
        context.insert(newPull)
        try context.save()

        // When
        await sut.loadHistory()

        // Then
        #expect(sut.pulls.count == 2)
        #expect(sut.pulls.first?.cardName == "New Card")
        #expect(sut.pulls.last?.cardName == "Old Card")
    }

    @Test func loadHistory_limitsTo100Pulls() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()
        let sut = HistoryViewModel(modelContext: context, storageMonitor: storageMonitor)

        // Add 150 pulls
        for index in 0 ..< 150 {
            let pull = self.createSamplePull(cardName: "Card \(index)")
            context.insert(pull)
        }
        try context.save()

        // When
        await sut.loadHistory()

        // Then
        #expect(sut.pulls.count == 100)
    }

    @Test func loadHistory_handlesEmptyContext() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()
        let sut = HistoryViewModel(modelContext: context, storageMonitor: storageMonitor)

        // When
        await sut.loadHistory()

        // Then
        #expect(sut.pulls.isEmpty)
    }

    // MARK: - Delete Pull Tests

    @Test func deletePull_removesPullFromContext() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()
        let sut = HistoryViewModel(modelContext: context, storageMonitor: storageMonitor)

        let pull = self.createSamplePull()
        context.insert(pull)
        try context.save()
        await sut.loadHistory()

        #expect(sut.pulls.count == 1)

        // When
        sut.deletePull(pull)
        try await Task.sleep(nanoseconds: 100_000_000) // Wait for reload

        // Then
        #expect(sut.pulls.isEmpty)
    }

    @Test func deletePull_reloadsHistory() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()
        let sut = HistoryViewModel(modelContext: context, storageMonitor: storageMonitor)

        let pull1 = self.createSamplePull(cardName: "Card 1")
        let pull2 = self.createSamplePull(cardName: "Card 2")
        context.insert(pull1)
        context.insert(pull2)
        try context.save()
        await sut.loadHistory()

        #expect(sut.pulls.count == 2)

        // When
        sut.deletePull(pull1)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then
        #expect(sut.pulls.count == 1)
        #expect(sut.pulls.first?.cardName == "Card 2")
    }

    // MARK: - Storage Check Tests

    @Test func checkStorage_setsAlertWhenNearCapacity() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()
        storageMonitor.isNearCapacityValue = true
        let sut = HistoryViewModel(modelContext: context, storageMonitor: storageMonitor)

        // When
        await sut.checkStorageAndPruneIfNeeded()

        // Then
        #expect(sut.showsPruningAlert == true)
    }

    @Test func checkStorage_doesNotSetAlertWhenNotNearCapacity() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()
        storageMonitor.isNearCapacityValue = false
        let sut = HistoryViewModel(modelContext: context, storageMonitor: storageMonitor)

        // When
        await sut.checkStorageAndPruneIfNeeded()

        // Then
        #expect(sut.showsPruningAlert == false)
    }

    // MARK: - Prune Tests

    @Test func pruneOldestPulls_removesSpecifiedCount() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()
        let sut = HistoryViewModel(modelContext: context, storageMonitor: storageMonitor)

        // Add 100 pulls
        for index in 0 ..< 100 {
            let date = Date().addingTimeInterval(TimeInterval(index * 60)) // 1 min apart
            let pull = self.createSamplePull(date: date, cardName: "Card \(index)")
            context.insert(pull)
        }
        try context.save()
        await sut.loadHistory()

        #expect(sut.pulls.count == 100)

        // When
        await sut.pruneOldestPulls(count: 30)

        // Then
        #expect(sut.pulls.count == 70)
    }

    @Test func pruneOldestPulls_removesOldestFirst() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()
        let sut = HistoryViewModel(modelContext: context, storageMonitor: storageMonitor)

        let oldDate = Date().addingTimeInterval(-86_400) // 1 day ago
        let newDate = Date()

        let oldPull = self.createSamplePull(date: oldDate, cardName: "Old Card")
        let newPull = self.createSamplePull(date: newDate, cardName: "New Card")
        context.insert(oldPull)
        context.insert(newPull)
        try context.save()
        await sut.loadHistory()

        // When
        await sut.pruneOldestPulls(count: 1)

        // Then
        #expect(sut.pulls.count == 1)
        #expect(sut.pulls.first?.cardName == "New Card")
    }

    @Test func pruneOldestPulls_clearsAlert() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()
        storageMonitor.isNearCapacityValue = true
        let sut = HistoryViewModel(modelContext: context, storageMonitor: storageMonitor)

        await sut.checkStorageAndPruneIfNeeded()
        #expect(sut.showsPruningAlert == true)

        let pull = self.createSamplePull()
        context.insert(pull)
        try context.save()

        // When
        await sut.pruneOldestPulls(count: 1)

        // Then
        #expect(sut.showsPruningAlert == false)
    }

    @Test func pruneOldestPulls_usesDefaultCount50() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()
        let sut = HistoryViewModel(modelContext: context, storageMonitor: storageMonitor)

        // Add 100 pulls
        for index in 0 ..< 100 {
            let pull = self.createSamplePull(cardName: "Card \(index)")
            context.insert(pull)
        }
        try context.save()
        await sut.loadHistory()

        // When
        await sut.pruneOldestPulls() // Default count = 50

        // Then
        #expect(sut.pulls.count == 50)
    }

    @Test func pruneOldestPulls_handlesCountLargerThanTotal() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()
        let sut = HistoryViewModel(modelContext: context, storageMonitor: storageMonitor)

        // Add 10 pulls
        for index in 0 ..< 10 {
            let pull = self.createSamplePull(cardName: "Card \(index)")
            context.insert(pull)
        }
        try context.save()
        await sut.loadHistory()

        // When
        await sut.pruneOldestPulls(count: 100) // More than available

        // Then
        #expect(sut.pulls.isEmpty)
    }
}
