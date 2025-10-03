import XCTest
import SwiftData
@testable import WristArcana

@MainActor
final class HistoryViewModelTests: XCTestCase {
    var sut: HistoryViewModel!
    var mockStorage: MockStorageMonitor!
    var mockContext: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        mockStorage = MockStorageMonitor()

        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: CardPull.self, configurations: configuration)
        mockContext = ModelContext(container)

        sut = HistoryViewModel(modelContext: mockContext, storageMonitor: mockStorage)
    }

    override func tearDown() {
        sut = nil
        mockStorage = nil
        mockContext = nil
        super.tearDown()
    }

    func test_loadHistory_fetchesAllPulls() async throws {
        let pull1 = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings"
        )
        let pull2 = CardPull(
            cardName: "The Magician",
            deckName: "Rider-Waite",
            cardImageName: "major_01",
            cardDescription: "Manifestation"
        )

        mockContext.insert(pull1)
        mockContext.insert(pull2)
        try mockContext.save()

        await sut.loadHistory()

        XCTAssertEqual(sut.pulls.count, 2)
    }

    func test_saveNote_addsNoteToCardPull() async throws {
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings"
        )
        mockContext.insert(pull)
        try mockContext.save()

        sut.startAddingNote(to: pull)
        sut.editingNote = "This was a powerful reading"

        sut.saveNote()

        XCTAssertEqual(pull.note, "This was a powerful reading")
    }

    func test_saveNote_sanitizesInput() async throws {
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings"
        )
        mockContext.insert(pull)
        try mockContext.save()

        sut.startAddingNote(to: pull)
        sut.editingNote = "  Whitespace test  "

        sut.saveNote()

        XCTAssertEqual(pull.note, "Whitespace test")
    }

    func test_saveNote_removesNoteIfEmpty() async throws {
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: "Existing note"
        )
        mockContext.insert(pull)
        try mockContext.save()

        sut.startAddingNote(to: pull)
        sut.editingNote = "   "

        sut.saveNote()

        XCTAssertNil(pull.note)
    }

    func test_deleteNote_removesNoteFromPull() async throws {
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: "Note to delete"
        )
        mockContext.insert(pull)
        try mockContext.save()

        sut.deleteNote(from: pull)

        XCTAssertNil(pull.note)
    }

    func test_deletePull_removesFromDatabase() async throws {
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings"
        )
        mockContext.insert(pull)
        try mockContext.save()

        await sut.loadHistory()
        XCTAssertEqual(sut.pulls.count, 1)

        sut.deletePull(pull)

        await sut.loadHistory()
        XCTAssertEqual(sut.pulls.count, 0)
    }
}
