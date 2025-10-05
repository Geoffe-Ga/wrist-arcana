//
//  DrawCardViewAddNoteHandlerTests.swift
//  WristArcana Watch AppTests
//
//  Created by OpenAI Assistant on 3/6/24.
//

import Foundation
import SwiftData
import Testing
@testable import WristArcana_Watch_App

@MainActor
struct DrawCardViewAddNoteHandlerTests {
    // MARK: - Helpers

    func createInMemoryModelContainer() -> ModelContainer {
        let schema = Schema([CardPull.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        // swiftlint:disable:next force_try
        return try! ModelContainer(for: schema, configurations: [configuration])
    }

    func createSamplePull(note: String? = nil) -> CardPull {
        CardPull(
            date: Date(),
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: note
        )
    }

    // MARK: - Tests

    @Test
    func makeAddNoteHandler_stagesPendingPullAndDismissesCard() {
        // Given
        let pull = self.createSamplePull()
        var stagedPullID: UUID?
        var dismissCount = 0

        let handler = makeAddNoteHandler(
            stageNote: { stagedPullID = $0.id },
            dismissCard: { dismissCount += 1 }
        )

        // When
        handler(pull)

        // Then
        #expect(stagedPullID == pull.id)
        #expect(dismissCount == 1)
    }

    @Test
    func drainPendingNotePull_returnsPullAndClearsState() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()
        let historyViewModel = HistoryViewModel(
            modelContext: context,
            storageMonitor: storageMonitor
        )
        try await Task.sleep(nanoseconds: 50_000_000)

        var pendingPull: CardPull? = self.createSamplePull()
        let originalID = pendingPull?.id

        // When
        let drained = drainPendingNotePull(&pendingPull)

        // Then
        #expect(drained?.id == originalID)
        #expect(drained != nil)
        #expect(pendingPull == nil)

        if let drained {
            historyViewModel.startAddingNote(to: drained)
        }

        #expect(historyViewModel.showsNoteEditor == true)
        #expect(historyViewModel.selectedPull?.id == originalID)
    }

    @Test
    func drainPendingNotePull_withNoPendingPullReturnsNil() {
        // Given
        var pendingPull: CardPull?

        // When
        let drained = drainPendingNotePull(&pendingPull)

        // Then
        #expect(drained == nil)
        #expect(pendingPull == nil)
    }
}
