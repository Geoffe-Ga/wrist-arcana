//
//  CardDisplayView.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import SwiftUI

struct CardDisplayView: View {
    // MARK: - Properties

    let card: TarotCard
    let cardPull: CardPull?
    let onAddNote: ((CardPull) -> Void)?
    let onDismiss: () -> Void

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Card Image
                CardImageView(imageName: self.card.imageName, cardName: self.card.name)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(11.0 / 19.0, contentMode: .fit)
                    .padding(.top, 20)

                // Card Name
                Text(self.card.name)
                    .font(Theme.Fonts.cardName)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .accessibilityIdentifier("card-detail-name")

                // Meaning
                Text(self.card.upright)
                    .font(Theme.Fonts.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Note Section (if cardPull and onAddNote callback are available)
                if let pull = cardPull, onAddNote != nil {
                    Divider()
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        if let note = pull.note, !note.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Your Note")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Text(note)
                                    .font(.body)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)

                            Button(
                                action: {
                                    self.onAddNote?(pull)
                                },
                                label: {
                                    Label("Edit Note", systemImage: "pencil")
                                        .font(.caption)
                                }
                            )
                            .buttonStyle(.bordered)
                        } else {
                            Button(
                                action: {
                                    self.onAddNote?(pull)
                                },
                                label: {
                                    Label("Add Note", systemImage: "note.text.badge.plus")
                                }
                            )
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }

                Spacer()
                    .frame(height: 20)
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    self.onDismiss()
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Card details for \(self.card.name)")
    }
}

#Preview {
    NavigationStack {
        CardDisplayView(
            card: TarotCard(
                name: "The Fool",
                imageName: "major_00",
                suit: .majorArcana,
                number: 0,
                upright: "New beginnings, optimism, trust in life",
                reversed: "Recklessness, taken advantage of, inconsideration",
                keywords: ["New Beginnings", "Optimism", "Trust"]
            ),
            cardPull: nil,
            onAddNote: nil,
            onDismiss: {}
        )
    }
}
