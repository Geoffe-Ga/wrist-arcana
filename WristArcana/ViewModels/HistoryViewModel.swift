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
    @Published var selectedPullIDs: Set<UUID> = []
    @Published var showsPruningAlert: Bool = false
    @Published var showsDeleteSelectionConfirmation: Bool = false
    @Published var showsDeleteAllConfirmation: Bool = false
    @Published var showsNoteEditor: Bool = false
    @Published var editingNote: String = ""
    @Published var isEditingExistingNote: Bool = false

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
            print("⚠️ Failed to load history: \(error)")
        }
    }

    func deletePull(_ pull: CardPull) {
        self.modelContext.delete(pull)
        try? self.modelContext.save()
        Task {
            await self.loadHistory()
        }
    }

    func toggleSelection(for pull: CardPull) {
        if self.selectedPullIDs.contains(pull.id) {
            self.selectedPullIDs.remove(pull.id)
        } else {
            self.selectedPullIDs.insert(pull.id)
        }
    }

    func isPullSelected(_ pull: CardPull) -> Bool {
        self.selectedPullIDs.contains(pull.id)
    }

    func clearSelection() {
        self.selectedPullIDs.removeAll()
    }

    func requestDeleteSelectedPulls() {
        guard !self.selectedPullIDs.isEmpty else { return }
        self.showsDeleteSelectionConfirmation = true
    }

    func deleteSelectedPulls() {
        let ids = Array(self.selectedPullIDs)
        guard !ids.isEmpty else { return }

        let descriptor = FetchDescriptor<CardPull>(
            predicate: #Predicate<CardPull> { pull in
                ids.contains(pull.id)
            }
        )

        do {
            let pullsToDelete = try self.modelContext.fetch(descriptor)
            pullsToDelete.forEach { self.modelContext.delete($0) }
            try self.modelContext.save()
            self.selectedPullIDs.removeAll()
            self.showsDeleteSelectionConfirmation = false
            Task {
                await self.loadHistory()
            }
        } catch {
            print("⚠️ Failed to delete selected pulls: \(error)")
        }
    }

    func requestDeleteAllPulls() {
        self.showsDeleteAllConfirmation = true
    }

    func deleteAllPulls() {
        let descriptor = FetchDescriptor<CardPull>()

        do {
            let allPulls = try self.modelContext.fetch(descriptor)
            allPulls.forEach { self.modelContext.delete($0) }
            try self.modelContext.save()
            self.selectedPullIDs.removeAll()
            self.showsDeleteAllConfirmation = false
            Task {
                await self.loadHistory()
            }
        } catch {
            print("⚠️ Failed to delete all pulls: \(error)")
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
            print("⚠️ Failed to prune history: \(error)")
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
}
