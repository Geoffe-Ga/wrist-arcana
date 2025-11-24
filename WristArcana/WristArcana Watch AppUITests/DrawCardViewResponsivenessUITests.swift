//
//  DrawCardViewResponsivenessUITests.swift
//  WristArcana Watch AppUITests
//
//  Created by Geoff Gallinger on 2025-11-24.
//

import XCTest

final class DrawCardViewResponsivenessUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        self.app = XCUIApplication()
        self.app.launch()
    }

    override func tearDownWithError() throws {
        self.app = nil
    }

    // MARK: - Basic Layout Tests

    func test_drawButton_existsAndIsTappable() throws {
        // Given/When
        let drawButton = self.app.buttons["DRAW"]

        // Then
        XCTAssertTrue(drawButton.exists, "DRAW button should exist")
        XCTAssertTrue(drawButton.isHittable, "DRAW button should be tappable")
    }

    func test_titleText_isVisible() throws {
        // Given/When
        let titleText = self.app.staticTexts["Tarot"]

        // Then
        XCTAssertTrue(titleText.exists, "Title 'Tarot' should be visible")
    }

    func test_drawButton_isCenteredVertically() throws {
        // Given
        let drawButton = self.app.buttons["DRAW"]
        XCTAssertTrue(drawButton.waitForExistence(timeout: 2))

        // When
        let buttonFrame = drawButton.frame
        let screenHeight = self.app.frame.height

        // Then - Button should be roughly in middle third of screen
        let buttonCenterY = buttonFrame.midY
        let screenCenterY = screenHeight / 2

        // Allow 20% deviation from perfect center
        let tolerance = screenHeight * 0.2
        XCTAssertTrue(
            abs(buttonCenterY - screenCenterY) < tolerance,
            "Button should be centered vertically (center: \(buttonCenterY), screen center: \(screenCenterY))"
        )
    }

    // MARK: - Minimum Size Requirements

    func test_drawButton_meetsMinimumTapTarget() throws {
        // Given
        let drawButton = self.app.buttons["DRAW"]
        XCTAssertTrue(drawButton.waitForExistence(timeout: 2))

        // When
        let buttonFrame = drawButton.frame

        // Then - Minimum 44pt tap target for accessibility
        XCTAssertGreaterThanOrEqual(
            buttonFrame.width,
            44.0,
            "Button width should be at least 44pt for accessibility"
        )
        XCTAssertGreaterThanOrEqual(
            buttonFrame.height,
            44.0,
            "Button height should be at least 44pt for accessibility"
        )
    }

    // MARK: - Screen Size Adaptation Tests

    func test_drawButton_sizesAppropriatelyForSmallScreen() throws {
        // This test runs on whatever simulator is configured
        // We verify button doesn't exceed reasonable bounds

        // Given
        let drawButton = self.app.buttons["DRAW"]
        XCTAssertTrue(drawButton.waitForExistence(timeout: 2))

        // When
        let buttonFrame = drawButton.frame
        let screenWidth = self.app.frame.width

        // Then - Button shouldn't be wider than 80% of screen
        XCTAssertLessThanOrEqual(
            buttonFrame.width,
            screenWidth * 0.8,
            "Button shouldn't exceed 80% of screen width"
        )
    }

    func test_drawButton_isSquare() throws {
        // Given
        let drawButton = self.app.buttons["DRAW"]
        XCTAssertTrue(drawButton.waitForExistence(timeout: 2))

        // When
        let buttonFrame = drawButton.frame
        let aspectRatio = buttonFrame.width / buttonFrame.height

        // Then - Button should be square (aspect ratio ~1.0)
        XCTAssertEqual(
            aspectRatio,
            1.0,
            accuracy: 0.1,
            "Button should be square (aspect ratio: \(aspectRatio))"
        )
    }

    func test_layout_hasBalancedSpacing() throws {
        // Given
        let titleText = self.app.staticTexts["Tarot"]
        let drawButton = self.app.buttons["DRAW"]

        XCTAssertTrue(titleText.waitForExistence(timeout: 2))
        XCTAssertTrue(drawButton.exists)

        // When
        let titleFrame = titleText.frame
        let buttonFrame = drawButton.frame
        let screenHeight = self.app.frame.height

        // Then - Title should be in upper portion, button in middle/lower
        XCTAssertLessThan(
            titleFrame.maxY,
            buttonFrame.minY,
            "Title should be above button"
        )

        // Button shouldn't be at very top or bottom
        XCTAssertGreaterThan(
            buttonFrame.minY,
            screenHeight * 0.2,
            "Button should have space above"
        )
        XCTAssertLessThan(
            buttonFrame.maxY,
            screenHeight * 0.8,
            "Button should have space below"
        )
    }

    // MARK: - Functional Tests

    func test_drawButton_tapOpensPreview() throws {
        // Given
        let drawButton = self.app.buttons["DRAW"]
        XCTAssertTrue(drawButton.waitForExistence(timeout: 2))

        // When
        drawButton.tap()

        // Then - Card preview should appear
        let cardImage = self.app.images.firstMatch
        XCTAssertTrue(
            cardImage.waitForExistence(timeout: 3),
            "Card image should appear after tapping DRAW"
        )
    }

    func test_layout_remainsStableAfterInteraction() throws {
        // Given
        let drawButton = self.app.buttons["DRAW"]
        let initialFrame = drawButton.frame

        // When - Navigate away and back
        self.app.tabBars.buttons["History"].tap()
        self.app.tabBars.buttons["Draw"].tap()

        // Then - Button size should remain consistent
        let finalFrame = drawButton.frame

        XCTAssertEqual(
            initialFrame.width,
            finalFrame.width,
            accuracy: 1.0,
            "Button width should remain consistent after navigation"
        )
        XCTAssertEqual(
            initialFrame.height,
            finalFrame.height,
            accuracy: 1.0,
            "Button height should remain consistent after navigation"
        )
    }
}
