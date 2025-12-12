//
//  CardPreviewView.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 2025-11-24.
//

import SwiftUI

struct CardPreviewView: View {
    // MARK: - Properties

    let card: TarotCard
    let onDismiss: () -> Void
    let onShowDetail: () -> Void

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                Spacer()

                // Full-height card image (tappable, width calculated from height)
                Button(action: self.onShowDetail) {
                    CardImageView(imageName: self.card.imageName, cardName: self.card.name)
                        .frame(
                            width: geometry.size.height * (11.0 / 19.0),
                            height: geometry.size.height
                        )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("card-preview-image")

                Spacer()
            }
        }
        .background(Color.black.opacity(0.9))
        .ignoresSafeArea(edges: .bottom)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    self.onDismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button {
                    self.onShowDetail()
                } label: {
                    Image(systemName: "info.circle")
                }
                .accessibilityLabel("Show card details")
                .accessibilityHint("Opens detailed view with card meaning and description")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Card preview for \(self.card.name). Tap to view detailed meaning.")
    }
}

#Preview {
    NavigationStack {
        CardPreviewView(
            card: TarotCard(
                name: "The Fool",
                imageName: "major_00",
                suit: .majorArcana,
                number: 0,
                upright: "New beginnings, optimism, trust in life",
                reversed: "Recklessness, taken advantage of, inconsideration",
                keywords: ["New Beginnings", "Optimism", "Trust"]
            ),
            onDismiss: {},
            onShowDetail: {}
        )
    }
}
