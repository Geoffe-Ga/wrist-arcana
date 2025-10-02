//
//  DeckSelectionView.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import SwiftUI

struct DeckSelectionView: View {
    // MARK: - Properties

    let decks: [TarotDeck]
    @Binding var selectedDeckId: UUID

    // MARK: - Body

    var body: some View {
        List(self.decks) { deck in
            Button {
                self.selectedDeckId = deck.id
            } label: {
                HStack {
                    Text(deck.name)
                    Spacer()
                    if deck.id == self.selectedDeckId {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                    }
                }
            }
            .accessibilityLabel(deck.name)
            .accessibilityHint(deck.id == self.selectedDeckId ? "Currently selected" : "Tap to select this deck")
        }
        .navigationTitle("Select Deck")
    }
}

#Preview {
    NavigationStack {
        DeckSelectionView(
            decks: [
                TarotDeck(name: "Rider-Waite", cards: []),
                TarotDeck(name: "Marseille", cards: [])
            ],
            selectedDeckId: .constant(UUID())
        )
    }
}
