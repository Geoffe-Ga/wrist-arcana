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

    // MARK: - Private Properties

    private let modelContext: ModelContext
    private let storageMonitor: StorageMonitorProtocol
    private let maxPullsToDisplay = 100

    // MARK: - Initialization

    init(modelContext: ModelContext, storageMonitor: StorageMonitorProtocol) {
        self.modelContext = modelContext
        self.storageMonitor = storageMonitor
        Task {
            await self.loadHistory()
        }
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
            print("⚠️ No pull selected for note save")
            return
        }

        let sanitized = NoteInputSanitizer.sanitize(self.editingNote)

        if sanitized.isEmpty {
            pull.note = nil
        } else {
            pull.note = sanitized
        }

        do {
            try self.modelContext.save()
            Task {
                await self.loadHistory()
            }
        } catch {
            print("⚠️ Failed to save note: \(error)")
        }

        self.dismissNoteEditor()
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
