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
}
