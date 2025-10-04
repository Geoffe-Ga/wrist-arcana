//
//  DrawCardViewAddNoteHandlerTests.swift
//  WristArcana Watch AppTests
//
//  Created by OpenAI Assistant on 3/6/24.
//

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
    func makeAddNoteHandler_startsNoteEditorAndDismissesCard() async throws {
        // Given
        let container = self.createInMemoryModelContainer()
        let context = ModelContext(container)
        let storageMonitor = MockStorageMonitor()
        let historyViewModel = HistoryViewModel(
            modelContext: context,
            storageMonitor: storageMonitor
        )
        try await Task.sleep(nanoseconds: 50_000_000)

        let pull = self.createSamplePull()
        context.insert(pull)
        try context.save()

        var dismissCount = 0
        let handler = makeAddNoteHandler(historyViewModel: historyViewModel) {
            dismissCount += 1
        }

        // When
        handler(pull)

        // Then
        #expect(historyViewModel.showsNoteEditor == true)
        #expect(historyViewModel.selectedPull?.id == pull.id)
        #expect(dismissCount == 1)
    }
}
