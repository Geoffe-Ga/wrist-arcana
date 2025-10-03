//
//  CardPull.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation
import SwiftData

@Model
final class CardPull {
    @Attribute(.unique) var id: UUID
    var date: Date
    var cardName: String
    var deckName: String
    var cardImageName: String
    var cardDescription: String
    var note: String?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        cardName: String,
        deckName: String,
        cardImageName: String,
        cardDescription: String,
        note: String? = nil
    ) {
        self.id = id
        self.date = date
        self.cardName = cardName
        self.deckName = deckName
        self.cardImageName = cardImageName
        self.cardDescription = cardDescription
        self.note = note
    }

    // MARK: - Computed Properties

    var hasNote: Bool {
        guard let note else { return false }
        return !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var truncatedNote: String? {
        guard let note, !note.isEmpty else { return nil }
        let maxLength = 80
        if note.count <= maxLength {
            return note
        }
        return String(note.prefix(maxLength)) + "..."
    }
}
