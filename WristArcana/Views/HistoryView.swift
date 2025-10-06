//
//  HistoryView.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Combine
import SwiftData
import SwiftUI

struct HistoryView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.autoSleepManager) private var autoSleepManager

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
            Group {
                if let viewModel {
                    HistoryListContent(viewModel: viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("History")
        }
        .onAppear {
            if self.viewModel == nil {
                self.viewModel = HistoryViewModel(
                    modelContext: self.modelContext,
                    storageMonitor: self.storage
                )
                self.autoSleepManager.registerInteraction()
            }
        }
    }
}

// MARK: - Supporting Views

private struct HistoryListContent: View {
    @Environment(\.autoSleepManager) private var autoSleepManager
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        List {
            if self.viewModel.pulls.isEmpty {
                ContentUnavailableView(
                    "No Readings Yet",
                    systemImage: "sparkles",
                    description: Text("Tap DRAW to get your first card reading")
                )
            } else {
                ForEach(self.viewModel.pulls) { pull in
                    NavigationLink(destination: HistoryDetailView(pull: pull, viewModel: self.viewModel)) {
                        HistoryRow(pull: pull)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        self.viewModel.deletePull(self.viewModel.pulls[index])
                    }
                }
            }
        }
        .refreshable {
            await self.viewModel.loadHistory()
        }
        .task {
            await self.viewModel.loadHistory()
            await self.viewModel.checkStorageAndPruneIfNeeded()
        }
        .alert("Storage Full", isPresented: Binding(
            get: { self.viewModel.showsPruningAlert },
            set: { if !$0 { self.viewModel.showsPruningAlert = false } }
        )) {
            Button("Delete Oldest 50") {
                Task {
                    await self.viewModel.pruneOldestPulls(count: 50)
                }
            }
            Button("Cancel", role: .cancel) {
                self.viewModel.showsPruningAlert = false
            }
        } message: {
            Text("Your card history is full. Delete old readings to free up space?")
        }
        .sheet(isPresented: Binding(
            get: { self.viewModel.showsNoteEditor },
            set: { if !$0 { self.viewModel.dismissNoteEditor() } }
        )) {
            self.autoSleepManager.registerInteraction()

            NoteEditorView(
                note: Binding(
                    get: { self.viewModel.editingNote },
                    set: { self.viewModel.editingNote = $0 }
                ),
                onSave: { self.viewModel.saveNote() },
                onCancel: { self.viewModel.dismissNoteEditor() }
            )
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [CardPull.self])
}
