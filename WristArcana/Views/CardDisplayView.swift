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
    var historyViewModel: HistoryViewModel?
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

                // Note Section (if cardPull and historyViewModel are available)
                if let pull = cardPull, let viewModel = historyViewModel {
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
                                    viewModel.startAddingNote(to: pull)
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
                                    viewModel.startAddingNote(to: pull)
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
        .sheet(isPresented: Binding(
            get: { self.historyViewModel?.showsNoteEditor ?? false },
            set: { if !$0 { self.historyViewModel?.dismissNoteEditor() } }
        )) {
            if let activeViewModel = historyViewModel {
                NoteEditorView(
                    note: Binding(
                        get: { activeViewModel.editingNote },
                        set: { activeViewModel.editingNote = $0 }
                    ),
                    onSave: { activeViewModel.saveNote() },
                    onCancel: { activeViewModel.dismissNoteEditor() }
                )
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
            historyViewModel: nil,
            onDismiss: {}
        )
    }
}
