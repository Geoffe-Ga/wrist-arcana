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
                            NavigationLink {
                                HistoryDetailView(pull: pull, viewModel: viewModel)
                            } label: {
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
                .toolbar {
                    EditButton()
                }
                .sheet(isPresented: Binding(
                    get: { viewModel.showsNoteEditor },
                    set: { newValue in
                        if !newValue {
                            viewModel.dismissNoteEditor()
                        } else {
                            viewModel.showsNoteEditor = newValue
                        }
                    }
                )) {
                    NoteEditorView(
                        note: Binding(
                            get: { viewModel.editingNote },
                            set: { viewModel.editingNote = $0 }
                        ),
                        onSave: { viewModel.saveNote() },
                        onCancel: { viewModel.dismissNoteEditor() }
                    )
                }
                .task {
                    await viewModel.checkStorageAndPruneIfNeeded()
                }
                .alert("Storage Full", isPresented: Binding(
                    get: { viewModel.showsPruningAlert },
                    set: { newValue in
                        if !newValue {
                            viewModel.showsPruningAlert = false
                        } else {
                            viewModel.showsPruningAlert = newValue
                        }
                    }
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
                .alert("Error", isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { newValue in
                        if !newValue {
                            viewModel.errorMessage = nil
                        }
                    }
                )) {
                    Button("OK") {
                        viewModel.errorMessage = nil
                    }
                } message: {
                    if let message = viewModel.errorMessage {
                        Text(message)
                    }
                }
            } else {
                ProgressView()
                    .navigationTitle("History")
            }
        }
        .onAppear {
            if self.viewModel == nil {
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
