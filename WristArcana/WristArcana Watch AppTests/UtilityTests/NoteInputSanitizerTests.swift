//
//  NoteInputSanitizerTests.swift
//  WristArcana Watch AppTests
//
//  Created by Geoff Gallinger on 10/3/25.
//

import Foundation
import Testing
@testable import WristArcana_Watch_App

struct NoteInputSanitizerTests {
    // MARK: - Sanitize Tests

    @Test func sanitizeTrimsWhitespace() async throws {
        // Given
        let input = "  Hello World  "

        // When
        let result = NoteInputSanitizer.sanitize(input)

        // Then
        #expect(result == "Hello World")
    }

    @Test func sanitizeRemovesControlCharacters() async throws {
        // Given
        let input = "Hello\u{0000}World\u{0001}"

        // When
        let result = NoteInputSanitizer.sanitize(input)

        // Then
        #expect(result == "HelloWorld")
    }

    @Test func sanitizePreservesNewlines() async throws {
        // Given
        let input = "Line1\nLine2\nLine3"

        // When
        let result = NoteInputSanitizer.sanitize(input)

        // Then
        #expect(result == "Line1\nLine2\nLine3")
    }

    @Test func sanitizeCollapsesMultipleNewlines() async throws {
        // Given
        let input = "Line1\n\n\n\nLine2"

        // When
        let result = NoteInputSanitizer.sanitize(input)

        // Then
        #expect(result == "Line1\n\nLine2")
    }

    @Test func sanitizeEnforcesCharacterLimit() async throws {
        // Given
        let input = String(repeating: "a", count: 600)

        // When
        let result = NoteInputSanitizer.sanitize(input)

        // Then
        #expect(result.count == 500)
    }

    @Test func sanitizeHandlesEmptyString() async throws {
        // Given
        let input = ""

        // When
        let result = NoteInputSanitizer.sanitize(input)

        // Then
        #expect(result == "")
    }

    @Test func sanitizeHandlesWhitespaceOnly() async throws {
        // Given
        let input = "     "

        // When
        let result = NoteInputSanitizer.sanitize(input)

        // Then
        #expect(result == "")
    }

    @Test func sanitizePreservesTabs() async throws {
        // Given
        let input = "Hello\tWorld"

        // When
        let result = NoteInputSanitizer.sanitize(input)

        // Then
        #expect(result == "Hello\tWorld")
    }

    @Test func sanitizeHandlesEmoji() async throws {
        // Given
        let input = "Hello 🌟 World ✨"

        // When
        let result = NoteInputSanitizer.sanitize(input)

        // Then
        #expect(result == "Hello 🌟 World ✨")
    }

    // MARK: - Validation Tests

    @Test func isValidReturnsTrueForValidInput() async throws {
        // When
        let result = NoteInputSanitizer.isValid("Valid note")

        // Then
        #expect(result == true)
    }

    @Test func isValidReturnsFalseForEmptyInput() async throws {
        // When
        let result = NoteInputSanitizer.isValid("")

        // Then
        #expect(result == false)
    }

    @Test func isValidReturnsFalseForWhitespaceOnly() async throws {
        // When
        let result = NoteInputSanitizer.isValid("   ")

        // Then
        #expect(result == false)
    }

    @Test func isValidReturnsFalseForTooLong() async throws {
        // Given
        let input = String(repeating: "a", count: 501)

        // When
        let result = NoteInputSanitizer.isValid(input)

        // Then
        #expect(result == false)
    }

    @Test func isValidReturnsTrueForExactlyMaxLength() async throws {
        // Given
        let input = String(repeating: "a", count: 500)

        // When
        let result = NoteInputSanitizer.isValid(input)

        // Then
        #expect(result == true)
    }

    // MARK: - Remaining Characters Tests

    @Test func remainingCharactersCalculatesCorrectly() async throws {
        // Given
        let input = String(repeating: "a", count: 100)

        // When
        let result = NoteInputSanitizer.remainingCharacters(input)

        // Then
        #expect(result == 400)
    }

    @Test func remainingCharactersReturnsZeroWhenAtLimit() async throws {
        // Given
        let input = String(repeating: "a", count: 500)

        // When
        let result = NoteInputSanitizer.remainingCharacters(input)

        // Then
        #expect(result == 0)
    }

    @Test func remainingCharactersReturnsZeroWhenOverLimit() async throws {
        // Given
        let input = String(repeating: "a", count: 600)

        // When
        let result = NoteInputSanitizer.remainingCharacters(input)

        // Then
        #expect(result == 0)
    }

    @Test func remainingCharactersHandlesEmptyString() async throws {
        // Given
        let input = ""

        // When
        let result = NoteInputSanitizer.remainingCharacters(input)

        // Then
        #expect(result == 500)
    }
}
