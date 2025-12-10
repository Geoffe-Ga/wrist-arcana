//
//  WristArcana_Watch_AppUITests.swift
//  WristArcana Watch AppUITests
//
//  Created by Geoff Gallinger on 10/1/25.
//

import XCTest

final class WristArcanaWatchAppUITests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests
        // before they run. The setUp method is a good place to do this.
    }

    // MARK: - Helper Methods

    /// Creates an XCUIApplication configured for UI testing with in-memory storage
    private func createApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        return app
    }

    /// Navigate to History tab by swiping left from Draw tab
    /// Note: watchOS TabView with .page style uses swiping, not tab buttons
    private func navigateToHistory(_ app: XCUIApplication) {
        app.swipeLeft()
        Thread.sleep(forTimeInterval: 0.5) // Brief pause for animation
    }

    /// Navigate back to Draw tab by swiping right from History
    private func navigateToDraw(_ app: XCUIApplication) {
        app.swipeRight()
        Thread.sleep(forTimeInterval: 0.5) // Brief pause for animation
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = self.createApp()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            self.createApp().launch()
        }
    }

    @MainActor
    func testDrawCardAppearsInHistory() throws {
        // MARK: - Arrange

        let app = self.createApp()
        app.launch()

        // App starts on Draw tab (default selection)
        // Navigate to History to verify empty state
        self.navigateToHistory(app)

        // Verify empty state is shown
        let emptyMessage = app.staticTexts["No Readings Yet"]
        XCTAssertTrue(emptyMessage.waitForExistence(timeout: 2), "Empty state should be shown initially")

        // MARK: - Act

        // Navigate back to Draw tab
        self.navigateToDraw(app)

        // Tap DRAW button
        let drawButton = app.buttons["DRAW"]
        XCTAssertTrue(drawButton.waitForExistence(timeout: 2), "DRAW button should exist")
        drawButton.tap()

        // Wait for card to appear and dismiss it
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5), "Done button should appear after drawing")
        doneButton.tap()

        // Brief delay to ensure save completes
        Thread.sleep(forTimeInterval: 0.5)

        // Navigate to History tab
        self.navigateToHistory(app)

        // MARK: - Assert

        // Verify at least one history row appears (regression test for observation bug)
        let historyList = app.tables.firstMatch
        XCTAssertTrue(historyList.waitForExistence(timeout: 5), "History list should exist")

        // The empty message should no longer be visible
        XCTAssertFalse(
            emptyMessage.exists,
            "Empty state should be hidden after drawing a card"
        )

        // At least one cell should exist (the card we just drew)
        let firstCell = historyList.cells.firstMatch
        XCTAssertTrue(
            firstCell.waitForExistence(timeout: 3),
            "At least one history entry should appear after drawing a card"
        )
    }

    // MARK: - Regression Tests for Multi-Delete Feature

    @MainActor
    func testHistoryItemsAreClickableInNormalMode() throws {
        // Regression test: Ensure history items remain clickable/tappable
        // Bug: Replacing NavigationLink with Button broke navigation

        let app = self.createApp()
        app.launch()

        // Draw a card first
        let drawButton = app.buttons["DRAW"]
        XCTAssertTrue(drawButton.waitForExistence(timeout: 2))
        drawButton.tap()

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()

        // Brief delay to ensure save completes
        Thread.sleep(forTimeInterval: 0.5)

        // Navigate to History
        self.navigateToHistory(app)

        // Wait for history list
        let historyList = app.tables.firstMatch
        XCTAssertTrue(historyList.waitForExistence(timeout: 5))

        // CRITICAL: Tap on the first history item
        let firstCell = historyList.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 2), "First cell should exist")
        firstCell.tap()

        // Verify we navigated to detail view
        // Look for elements that only exist in HistoryDetailView
        let detailView = app.navigationBars.firstMatch
        XCTAssertTrue(
            detailView.waitForExistence(timeout: 3),
            "Should navigate to detail view when tapping history item in normal mode"
        )
    }

    @MainActor
    func testManagementButtonsAreVisible() throws {
        // Regression test: Management buttons should be visible at top of history list
        // Bug: Buttons were completely missing

        let app = self.createApp()
        app.launch()

        // Draw a card to have history
        let drawButton = app.buttons["DRAW"]
        drawButton.tap()

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()

        // Brief delay to ensure save completes
        Thread.sleep(forTimeInterval: 0.5)

        // Navigate to History
        self.navigateToHistory(app)

        // Wait for list to appear
        let historyList = app.tables.firstMatch
        XCTAssertTrue(historyList.waitForExistence(timeout: 5))

        // Buttons should be visible at top of list
        let selectButton = app.buttons["Select"]
        XCTAssertTrue(
            selectButton.waitForExistence(timeout: 2),
            "Select button should be visible in history"
        )

        let clearAllButton = app.buttons["Clear All"]
        XCTAssertTrue(
            clearAllButton.waitForExistence(timeout: 2),
            "Clear All button should be visible in history"
        )
    }

    @MainActor
    func testSelectButtonEntersEditMode() throws {
        // Test that Select button properly activates multi-select mode

        let app = self.createApp()
        app.launch()

        // Draw cards
        for _ in 1 ... 2 {
            let drawButton = app.buttons["DRAW"]
            drawButton.tap()
            let doneButton = app.buttons["Done"]
            XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
            doneButton.tap()
            Thread.sleep(forTimeInterval: 0.5)
        }

        // Go to History
        self.navigateToHistory(app)

        // Wait for list
        let historyList = app.tables.firstMatch
        XCTAssertTrue(historyList.waitForExistence(timeout: 5))

        // Tap Select
        let selectButton = app.buttons["Select"]
        XCTAssertTrue(selectButton.waitForExistence(timeout: 2))
        selectButton.tap()

        // Verify Done button appears (indicates edit mode)
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(
            doneButton.waitForExistence(timeout: 2),
            "Done button should appear in toolbar when edit mode is active"
        )

        // Verify selection indicators appear on items
        // In edit mode, items should show circle/checkmark icons
        let checkmarkImage = app.images["circle"]
        XCTAssertTrue(
            checkmarkImage.exists,
            "Selection indicators should appear on history items in edit mode"
        )
    }

    @MainActor
    func testMultiSelectAndDelete() throws {
        // End-to-end test for multi-delete functionality

        let app = self.createApp()
        app.launch()

        // Draw 3 cards
        for _ in 1 ... 3 {
            app.buttons["DRAW"].tap()
            let done = app.buttons["Done"]
            XCTAssertTrue(done.waitForExistence(timeout: 5))
            done.tap()
            Thread.sleep(forTimeInterval: 0.5)
        }

        // Go to History
        self.navigateToHistory(app)

        let historyList = app.tables.firstMatch
        XCTAssertTrue(historyList.waitForExistence(timeout: 5))

        // Count initial items
        let initialCellCount = historyList.cells.count
        XCTAssertEqual(initialCellCount, 3, "Should have 3 history items")

        // Enter edit mode
        let selectButton = app.buttons["Select"]
        XCTAssertTrue(selectButton.waitForExistence(timeout: 2))
        selectButton.tap()

        // Select 2 items
        let firstCell = historyList.cells.element(boundBy: 0)
        firstCell.tap()

        let secondCell = historyList.cells.element(boundBy: 1)
        secondCell.tap()

        // Delete button should appear at bottom
        let deleteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Delete'")).firstMatch
        XCTAssertTrue(
            deleteButton.waitForExistence(timeout: 2),
            "Delete button should appear when items are selected"
        )

        // Tap delete
        deleteButton.tap()

        // Confirm in alert
        let deleteAlertButton = app.buttons["Delete"]
        XCTAssertTrue(deleteAlertButton.waitForExistence(timeout: 2))
        deleteAlertButton.tap()

        // Wait for deletion to complete
        Thread.sleep(forTimeInterval: 1)

        // Verify only 1 item remains
        let finalCellCount = historyList.cells.count
        XCTAssertEqual(finalCellCount, 1, "Should have 1 history item after deleting 2")
    }

    @MainActor
    func testClearAllDeletesAllHistory() throws {
        // Test Clear All functionality

        let app = self.createApp()
        app.launch()

        // Draw 2 cards
        for _ in 1 ... 2 {
            app.buttons["DRAW"].tap()
            let done = app.buttons["Done"]
            XCTAssertTrue(done.waitForExistence(timeout: 5))
            done.tap()
            Thread.sleep(forTimeInterval: 0.5)
        }

        // Go to History
        self.navigateToHistory(app)

        let historyList = app.tables.firstMatch
        XCTAssertTrue(historyList.waitForExistence(timeout: 5))

        // Verify we have items
        XCTAssertGreaterThan(historyList.cells.count, 0)

        // Tap Clear All
        let clearAllButton = app.buttons["Clear All"]
        XCTAssertTrue(clearAllButton.exists)
        clearAllButton.tap()

        // Confirm deletion
        let deleteAllButton = app.buttons["Delete All"]
        XCTAssertTrue(deleteAllButton.waitForExistence(timeout: 2))
        deleteAllButton.tap()

        // Wait for deletion
        Thread.sleep(forTimeInterval: 1)

        // Verify empty state appears
        let emptyMessage = app.staticTexts["No Readings Yet"]
        XCTAssertTrue(
            emptyMessage.waitForExistence(timeout: 3),
            "Empty state should appear after clearing all history"
        )
    }

    @MainActor
    func testManagementButtonsAccessibleViaScrollUp() throws {
        // CRITICAL TEST: Buttons should be accessible at top of list
        // They appear as the first row and can be accessed by scrolling to top

        let app = self.createApp()
        app.launch()

        // Draw 5 cards to ensure we have scrollable content
        for _ in 1 ... 5 {
            app.buttons["DRAW"].tap()
            let done = app.buttons["Done"]
            XCTAssertTrue(done.waitForExistence(timeout: 5))
            done.tap()
            Thread.sleep(forTimeInterval: 0.5)
        }

        // Navigate to History
        self.navigateToHistory(app)

        let historyList = app.tables.firstMatch
        XCTAssertTrue(historyList.waitForExistence(timeout: 5))

        // Buttons should be at the top of the list
        let selectButton = app.buttons["Select"]
        let clearAllButton = app.buttons["Clear All"]

        // Buttons should exist and be accessible
        XCTAssertTrue(
            selectButton.waitForExistence(timeout: 2),
            "Select button should exist at top of list"
        )
        XCTAssertTrue(
            clearAllButton.waitForExistence(timeout: 2),
            "Clear All button should exist at top of list"
        )

        // If we've scrolled down, scroll back up to make buttons visible
        if !selectButton.isHittable {
            // Scroll to top of list
            historyList.swipeDown()
            historyList.swipeDown()

            // Give animation time to complete
            Thread.sleep(forTimeInterval: 0.5)
        }

        // Buttons should now be hittable
        XCTAssertTrue(
            selectButton.isHittable,
            "Select button should be hittable at top of list"
        )
        XCTAssertTrue(
            clearAllButton.isHittable,
            "Clear All button should be hittable at top of list"
        )

        // CRITICAL: Verify buttons are functional - tap Select button
        selectButton.tap()

        // Verify we entered edit mode
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(
            doneButton.waitForExistence(timeout: 2),
            "Done button should appear, confirming Select button worked"
        )
    }
}
