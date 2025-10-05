//
//  HistoryDetailView.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/3/25.
//

import SwiftUI

struct HistoryDetailView: View {
    // MARK: - Properties

    let pull: CardPull
    @ObservedObject var viewModel: HistoryViewModel
    @State private var showDeleteNoteAlert = false

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Card Image
                CardImageView(
                    imageName: self.pull.cardImageName,
                    cardName: self.pull.cardName
                )
                .frame(maxWidth: .infinity)
                .aspectRatio(0.6, contentMode: .fit)
                .padding(.top, 20)

                // Card Info
                VStack(spacing: 8) {
                    Text(self.pull.cardName)
                        .font(.system(size: 20, weight: .semibold, design: .serif))
                        .multilineTextAlignment(.center)

                    Text(self.pull.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Card Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meaning")
                        .font(.headline)

                    Text(self.pull.cardDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                Divider()
                    .padding(.horizontal)

                // Note Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("Your Note", systemImage: "note.text")
                            .font(.headline)
                        Spacer()
                    }

                    if let note = self.pull.note, !note.isEmpty {
                        Text(note)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)

                        HStack(spacing: 12) {
                            Button(
                                action: {
                                    self.viewModel.startAddingNote(to: self.pull)
                                },
                                label: {
                                    Label("Edit", systemImage: "pencil")
                                        .font(.caption)
                                }
                            )
                            .buttonStyle(.bordered)

                            Button(
                                role: .destructive,
                                action: {
                                    self.showDeleteNoteAlert = true
                                },
                                label: {
                                    Label("Delete", systemImage: "trash")
                                        .font(.caption)
                                }
                            )
                            .buttonStyle(.bordered)
                        }
                    } else {
                        Button(
                            action: {
                                self.viewModel.startAddingNote(to: self.pull)
                            },
                            label: {
                                Label("Add Note", systemImage: "plus.circle")
                            }
                        )
                        .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("Card Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Note", isPresented: self.$showDeleteNoteAlert) {
            Button("Delete", role: .destructive) {
                self.viewModel.deleteNote(from: self.pull)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this note? This cannot be undone.")
        }
    }
}
