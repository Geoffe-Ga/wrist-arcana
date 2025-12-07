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

        // Wait for app to fully initialize and complete initial layout
        _ = self.app.wait(for: .runningForeground, timeout: 5)
    }

    override func tearDownWithError() throws {
        self.app = nil
    }

    // MARK: - Basic Layout Tests

    func test_drawButton_existsAndIsTappable() throws {
        // Given/When
        let drawButton = self.app.buttons["draw-button"]

        // Then - Wait for button to appear after app launch and layout
        XCTAssertTrue(
            drawButton.waitForExistence(timeout: 10),
            "DRAW button should exist after app launch"
        )
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
        let drawButton = self.app.buttons["draw-button"]
        XCTAssertTrue(drawButton.waitForExistence(timeout: 10))

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
        let drawButton = self.app.buttons["draw-button"]
        XCTAssertTrue(drawButton.waitForExistence(timeout: 10))

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
        let drawButton = self.app.buttons["draw-button"]
        XCTAssertTrue(drawButton.waitForExistence(timeout: 10))

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
        let drawButton = self.app.buttons["draw-button"]
        XCTAssertTrue(drawButton.waitForExistence(timeout: 10))

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
        let drawButton = self.app.buttons["draw-button"]

        XCTAssertTrue(titleText.waitForExistence(timeout: 10))
        XCTAssertTrue(drawButton.waitForExistence(timeout: 10))

        // When
        let titleFrame = titleText.frame
        let buttonFrame = drawButton.frame
        let screenHeight = self.app.frame.height

        // Then - Title should be at top, button should be at bottom (ZStack + safeAreaInset layout)
        // Title should be in upper portion (first 40% of screen)
        // Note: Title is in safeAreaInset which may extend into clock area
        XCTAssertLessThan(
            titleFrame.maxY,
            screenHeight * 0.4,
            "Title should be in upper portion of screen"
        )

        // Title should be above button with significant space between
        XCTAssertLessThan(
            titleFrame.maxY,
            buttonFrame.minY,
            "Title should be above button"
        )

        // Button should be in lower portion (positioned via safeAreaInset)
        // Button center should be in bottom half of screen
        XCTAssertGreaterThan(
            buttonFrame.midY,
            screenHeight * 0.5,
            "Button should be in lower half of screen"
        )
    }

    // MARK: - Functional Tests

    func test_drawButton_tapOpensPreview() throws {
        // Given
        let drawButton = self.app.buttons["draw-button"]
        XCTAssertTrue(drawButton.waitForExistence(timeout: 10))

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
        let drawButton = self.app.buttons["draw-button"]
        XCTAssertTrue(drawButton.waitForExistence(timeout: 10))
        let initialFrame = drawButton.frame

        // When - Navigate away and back using swipe gestures (page-style TabView)
        // Swipe left to go to History page
        self.app.swipeLeft()

        // Wait for transition to complete
        _ = self.app.otherElements.firstMatch.waitForExistence(timeout: 2)

        // Swipe right to return to Draw page
        self.app.swipeRight()

        // Wait for button to re-appear and settle after navigation
        XCTAssertTrue(drawButton.waitForExistence(timeout: 10))

        // Then - Button size should remain consistent
        let finalFrame = drawButton.frame

        XCTAssertEqual(
            initialFrame.width,
            finalFrame.width,
            accuracy: 5.0,
            "Button width should remain consistent after navigation"
        )
        XCTAssertEqual(
            initialFrame.height,
            finalFrame.height,
            accuracy: 5.0,
            "Button height should remain consistent after navigation"
        )
    }
}
