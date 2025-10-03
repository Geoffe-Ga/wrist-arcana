//
//  DateFormattingTests.swift
//  WristArcana Watch AppTests
//
//  Created by Geoff Gallinger on 10/2/25.
//

import Foundation
import Testing
@testable import WristArcana_Watch_App

struct DateFormattingTests {
    // MARK: - Short Format Tests

    @Test func shortFormat_returnsDateOnly() async throws {
        // Given
        var components = DateComponents()
        components.year = 2_025
        components.month = 10
        components.day = 2
        components.hour = 15
        components.minute = 30
        let date = Calendar.current.date(from: components)!

        // When
        let formatted = date.shortFormat

        // Then - Should contain date but not time
        #expect(formatted.contains("Oct"))
        #expect(formatted.contains("2"))
        #expect(formatted.contains("2025"))
        #expect(!formatted.contains("15"))
        #expect(!formatted.contains("30"))
        #expect(!formatted.contains("PM"))
    }

    @Test func shortFormat_handlesJanuary1() async throws {
        // Given
        var components = DateComponents()
        components.year = 2_025
        components.month = 1
        components.day = 1
        let date = Calendar.current.date(from: components)!

        // When
        let formatted = date.shortFormat

        // Then
        #expect(formatted.contains("Jan"))
        #expect(formatted.contains("1"))
        #expect(formatted.contains("2025"))
    }

    @Test func shortFormat_handlesDecember31() async throws {
        // Given
        var components = DateComponents()
        components.year = 2_025
        components.month = 12
        components.day = 31
        let date = Calendar.current.date(from: components)!

        // When
        let formatted = date.shortFormat

        // Then
        #expect(formatted.contains("Dec"))
        #expect(formatted.contains("31"))
        #expect(formatted.contains("2025"))
    }

    @Test func shortFormat_producesNonEmptyString() async throws {
        // Given
        let date = Date()

        // When
        let formatted = date.shortFormat

        // Then
        #expect(!formatted.isEmpty)
        #expect(formatted.count > 5) // At least "MMM D"
    }

    // MARK: - Full Format Tests

    @Test func fullFormat_includesTimeComponents() async throws {
        // Given
        var components = DateComponents()
        components.year = 2_025
        components.month = 10
        components.day = 2
        components.hour = 15
        components.minute = 30
        let date = Calendar.current.date(from: components)!

        // When
        let formatted = date.fullFormat

        // Then - Should contain both date and time
        #expect(formatted.contains("Oct"))
        #expect(formatted.contains("2"))
        #expect(formatted.contains("2025"))
        // Time component will be present (format varies by locale)
        #expect(formatted.contains(":"))
    }

    @Test func fullFormat_handlesMorning() async throws {
        // Given
        var components = DateComponents()
        components.year = 2_025
        components.month = 10
        components.day = 2
        components.hour = 9
        components.minute = 15
        let date = Calendar.current.date(from: components)!

        // When
        let formatted = date.fullFormat

        // Then
        #expect(formatted.contains("9"))
        #expect(formatted.contains("15"))
    }

    @Test func fullFormat_handlesAfternoon() async throws {
        // Given
        var components = DateComponents()
        components.year = 2_025
        components.month = 10
        components.day = 2
        components.hour = 15
        components.minute = 45
        let date = Calendar.current.date(from: components)!

        // When
        let formatted = date.fullFormat

        // Then
        #expect(formatted.contains(":"))
        #expect(formatted.contains("45"))
    }

    @Test func fullFormat_handlesMidnight() async throws {
        // Given
        var components = DateComponents()
        components.year = 2_025
        components.month = 10
        components.day = 2
        components.hour = 0
        components.minute = 0
        let date = Calendar.current.date(from: components)!

        // When
        let formatted = date.fullFormat

        // Then
        #expect(!formatted.isEmpty)
        #expect(formatted.contains("Oct"))
    }

    @Test func fullFormat_producesNonEmptyString() async throws {
        // Given
        let date = Date()

        // When
        let formatted = date.fullFormat

        // Then
        #expect(!formatted.isEmpty)
        #expect(formatted.count > 10) // At least "MMM D, YYYY"
    }

    // MARK: - Comparison Tests

    @Test func shortFormat_isShorterThanFullFormat() async throws {
        // Given
        let date = Date()

        // When
        let short = date.shortFormat
        let full = date.fullFormat

        // Then
        #expect(short.count < full.count)
    }

    @Test func fullFormat_containsShortFormatContent() async throws {
        // Given
        var components = DateComponents()
        components.year = 2_025
        components.month = 10
        components.day = 2
        components.hour = 15
        components.minute = 30
        let date = Calendar.current.date(from: components)!

        // When
        let short = date.shortFormat
        let full = date.fullFormat

        // Then - Full format should contain the date parts
        let dateParts = ["Oct", "2", "2025"]
        for part in dateParts where short.contains(part) {
            #expect(full.contains(part))
        }
    }
}
