//
//  CardReferenceView.swift
//  WristArcana
//
//  Created by OpenAI on 10/1/25.
//

import SwiftUI

struct CardReferenceView: View {
    @StateObject private var viewModel = CardReferenceViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.suits, id: \.self) { suit in
                    NavigationLink(value: suit) {
                        SuitRow(
                            suit: suit,
                            cardCount: viewModel.cardCount(for: suit)
                        )
                    }
                }
            }
            .navigationDestination(for: TarotCard.Suit.self) { suit in
                CardListView(suit: suit, viewModel: viewModel)
            }
            .navigationTitle("Reference")
        }
        .onAppear {
            viewModel.loadSuits()
        }
    }
}

struct SuitRow: View {
    let suit: TarotCard.Suit
    let cardCount: Int

    var body: some View {
        HStack {
            Text(suit.icon)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text(suit.rawValue)
                    .font(.headline)

                Text("\(cardCount) cards")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    CardReferenceView()
}
