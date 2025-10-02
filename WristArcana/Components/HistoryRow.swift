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
                Text(self.pull.cardName)
                    .font(.headline)
                    .lineLimit(1)

                Text(self.pull.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
                cardImageName: "major_00"
            )
        )

        HistoryRow(
            pull: CardPull(
                date: Date().addingTimeInterval(-86_400),
                cardName: "The Magician",
                deckName: "Rider-Waite",
                cardImageName: "major_01"
            )
        )
    }
}
