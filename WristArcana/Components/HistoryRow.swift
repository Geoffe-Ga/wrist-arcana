//
//  HistoryRow.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import SwiftUI

struct HistoryRow: View {
    // MARK: - Properties

    let pull: CardPull

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            CardImageView(imageName: self.pull.cardImageName, cardName: self.pull.cardName)
                .frame(width: 40, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(self.pull.cardName)
                        .font(.headline)
                        .lineLimit(1)

                    if self.pull.hasNote {
                        Image(systemName: "note.text")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
                }

                Text(self.pull.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if let truncatedNote = self.pull.truncatedNote {
                    Text(truncatedNote)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(2)
                        .padding(.top, 2)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(self.accessibilityDescription)
    }

    private var accessibilityDescription: String {
        var components = ["\(self.pull.cardName), drawn on \(self.pull.date.shortFormat)"]
        if self.pull.hasNote {
            components.append("Note added")
        }
        return components.joined(separator: ". ")
    }
}

#Preview {
    List {
        HistoryRow(
            pull: CardPull(
                cardName: "The Fool",
                deckName: "Rider-Waite",
                cardImageName: "major_00",
                cardDescription: "New beginnings",
                note: "A short reflection"
            )
        )

        HistoryRow(
            pull: CardPull(
                date: Date().addingTimeInterval(-86_400),
                cardName: "The Magician",
                deckName: "Rider-Waite",
                cardImageName: "major_01",
                cardDescription: "Manifestation and power",
                note: nil
            )
        )
    }
}
