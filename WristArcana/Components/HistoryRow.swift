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
            // Card thumbnail
            CardImageView(imageName: self.pull.cardImageName, cardName: self.pull.cardName)
                .frame(width: 40, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                // Card name with note indicator
                HStack {
                    Text(self.pull.cardName)
                        .font(.headline)
                        .lineLimit(1)

                    if self.pull.hasNote {
                        Image(systemName: "note.text")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(self.pull.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Note preview (if exists)
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
        .accessibilityLabel("\(self.pull.cardName), drawn on \(self.pull.date.shortFormat)")
    }
}

#Preview {
    List {
        HistoryRow(
            pull: CardPull(
                cardName: "The Fool",
                deckName: "Rider-Waite",
                cardImageName: "major_00",
                cardDescription: "New beginnings"
            )
        )

        HistoryRow(
            pull: CardPull(
                date: Date().addingTimeInterval(-86_400),
                cardName: "The Magician",
                deckName: "Rider-Waite",
                cardImageName: "major_01",
                cardDescription: "Manifestation"
            )
        )
    }
}
