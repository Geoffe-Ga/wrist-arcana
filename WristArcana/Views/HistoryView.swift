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
            }
        }
    }
}

// MARK: - Supporting Views

private struct HistoryListContent: View {
    @ObservedObject var viewModel: HistoryViewModel
    @State private var isEditingSelection: Bool = false

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
                    if self.isEditingSelection {
                        HStack(spacing: 12) {
                            Image(systemName: self.viewModel.isPullSelected(pull) ? "checkmark.circle.fill" : "circle")
                                .imageScale(.large)
                                .foregroundStyle(self.viewModel.isPullSelected(pull) ? .accent : .secondary)

                            HistoryRow(pull: pull)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.viewModel.toggleSelection(for: pull)
                        }
                    } else {
                        NavigationLink(destination: HistoryDetailView(pull: pull, viewModel: self.viewModel)) {
                            HistoryRow(pull: pull)
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        self.viewModel.deletePull(self.viewModel.pulls[index])
                    }
                }
            }
        }
        .animation(.default, value: self.isEditingSelection)
        .refreshable {
            await self.viewModel.loadHistory()
        }
        .task {
            await self.viewModel.loadHistory()
            await self.viewModel.checkStorageAndPruneIfNeeded()
        }
        .onChange(of: self.isEditingSelection) { isEditing in
            if !isEditing {
                self.viewModel.clearSelection()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(self.isEditingSelection ? "Done" : "Select") {
                    withAnimation {
                        self.isEditingSelection.toggle()
                    }
                }
                .disabled(self.viewModel.pulls.isEmpty)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("Clear All", role: .destructive) {
                    self.viewModel.requestDeleteAllPulls()
                }
                .disabled(self.viewModel.pulls.isEmpty)
            }

            ToolbarItem(placement: .bottomBar) {
                if self.isEditingSelection {
                    Button(role: .destructive) {
                        self.viewModel.requestDeleteSelectedPulls()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .labelStyle(.titleAndIcon)
                    }
                    .disabled(self.viewModel.selectedPullIDs.isEmpty)
                }
            }
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
        .confirmationDialog(
            "Delete selected readings?",
            isPresented: Binding(
                get: { self.viewModel.showsDeleteSelectionConfirmation },
                set: { self.viewModel.showsDeleteSelectionConfirmation = $0 }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete Selected", role: .destructive) {
                self.viewModel.deleteSelectedPulls()
            }
            Button("Cancel", role: .cancel) {
                self.viewModel.showsDeleteSelectionConfirmation = false
            }
        } message: {
            Text("This will remove all selected readings from your history.")
        }
        .confirmationDialog(
            "Clear entire history?",
            isPresented: Binding(
                get: { self.viewModel.showsDeleteAllConfirmation },
                set: { self.viewModel.showsDeleteAllConfirmation = $0 }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete All", role: .destructive) {
                self.viewModel.deleteAllPulls()
            }
            Button("Cancel", role: .cancel) {
                self.viewModel.showsDeleteAllConfirmation = false
            }
        } message: {
            Text("This action cannot be undone. All saved readings will be deleted.")
        }
        .sheet(isPresented: Binding(
            get: { self.viewModel.showsNoteEditor },
            set: { _ in }
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
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [CardPull.self])
}
