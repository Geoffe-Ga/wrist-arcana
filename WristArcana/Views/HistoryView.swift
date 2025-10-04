//
//  HistoryView.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import SwiftData
import SwiftUI

struct HistoryView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var viewModel: HistoryViewModel?

    // Dependencies
    private let storage: StorageMonitorProtocol

    // MARK: - Initialization

    init(storage: StorageMonitorProtocol = StorageMonitor()) {
        self.storage = storage
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            if let viewModel {
                List {
                    if viewModel.pulls.isEmpty {
                        ContentUnavailableView(
                            "No Readings Yet",
                            systemImage: "sparkles",
                            description: Text("Tap DRAW to get your first card reading")
                        )
                    } else {
                        ForEach(viewModel.pulls) { pull in
                            NavigationLink(destination: HistoryDetailView(pull: pull, viewModel: viewModel)) {
                                HistoryRow(pull: pull)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deletePull(viewModel.pulls[index])
                            }
                        }
                    }
                }
                .navigationTitle("History")
                .task {
                    await viewModel.checkStorageAndPruneIfNeeded()
                }
                .alert("Storage Full", isPresented: Binding(
                    get: { viewModel.showsPruningAlert },
                    set: { if !$0 { viewModel.showsPruningAlert = false } }
                )) {
                    Button("Delete Oldest 50") {
                        Task {
                            await viewModel.pruneOldestPulls(count: 50)
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        viewModel.showsPruningAlert = false
                    }
                } message: {
                    Text("Your card history is full. Delete old readings to free up space?")
                }
                .sheet(isPresented: Binding(
                    get: { viewModel.showsNoteEditor },
                    set: { if !$0 { viewModel.dismissNoteEditor() } }
                )) {
                    if let activeViewModel = self.viewModel {
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
            } else {
                ProgressView()
                    .navigationTitle("History")
            }
        }
        .onAppear {
            if self.viewModel == nil {
                // Create ViewModel with proper environment context
                self.viewModel = HistoryViewModel(
                    modelContext: self.modelContext,
                    storageMonitor: self.storage
                )
            }
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [CardPull.self])
}
