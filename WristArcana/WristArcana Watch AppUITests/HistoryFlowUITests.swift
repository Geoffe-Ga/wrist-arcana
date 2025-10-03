import XCTest

final class HistoryFlowUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func test_historyView_displaysPastDraws() {
        app.buttons["DRAW"].tap()
        sleep(2)
        app.buttons["Done"].tap()

        app.swipeLeft()

        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'The'")).firstMatch.exists)
    }

    func test_addNote_savesSuccessfully() {
        app.buttons["DRAW"].tap()
        sleep(2)

        let addNoteButton = app.buttons["Add Note"]
        XCTAssertTrue(addNoteButton.waitForExistence(timeout: 2))
        addNoteButton.tap()

        let textField = app.textFields.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 2))
        textField.tap()
        textField.typeText("Test note")

        app.buttons["Save"].tap()

        XCTAssertTrue(app.staticTexts["Test note"].waitForExistence(timeout: 2))
    }

    func test_editNote_updatesExistingNote() {
        app.buttons["DRAW"].tap()
        sleep(2)
        app.buttons["Add Note"].tap()

        let textField = app.textFields.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 2))
        textField.tap()
        textField.typeText("Original note")
        app.buttons["Save"].tap()

        app.buttons["Edit Note"].tap()
        textField.tap()
        textField.clearText()
        textField.typeText("Updated note")
        app.buttons["Save"].tap()

        XCTAssertTrue(app.staticTexts["Updated note"].exists)
        XCTAssertFalse(app.staticTexts["Original note"].exists)
    }

    func test_historyDetail_showsFullCardInfo() {
        app.buttons["DRAW"].tap()
        sleep(2)
        app.buttons["Done"].tap()

        app.swipeLeft()

        app.cells.firstMatch.tap()

        XCTAssertTrue(app.images.firstMatch.exists)
        XCTAssertTrue(app.staticTexts["Meaning"].exists)
        XCTAssertTrue(app.buttons["Add Note"].exists)
    }
}

private extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else { return }
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}
