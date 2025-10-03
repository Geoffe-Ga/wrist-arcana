import XCTest
import SwiftData
@testable import WristArcana

final class CardPullTests: XCTestCase {
    func test_hasNote_returnsTrueWhenNoteExists() {
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: "Great reading!"
        )

        XCTAssertTrue(pull.hasNote)
    }

    func test_hasNote_returnsFalseWhenNoteIsNil() {
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: nil
        )

        XCTAssertFalse(pull.hasNote)
    }

    func test_hasNote_returnsFalseWhenNoteIsEmpty() {
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: "   "
        )

        XCTAssertFalse(pull.hasNote)
    }

    func test_truncatedNote_returnsFullNoteWhenShort() {
        let shortNote = "Short note"
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: shortNote
        )

        XCTAssertEqual(pull.truncatedNote, shortNote)
    }

    func test_truncatedNote_truncatesLongNote() {
        let longNote = String(repeating: "a", count: 100)
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: longNote
        )

        XCTAssertNotNil(pull.truncatedNote)
        XCTAssertTrue(pull.truncatedNote?.hasSuffix("...") ?? false)
        XCTAssertLessThanOrEqual(pull.truncatedNote?.count ?? 0, 83)
    }

    func test_truncatedNote_returnsNilWhenNoNote() {
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings",
            note: nil
        )

        XCTAssertNil(pull.truncatedNote)
    }
}
