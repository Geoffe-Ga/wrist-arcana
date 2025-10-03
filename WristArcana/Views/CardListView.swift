//
//  CardListView.swift
//  WristArcana
//
//  Created by OpenAI on 10/1/25.
//

import SwiftUI

struct CardListView: View {
    let suit: TarotCard.Suit
    @ObservedObject var viewModel: CardReferenceViewModel

    var body: some View {
        List {
            ForEach(viewModel.cardsInSuit) { card in
                NavigationLink(value: card) {
                    CardListRow(card: card)
                }
            }
        }
        .navigationDestination(for: TarotCard.self) { card in
            CardReferenceDetailView(card: card)
        }
        .navigationTitle(suit.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.selectSuit(suit)
        }
    }
}

struct CardListRow: View {
    let card: TarotCard

    var body: some View {
        HStack(spacing: 12) {
            CardImageView(imageName: card.imageName, cardName: card.name)
                .frame(width: 30, height: 45)

            Text(card.fullDisplayName)
                .font(.body)
                .lineLimit(2)

            Spacer()
        }
        .padding(.vertical, 2)
    }
}

