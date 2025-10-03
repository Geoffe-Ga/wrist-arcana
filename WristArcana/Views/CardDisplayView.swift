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
    let onDismiss: () -> Void

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Card Image
                CardImageView(imageName: self.card.imageName, cardName: self.card.name)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(0.6, contentMode: .fit)
                    .padding(.top, 20)

                // Card Name
                Text(self.card.name)
                    .font(Theme.Fonts.cardName)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Meaning
                Text(self.card.upright)
                    .font(Theme.Fonts.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
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
            onDismiss: {}
        )
    }
}
