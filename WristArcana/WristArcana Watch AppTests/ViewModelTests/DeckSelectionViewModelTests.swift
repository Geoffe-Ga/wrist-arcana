//
//  DeckSelectionViewModelTests.swift
//  WristArcana Watch AppTests
//
//  Created by Claude Code on 11/24/25.
//

import Testing
@testable import WristArcana_Watch_App

@MainActor
struct DeckSelectionViewModelTests {
    // MARK: - Initialization Tests

    @Test func init_loadsDecksFromRepository() async throws {
        let repository = MockDeckRepository()
        let testDeck = TarotDeck(id: "test-deck-id", name: "Test Deck", cards: [])
        repository.decks = [testDeck]

        let viewModel = DeckSelectionViewModel(repository: repository)

        #expect(viewModel.availableDecks.count == 1)
        #expect(viewModel.availableDecks.first?.id == "test-deck-id")
    }

    @Test func init_setsSelectedDeckIdToCurrentDeck() async throws {
        let repository = MockDeckRepository()
        let testDeck = TarotDeck(id: "test-deck-id", name: "Test Deck", cards: [])
        repository.decks = [testDeck]

        let viewModel = DeckSelectionViewModel(repository: repository)

        #expect(viewModel.selectedDeckId == "test-deck-id")
    }

    @Test func init_handlesEmptyDeckList() async throws {
        let repository = MockDeckRepository()
        repository.decks = []
        repository.shouldFail = false

        let viewModel = DeckSelectionViewModel(repository: repository)

        #expect(viewModel.availableDecks.isEmpty)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func init_handlesRepositoryError() async throws {
        let repository = MockDeckRepository()
        repository.shouldFail = true

        let viewModel = DeckSelectionViewModel(repository: repository)

        #expect(viewModel.availableDecks.isEmpty)
        #expect(viewModel.errorMessage == "Failed to load decks")
    }

    // MARK: - Load Decks Tests

    @Test func loadDecks_populatesAvailableDecks() async throws {
        let repository = MockDeckRepository()
        repository.decks = []

        let viewModel = DeckSelectionViewModel(repository: repository)
        #expect(viewModel.availableDecks.isEmpty)

        // Now add decks and reload
        let testDeck = TarotDeck(id: "test-deck-id", name: "Test Deck", cards: [])
        repository.decks = [testDeck]
        viewModel.loadDecks()

        #expect(viewModel.availableDecks.count == 1)
        #expect(viewModel.availableDecks.first?.id == "test-deck-id")
    }

    @Test func loadDecks_updatesSelectedDeckId() async throws {
        let repository = MockDeckRepository()
        let testDeck = TarotDeck(id: "test-deck-id", name: "Test Deck", cards: [])
        repository.decks = [testDeck]

        let viewModel = DeckSelectionViewModel(repository: repository)

        viewModel.loadDecks()

        #expect(viewModel.selectedDeckId == "test-deck-id")
    }

    @Test func loadDecks_setsErrorMessageOnFailure() async throws {
        let repository = MockDeckRepository()
        let testDeck = TarotDeck(id: "test-deck-id", name: "Test Deck", cards: [])
        repository.decks = [testDeck]

        let viewModel = DeckSelectionViewModel(repository: repository)
        #expect(viewModel.errorMessage == nil)

        // Trigger error
        repository.shouldFail = true
        viewModel.loadDecks()

        #expect(viewModel.errorMessage == "Failed to load decks")
        #expect(viewModel.availableDecks.isEmpty)
    }

    @Test func loadDecks_clearsErrorMessageOnSuccess() async throws {
        let repository = MockDeckRepository()
        repository.shouldFail = true

        let viewModel = DeckSelectionViewModel(repository: repository)
        #expect(viewModel.errorMessage == "Failed to load decks")

        // Fix error and reload
        repository.shouldFail = false
        let testDeck = TarotDeck(id: "test-deck-id", name: "Test Deck", cards: [])
        repository.decks = [testDeck]
        viewModel.loadDecks()

        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.availableDecks.count == 1)
    }

    // MARK: - Select Deck Tests

    @Test func selectDeck_updatesSelectedDeckId() async throws {
        let repository = MockDeckRepository()
        let testDeck = TarotDeck(id: "test-deck-id", name: "Test Deck", cards: [])
        repository.decks = [testDeck]

        let viewModel = DeckSelectionViewModel(repository: repository)
        #expect(viewModel.selectedDeckId == "test-deck-id")

        viewModel.selectDeck("future-deck-id")

        #expect(viewModel.selectedDeckId == "future-deck-id")
    }

    @Test func selectDeck_allowsNilSelection() async throws {
        let repository = MockDeckRepository()
        let testDeck = TarotDeck(id: "test-deck-id", name: "Test Deck", cards: [])
        repository.decks = [testDeck]

        let viewModel = DeckSelectionViewModel(repository: repository)
        #expect(viewModel.selectedDeckId != nil)

        viewModel.selectedDeckId = nil

        #expect(viewModel.selectedDeckId == nil)
    }

    @Test func selectDeck_canChangeDeckMultipleTimes() async throws {
        let repository = MockDeckRepository()
        let testDeck = TarotDeck(id: "test-deck-id", name: "Test Deck", cards: [])
        repository.decks = [testDeck]

        let viewModel = DeckSelectionViewModel(repository: repository)

        viewModel.selectDeck("deck1")
        #expect(viewModel.selectedDeckId == "deck1")

        viewModel.selectDeck("deck2")
        #expect(viewModel.selectedDeckId == "deck2")

        viewModel.selectDeck("deck3")
        #expect(viewModel.selectedDeckId == "deck3")
    }

    // MARK: - Integration Tests

    @Test func fullWorkflow_loadSelectReload() async throws {
        let repository = MockDeckRepository()
        let testDeck = TarotDeck(id: "test-deck-id", name: "Test Deck", cards: [])
        repository.decks = [testDeck]

        let viewModel = DeckSelectionViewModel(repository: repository)

        // Initial state
        #expect(viewModel.availableDecks.count == 1)
        #expect(viewModel.selectedDeckId == "test-deck-id")

        // Select different deck
        viewModel.selectDeck("other-deck")
        #expect(viewModel.selectedDeckId == "other-deck")

        // Reload decks
        viewModel.loadDecks()
        #expect(viewModel.availableDecks.count == 1)
        // Selection is reset to current deck after reload
        #expect(viewModel.selectedDeckId == "test-deck-id")
    }
}
