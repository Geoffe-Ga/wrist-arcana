//
//  NoteInputSanitizer.swift
//  WristArcana
//
//  Created by OpenAI on 3/8/24.
//

import Foundation

enum NoteInputSanitizer {
    static let maxCharacters = 500

    static func sanitize(_ input: String) -> String {
        var sanitized = input.trimmingCharacters(in: .whitespacesAndNewlines)

        sanitized = sanitized.filter { character in
            guard character.isControlCharacter else { return true }
            return character.isNewline || character == "\t"
        }

        if sanitized.count > maxCharacters {
            sanitized = String(sanitized.prefix(maxCharacters))
        }

        sanitized = sanitized.replacingOccurrences(
            of: "\n{3,}",
            with: "\n\n",
            options: .regularExpression
        )

        return sanitized
    }

    static func isValid(_ input: String) -> Bool {
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)
        return !cleaned.isEmpty && cleaned.count <= maxCharacters
    }

    static func remainingCharacters(_ input: String) -> Int {
        max(0, maxCharacters - input.count)
    }
}

private extension Character {
    var isControlCharacter: Bool {
        guard let scalar = String(self).unicodeScalars.first else {
            return false
        }
        return scalar.properties.generalCategory == .control
    }
}
