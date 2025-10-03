//
//  CardReferenceDetailView.swift
//  WristArcana
//
//  Created by OpenAI on 10/1/25.
//

import SwiftUI

struct CardReferenceDetailView: View {
    let card: TarotCard

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CardImageView(imageName: card.imageName, cardName: card.name)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(0.6, contentMode: .fit)
                    .padding(.top, 20)

                VStack(spacing: 4) {
                    Text(card.name)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .multilineTextAlignment(.center)

                    Text("\(card.suit.rawValue) • \(card.displayNumber)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Label("Upright Meaning", systemImage: "arrow.up.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.green)

                    Text(card.upright)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Label("Reversed Meaning", systemImage: "arrow.down.circle.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)

                    Text(card.reversed)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                if !card.keywords.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Keywords", systemImage: "tag.fill")
                            .font(.headline)

                        FlowLayout(spacing: 8) {
                            ForEach(card.keywords, id: \.self) { keyword in
                                Text(keyword)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.secondary.opacity(0.2))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }

                Spacer(minLength: 20)
            }
        }
        .navigationTitle(card.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    CardReferenceDetailView(
        card: TarotCard(
            name: "The Fool",
            imageName: "major_00",
            suit: .majorArcana,
            number: 0,
            upright: "New beginnings, innocence, spontaneity, free spirit.",
            reversed: "Recklessness, taken advantage of, inconsideration.",
            keywords: ["New Beginnings", "Innocence", "Spontaneity"]
        )
    )
}
