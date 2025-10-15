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

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests
        // before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testDrawCardAppearsInHistory() throws {
        // MARK: - Arrange

        let app = XCUIApplication()
        app.launch()

        // Verify we start on Draw tab
        let drawTab = app.buttons["Draw"]
        XCTAssertTrue(drawTab.exists, "Draw tab should exist")

        // Switch to History tab first to verify empty state
        let historyTab = app.buttons["History"]
        XCTAssertTrue(historyTab.exists, "History tab should exist")
        historyTab.tap()

        // Verify empty state is shown
        let emptyMessage = app.staticTexts["No Readings Yet"]
        XCTAssertTrue(emptyMessage.waitForExistence(timeout: 2), "Empty state should be shown initially")

        // MARK: - Act

        // Switch back to Draw tab
        drawTab.tap()

        // Tap DRAW button
        let drawButton = app.buttons["DRAW"]
        XCTAssertTrue(drawButton.waitForExistence(timeout: 2), "DRAW button should exist")
        drawButton.tap()

        // Wait for card to appear and dismiss it
        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5), "Done button should appear after drawing")
        doneButton.tap()

        // Switch to History tab
        historyTab.tap()

        // MARK: - Assert

        // Verify at least one history row appears (regression test for observation bug)
        let historyList = app.tables.firstMatch
        XCTAssertTrue(historyList.waitForExistence(timeout: 3), "History list should exist")

        // The empty message should no longer be visible
        XCTAssertFalse(
            emptyMessage.exists,
            "Empty state should be hidden after drawing a card"
        )

        // At least one cell should exist (the card we just drew)
        let firstCell = historyList.cells.firstMatch
        XCTAssertTrue(
            firstCell.waitForExistence(timeout: 2),
            "At least one history entry should appear after drawing a card"
        )
    }

    // MARK: - Regression Tests for Multi-Delete Feature

    @MainActor
    func testHistoryItemsAreClickableInNormalMode() throws {
        // Regression test: Ensure history items remain clickable/tappable
        // Bug: Replacing NavigationLink with Button broke navigation

        let app = XCUIApplication()
        app.launch()

        // Draw a card first
        let drawButton = app.buttons["DRAW"]
        XCTAssertTrue(drawButton.waitForExistence(timeout: 2))
        drawButton.tap()

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()

        // Navigate to History
        let historyTab = app.buttons["History"]
        historyTab.tap()

        // Wait for history list
        let historyList = app.tables.firstMatch
        XCTAssertTrue(historyList.waitForExistence(timeout: 2))

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

        let app = XCUIApplication()
        app.launch()

        // Draw a card to have history
        let drawButton = app.buttons["DRAW"]
        drawButton.tap()

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
        doneButton.tap()

        // Navigate to History
        let historyTab = app.buttons["History"]
        historyTab.tap()

        // Wait for list to appear
        let historyList = app.tables.firstMatch
        XCTAssertTrue(historyList.waitForExistence(timeout: 2))

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

        let app = XCUIApplication()
        app.launch()

        // Draw cards
        for _ in 1 ... 2 {
            let drawButton = app.buttons["DRAW"]
            drawButton.tap()
            let doneButton = app.buttons["Done"]
            XCTAssertTrue(doneButton.waitForExistence(timeout: 5))
            doneButton.tap()
        }

        // Go to History
        app.buttons["History"].tap()

        // Wait for list
        let historyList = app.tables.firstMatch
        XCTAssertTrue(historyList.waitForExistence(timeout: 2))

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

        let app = XCUIApplication()
        app.launch()

        // Draw 3 cards
        for _ in 1 ... 3 {
            app.buttons["DRAW"].tap()
            let done = app.buttons["Done"]
            XCTAssertTrue(done.waitForExistence(timeout: 5))
            done.tap()
        }

        // Go to History
        app.buttons["History"].tap()

        let historyList = app.tables.firstMatch
        XCTAssertTrue(historyList.waitForExistence(timeout: 2))

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

        let app = XCUIApplication()
        app.launch()

        // Draw 2 cards
        for _ in 1 ... 2 {
            app.buttons["DRAW"].tap()
            let done = app.buttons["Done"]
            XCTAssertTrue(done.waitForExistence(timeout: 5))
            done.tap()
        }

        // Go to History
        app.buttons["History"].tap()

        let historyList = app.tables.firstMatch
        XCTAssertTrue(historyList.waitForExistence(timeout: 2))

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
}
