//
//  CardPreviewFlowUITests.swift
//  WristArcana Watch AppUITests
//
//  Created by Geoff Gallinger on 2025-11-24.
//

import XCTest

final class CardPreviewFlowUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launchArguments = ["--uitesting"]
        self.app.launch()
    }

    override func tearDownWithError() throws {
        self.app = nil
    }

    // MARK: - Helper Methods

    /// Navigate to History tab by swiping left from Draw tab
    private func navigateToHistory() {
        self.app.swipeLeft()
        Thread.sleep(forTimeInterval: 0.5)
    }

    /// Navigate back to Draw tab by swiping right from History
    private func navigateToDraw() {
        self.app.swipeRight()
        Thread.sleep(forTimeInterval: 0.5)
    }

    // MARK: - Preview Screen Tests

    func test_drawCard_showsPreviewFirst() throws {
        // Given
        let drawButton = self.app.buttons["DRAW"]
        XCTAssertTrue(drawButton.exists, "DRAW button should exist")

        // When
        drawButton.tap()

        // Then - Preview should appear (card image visible)
        let cardImage = self.app.images.firstMatch
        XCTAssertTrue(
            cardImage.waitForExistence(timeout: 3),
            "Card image should appear in preview"
        )

        // Verify Detail button exists (indicates we're in preview, not detail view)
        let detailButton = self.app.buttons.matching(identifier: "Show card details").firstMatch
        XCTAssertTrue(
            detailButton.exists,
            "Detail button should exist in CardPreviewView"
        )
    }

    func test_previewScreen_tapCard_showsDetail() throws {
        // Given - Draw a card to show preview
        self.app.buttons["DRAW"].tap()
        let cardImage = self.app.images.firstMatch
        XCTAssertTrue(cardImage.waitForExistence(timeout: 3))

        // When - Tap the card image
        cardImage.tap()

        // Then - Detail view should appear
        // Look for text that appears in detail view but not preview (card meaning)
        let meaningText = self.app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS[c] 'beginnings' OR label CONTAINS[c] 'optimism'")
        ).firstMatch
        XCTAssertTrue(
            meaningText.waitForExistence(timeout: 2),
            "Card meaning should appear in detail view"
        )
    }

    func test_previewScreen_tapDetailButton_showsDetail() throws {
        // Given - Draw a card to show preview
        self.app.buttons["DRAW"].tap()
        XCTAssertTrue(self.app.images.firstMatch.waitForExistence(timeout: 3))

        // When - Tap Detail button
        let detailButton = self.app.buttons.matching(identifier: "Show card details").firstMatch
        XCTAssertTrue(detailButton.exists, "Detail button should exist")
        detailButton.tap()

        // Then - Detail view should appear
        let meaningText = self.app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS[c] 'beginnings' OR label CONTAINS[c] 'optimism'")
        ).firstMatch
        XCTAssertTrue(
            meaningText.waitForExistence(timeout: 2),
            "Card meaning should appear in detail view"
        )
    }

    func test_previewScreen_tapDone_returnsToDraw() throws {
        // Given - Draw a card to show preview
        self.app.buttons["DRAW"].tap()
        XCTAssertTrue(self.app.images.firstMatch.waitForExistence(timeout: 3))

        // When - Tap Done button
        let doneButton = self.app.buttons["Done"].firstMatch
        XCTAssertTrue(doneButton.exists, "Done button should exist")
        doneButton.tap()

        // Then - Back to draw screen
        let drawButton = self.app.buttons["DRAW"]
        XCTAssertTrue(
            drawButton.waitForExistence(timeout: 2),
            "DRAW button should be visible again"
        )

        // Verify no card image is showing
        let cardImage = self.app.images.firstMatch
        XCTAssertFalse(
            cardImage.exists || cardImage.label == "DRAW",
            "Card image should not be visible on draw screen"
        )
    }

    func test_detailView_tapDone_returnsToDraw() throws {
        // Given - Draw a card and navigate to detail view
        self.app.buttons["DRAW"].tap()
        XCTAssertTrue(self.app.images.firstMatch.waitForExistence(timeout: 3))

        // Tap card to go to detail
        self.app.images.firstMatch.tap()
        XCTAssertTrue(
            self.app.staticTexts.containing(
                NSPredicate(format: "label CONTAINS[c] 'beginnings' OR label CONTAINS[c] 'optimism'")
            ).firstMatch.waitForExistence(timeout: 2)
        )

        // When - Tap Done on detail view
        let doneButton = self.app.buttons["Done"].firstMatch
        XCTAssertTrue(doneButton.exists, "Done button should exist")
        doneButton.tap()

        // Then - Back at draw screen, NOT preview screen
        let drawButton = self.app.buttons["DRAW"]
        XCTAssertTrue(
            drawButton.waitForExistence(timeout: 2),
            "DRAW button should be visible (back to draw, not preview)"
        )

        // Verify no card image showing (proves we skipped preview)
        let cardImage = self.app.images.firstMatch
        XCTAssertFalse(
            cardImage.exists || cardImage.label == "DRAW",
            "Should not show preview after dismissing detail"
        )
    }

    func test_cardSavedToHistory_evenWithImmediateDismiss() throws {
        // Given - Check initial history count
        self.navigateToHistory()
        let initialHistoryCount = self.app.tables.cells.count

        // When - Draw card and immediately dismiss without viewing details
        self.navigateToDraw()
        self.app.buttons["DRAW"].tap()
        XCTAssertTrue(self.app.images.firstMatch.waitForExistence(timeout: 3))
        self.app.buttons["Done"].firstMatch.tap() // Dismiss preview immediately
        Thread.sleep(forTimeInterval: 0.5) // Brief delay for save

        // Then - Card should be in history
        self.navigateToHistory()
        let newHistoryCount = self.app.tables.cells.count
        XCTAssertEqual(
            newHistoryCount,
            initialHistoryCount + 1,
            "Card should be saved to history even when dismissed immediately"
        )
    }
}
