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
        Thread.sleep(forTimeInterval: 1.5) // Wait for async SwiftData loading
    }

    /// Navigate back to Draw tab by swiping right from History
    private func navigateToDraw() {
        self.app.swipeRight()
        Thread.sleep(forTimeInterval: 1.5) // Wait for async SwiftData loading
    }

    // MARK: - Preview Screen Tests

    func test_drawCard_showsPreviewFirst() throws {
        // Given
        let drawButton = self.app.buttons["draw-button"]
        XCTAssertTrue(drawButton.exists, "Draw button should exist")

        // When
        drawButton.tap()

        // Then - Preview should appear (card image visible)
        let cardImage = self.app.images.firstMatch
        XCTAssertTrue(
            cardImage.waitForExistence(timeout: 3),
            "Card image should appear in preview"
        )

        // Verify Detail button exists (indicates we're in preview, not detail view)
        let detailButton = self.app.buttons["card-detail-button"]
        XCTAssertTrue(
            detailButton.exists,
            "Detail button should exist in CardPreviewView"
        )
    }

    func test_previewScreen_tapCard_showsDetail() throws {
        // Given - Draw a card to show preview
        self.app.buttons["draw-button"].tap()
        Thread.sleep(forTimeInterval: 1.0) // Wait for preview to fully render

        let cardImageButton = self.app.buttons["card-preview-image"]
        XCTAssertTrue(cardImageButton.waitForExistence(timeout: 3))

        // When - Tap the card image button
        cardImageButton.tap()

        // Wait for navigation
        Thread.sleep(forTimeInterval: 1.0)

        // Then - Detail view should appear with card name (using accessibility identifier)
        let cardNameElement = self.app.staticTexts.matching(identifier: "card-detail-name").firstMatch
        XCTAssertTrue(
            cardNameElement.waitForExistence(timeout: 3),
            "Card name should appear in detail view"
        )

        // Also verify the info button from preview is gone (we're in detail view now)
        let infoButton = self.app.buttons["card-detail-button"]
        XCTAssertFalse(
            infoButton.exists,
            "Info button should not exist in detail view"
        )
    }

    func test_previewScreen_detailButtonExistsAndIsAccessible() throws {
        // This test verifies the detail button is present and properly accessible.
        // Note: Actual navigation via toolbar button tap is not reliably testable on watchOS
        // due to XCUITest framework limitations, but the navigation IS tested via
        // test_previewScreen_tapCard_showsDetail which uses the card image tap.

        // Given - Draw a card to show preview
        self.app.buttons["draw-button"].tap()

        // Wait for preview to fully load (card image must appear first)
        let cardImage = self.app.images.firstMatch
        XCTAssertTrue(
            cardImage.waitForExistence(timeout: 3),
            "Card image should appear in preview"
        )

        // Then - Detail button should exist (matches test_drawCard_showsPreviewFirst)
        let detailButton = self.app.buttons["card-detail-button"]
        XCTAssertTrue(
            detailButton.exists,
            "Detail button should exist in preview toolbar"
        )
    }

    func test_previewScreen_tapDone_returnsToDraw() throws {
        // Given - Draw a card to show preview
        self.app.buttons["draw-button"].tap()
        XCTAssertTrue(self.app.images.firstMatch.waitForExistence(timeout: 3))

        // When - Tap Done button
        let doneButton = self.app.buttons["Done"].firstMatch
        XCTAssertTrue(doneButton.exists, "Done button should exist")
        doneButton.tap()

        // Then - Back to draw screen
        let drawButton = self.app.buttons["draw-button"]
        XCTAssertTrue(
            drawButton.waitForExistence(timeout: 2),
            "DRAW button should be visible again"
        )

        // Verify preview/detail elements are not showing
        let detailButton = self.app.buttons["card-detail-button"]
        XCTAssertFalse(
            detailButton.exists,
            "Detail button should not exist after dismissing preview"
        )
    }

    func test_detailView_tapDone_returnsToDraw() throws {
        // Given - Draw a card and navigate to detail view
        self.app.buttons["draw-button"].tap()
        Thread.sleep(forTimeInterval: 1.0) // Wait for preview to fully render

        // Tap card to go to detail
        let cardImageButton = self.app.buttons["card-preview-image"]
        XCTAssertTrue(cardImageButton.waitForExistence(timeout: 3))
        cardImageButton.tap()
        Thread.sleep(forTimeInterval: 1.0) // Wait for detail view navigation

        // Verify we're in detail view by checking for card name element
        let cardNameElement = self.app.staticTexts.matching(identifier: "card-detail-name").firstMatch
        XCTAssertTrue(cardNameElement.waitForExistence(timeout: 3), "Should be in detail view")

        // When - Tap Done on detail view
        let doneButton = self.app.buttons["Done"].firstMatch
        XCTAssertTrue(doneButton.exists, "Done button should exist")
        doneButton.tap()

        // Wait for navigation back
        Thread.sleep(forTimeInterval: 1.0)

        // Then - Back at draw screen
        let drawButton = self.app.buttons["draw-button"]
        XCTAssertTrue(
            drawButton.waitForExistence(timeout: 3),
            "Draw button should be visible (back to draw screen)"
        )
    }

    func test_cardSavedToHistory_evenWithImmediateDismiss() throws {
        // Given - Check initial history state
        self.navigateToHistory()

        // Look for empty state or count existing items
        let emptyState = self.app.staticTexts["No Readings Yet"]
        let initiallyEmpty = emptyState.waitForExistence(timeout: 2)

        // When - Draw card and immediately dismiss without viewing details
        self.navigateToDraw()
        self.app.buttons["draw-button"].tap()
        XCTAssertTrue(self.app.images.firstMatch.waitForExistence(timeout: 3))
        self.app.buttons["Done"].firstMatch.tap() // Dismiss preview immediately
        Thread.sleep(forTimeInterval: 0.5) // Brief delay for save

        // Then - Card should be in history
        self.navigateToHistory()

        if initiallyEmpty {
            // Was empty before, now should have items
            XCTAssertFalse(
                emptyState.exists,
                "Empty state should be gone after drawing a card"
            )
        }

        // Verify at least one history item exists
        let anyHistoryItem = self.app.descendants(matching: .any).matching(
            NSPredicate(format: "identifier BEGINSWITH 'history-item-'")
        ).firstMatch
        XCTAssertTrue(
            anyHistoryItem.waitForExistence(timeout: 10),
            "Card should be saved to history even when dismissed immediately"
        )
    }
}
