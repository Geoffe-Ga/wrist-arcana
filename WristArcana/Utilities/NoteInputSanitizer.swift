//
//  NoteInputSanitizer.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/3/25.
//

import Foundation

enum NoteInputSanitizer {
    static let maxCharacters = 500

    /// Sanitizes user input for note storage
    /// - Parameter input: Raw user input string
    /// - Returns: Sanitized string safe for storage
    static func sanitize(_ input: String) -> String {
        var sanitized = input

        // 1. Trim whitespace from ends
        sanitized = sanitized.trimmingCharacters(in: .whitespacesAndNewlines)

        // 2. Remove control characters except newlines and tabs
        sanitized = sanitized.filter { char in
            !char.isControlCharacter || char.isNewline || char == "\t"
        }

        // 3. Limit to max characters
        if sanitized.count > self.maxCharacters {
            sanitized = String(sanitized.prefix(self.maxCharacters))
        }

        // 4. Collapse multiple consecutive newlines to max 2
        sanitized = sanitized.replacingOccurrences(
            of: #"\n{3,}"#,
            with: "\n\n",
            options: .regularExpression
        )

        return sanitized
    }

    /// Validates if input is acceptable
    /// - Parameter input: User input to validate
    /// - Returns: True if valid, false otherwise
    static func isValid(_ input: String) -> Bool {
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)
        return !cleaned.isEmpty && cleaned.count <= self.maxCharacters
    }

    /// Returns remaining character count
    /// - Parameter input: Current input string
    /// - Returns: Number of characters remaining
    static func remainingCharacters(_ input: String) -> Int {
        max(0, self.maxCharacters - input.count)
    }
}

// MARK: - Character Extensions

private extension Character {
    var isControlCharacter: Bool {
        let scalar = String(self).unicodeScalars.first
        return scalar?.properties.generalCategory == .control
    }
}
