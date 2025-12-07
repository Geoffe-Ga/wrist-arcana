//
//  HistoryViewModel.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation
import SwiftData

@MainActor
final class HistoryViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var pulls: [CardPull] = []
    @Published var selectedPull: CardPull?
    @Published var showsPruningAlert: Bool = false
    @Published var showsNoteEditor: Bool = false
    @Published var editingNote: String = ""
    @Published var isEditingExistingNote: Bool = false

    // MARK: - Multi-Delete Properties

    @Published var isInEditMode: Bool = false
    @Published var selectedPullIds: Set<UUID> = []

    // MARK: - Private Properties

    private let modelContext: ModelContext
    private let storageMonitor: StorageMonitorProtocol
    private let maxPullsToDisplay = 100

    // MARK: - Initialization

    init(modelContext: ModelContext, storageMonitor: StorageMonitorProtocol) {
        self.modelContext = modelContext
        self.storageMonitor = storageMonitor
    }

    // MARK: - Public Methods

    func loadHistory() async {
        let descriptor = FetchDescriptor<CardPull>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        do {
            self.pulls = try self.modelContext.fetch(descriptor)
                .prefix(self.maxPullsToDisplay)
                .map { $0 }
        } catch {
            // Silently fail - history will be empty
        }
    }

    func deletePull(_ pull: CardPull) {
        self.modelContext.delete(pull)
        try? self.modelContext.save()
        Task {
            await self.loadHistory()
        }
    }

    func selectPull(_ pull: CardPull) {
        self.selectedPull = pull
    }

    func checkStorageAndPruneIfNeeded() async {
        if self.storageMonitor.isNearCapacity() {
            self.showsPruningAlert = true
        }
    }

    func pruneOldestPulls(count: Int = 50) async {
        let descriptor = FetchDescriptor<CardPull>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )

        do {
            let oldestPulls = try modelContext.fetch(descriptor).prefix(count)
            oldestPulls.forEach { self.modelContext.delete($0) }
            try self.modelContext.save()
            await self.loadHistory()
            self.showsPruningAlert = false
        } catch {
            // Silently fail - pruning alert remains visible
        }
    }

    // MARK: - Note Management

    func startAddingNote(to pull: CardPull) {
        self.selectedPull = pull
        self.editingNote = pull.note ?? ""
        self.isEditingExistingNote = pull.hasNote
        self.showsNoteEditor = true
    }

    func saveNote() {
        guard let pull = self.selectedPull else {
            self.dismissNoteEditor()
            return
        }

        let sanitized = NoteInputSanitizer.sanitize(self.editingNote)

        // Fetch the pull from the context to ensure it's properly managed
        let pullID = pull.id
        let descriptor = FetchDescriptor<CardPull>(
            predicate: #Predicate<CardPull> { cardPull in
                cardPull.id == pullID
            }
        )

        do {
            guard let managedPull = try self.modelContext.fetch(descriptor).first else {
                self.dismissNoteEditor()
                return
            }

            if sanitized.isEmpty {
                managedPull.note = nil
            } else {
                managedPull.note = sanitized
            }

            try self.modelContext.save()
            Task {
                await self.loadHistory()
            }
            self.dismissNoteEditor()
        } catch {
            self.dismissNoteEditor()
        }
    }

    func deleteNote(from pull: CardPull) {
        pull.note = nil
        try? self.modelContext.save()
        Task {
            await self.loadHistory()
        }
    }

    func dismissNoteEditor() {
        self.showsNoteEditor = false
        self.editingNote = ""
        self.selectedPull = nil
        self.isEditingExistingNote = false
    }

    // MARK: - Multi-Delete Methods

    /// Enters edit mode for multi-selection
    func enterEditMode() {
        self.isInEditMode = true
        self.selectedPullIds.removeAll()
    }

    /// Exits edit mode and clears selections
    func exitEditMode() {
        self.isInEditMode = false
        self.selectedPullIds.removeAll()
    }

    /// Toggles selection state for a pull
    func toggleSelection(for pull: CardPull) {
        if self.selectedPullIds.contains(pull.id) {
            self.selectedPullIds.remove(pull.id)
        } else {
            self.selectedPullIds.insert(pull.id)
        }
    }

    /// Checks if a pull is currently selected
    func isSelected(_ pull: CardPull) -> Bool {
        self.selectedPullIds.contains(pull.id)
    }

    /// Deletes multiple pulls by their IDs
    func deleteMultiplePulls(ids: Set<UUID>) async {
        let pullsToDelete = self.pulls.filter { ids.contains($0.id) }

        for pull in pullsToDelete {
            self.modelContext.delete(pull)
        }

        do {
            try self.modelContext.save()
        } catch {
            // Silently fail - UI will show stale data
        }

        // Reset state
        self.selectedPullIds.removeAll()
        self.isInEditMode = false

        // Defer reload to avoid publishing errors
        try? await Task.sleep(nanoseconds: 100_000_000)
        await self.loadHistory()
    }

    /// Deletes ALL pulls from history (nuclear option)
    func clearAllHistory() async {
        let allPulls = self.pulls
        for pull in allPulls {
            self.modelContext.delete(pull)
        }

        do {
            try self.modelContext.save()
        } catch {
            // Silently fail - UI will show stale data
        }

        // Reset state
        self.pulls = []
        self.selectedPullIds.removeAll()
        self.isInEditMode = false
    }
}
