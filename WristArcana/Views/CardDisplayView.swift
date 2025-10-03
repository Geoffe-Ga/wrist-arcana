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
    let cardPull: CardPull
    @ObservedObject var viewModel: HistoryViewModel
    let onDismiss: () -> Void

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CardImageView(imageName: self.card.imageName, cardName: self.card.name)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(0.6, contentMode: .fit)
                    .padding(.top, 20)

                Text(self.card.name)
                    .font(Theme.Fonts.cardName)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Text(self.card.upright)
                    .font(Theme.Fonts.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    if let note = self.cardPull.note, !note.isEmpty {
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

                        Button(action: {
                            self.viewModel.startAddingNote(to: self.cardPull)
                        }) {
                            Label("Edit Note", systemImage: "pencil")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Button(action: {
                            self.viewModel.startAddingNote(to: self.cardPull)
                        }) {
                            Label("Add Note", systemImage: "note.text.badge.plus")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
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
        .sheet(isPresented: Binding(
            get: { self.viewModel.showsNoteEditor },
            set: { newValue in
                if !newValue {
                    self.viewModel.dismissNoteEditor()
                } else {
                    self.viewModel.showsNoteEditor = newValue
                }
            }
        )) {
            NoteEditorView(
                note: Binding(
                    get: { self.viewModel.editingNote },
                    set: { self.viewModel.editingNote = $0 }
                ),
                onSave: { self.viewModel.saveNote() },
                onCancel: { self.viewModel.dismissNoteEditor() }
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Card details for \(self.card.name)")
    }
}
