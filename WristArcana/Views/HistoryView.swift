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

    // MARK: - State

    @State private var showMultiDeleteAlert = false
    @State private var showClearAllAlert = false

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                // MARK: - History Items Section

                Section {
                    // Management buttons (only when not in edit mode and has items)
                    if !self.viewModel.pulls.isEmpty, !self.viewModel.isInEditMode {
                        self.managementButtonsView
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    }

                    // Empty state or history items
                    if self.viewModel.pulls.isEmpty {
                        ContentUnavailableView(
                            "No Readings Yet",
                            systemImage: "sparkles",
                            description: Text("Tap DRAW to get your first card reading")
                        )
                    } else {
                        ForEach(self.viewModel.pulls) { pull in
                            self.historyItemView(for: pull)
                        }
                        .onDelete { indexSet in
                            // Swipe-to-delete (disabled in edit mode)
                            if !self.viewModel.isInEditMode {
                                for index in indexSet {
                                    self.viewModel.deletePull(self.viewModel.pulls[index])
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)

            // MARK: - Delete Button (Edit Mode)

            if self.viewModel.isInEditMode, !self.viewModel.selectedPullIds.isEmpty {
                self.deleteSelectedButton
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .toolbar {
            if self.viewModel.isInEditMode {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        self.viewModel.exitEditMode()
                    }
                }
            }
        }
        .animation(.easeInOut, value: self.viewModel.isInEditMode)
        .animation(.easeInOut, value: self.viewModel.selectedPullIds.count)
        .refreshable {
            await self.viewModel.loadHistory()
        }
        .task {
            await self.viewModel.loadHistory()
            await self.viewModel.checkStorageAndPruneIfNeeded()
        }

        // MARK: - Multi-Delete Alert

        .alert(
            "Delete \(self.viewModel.selectedPullIds.count) items?",
            isPresented: self.$showMultiDeleteAlert
        ) {
            Button("Delete", role: .destructive) {
                Task {
                    await self.viewModel.deleteMultiplePulls(ids: self.viewModel.selectedPullIds)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }

        // MARK: - Clear All Alert

        .alert(
            "Delete all \(self.viewModel.pulls.count) card readings?",
            isPresented: self.$showClearAllAlert
        ) {
            Button("Delete All", role: .destructive) {
                Task {
                    await self.viewModel.clearAllHistory()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete your entire history. This cannot be undone.")
        }

        // MARK: - Storage Alert

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

        // MARK: - Note Editor Sheet

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

    // MARK: - Subviews

    private func historyItemView(for pull: CardPull) -> some View {
        Group {
            if self.viewModel.isInEditMode {
                // In edit mode: button for selection
                Button {
                    self.viewModel.toggleSelection(for: pull)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: self.viewModel.isSelected(pull) ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(self.viewModel.isSelected(pull) ? .blue : .gray)
                            .imageScale(.large)
                            .frame(width: 24, height: 24)

                        HistoryRow(pull: pull)
                    }
                }
                .buttonStyle(.plain)
            } else {
                // Normal mode: navigation link to detail
                NavigationLink(destination: HistoryDetailView(pull: pull, viewModel: self.viewModel)) {
                    HistoryRow(pull: pull)
                }
            }
        }
    }

    private var managementButtonsView: some View {
        HStack(spacing: 8) {
            Button {
                print("🔍 DEBUG: Select button tapped")
                self.viewModel.enterEditMode()
            } label: {
                Label("Select", systemImage: "checkmark.circle")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue.opacity(0.15))
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)

            Button {
                print("🔍 DEBUG: Clear All button tapped")
                self.showClearAllAlert = true
            } label: {
                Label("Clear All", systemImage: "trash")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red.opacity(0.15))
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }

    private var deleteSelectedButton: some View {
        Button {
            print("🔍 DEBUG: Delete selected button tapped (\(self.viewModel.selectedPullIds.count) items)")
            self.showMultiDeleteAlert = true
        } label: {
            Label("Delete \(self.viewModel.selectedPullIds.count)", systemImage: "trash.fill")
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [CardPull.self])
}
