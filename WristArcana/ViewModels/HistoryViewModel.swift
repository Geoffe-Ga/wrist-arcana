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
    @Published var errorMessage: String?

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
            self.errorMessage = "Failed to load history. Please try again."
            print("⚠️ Failed to load history: \(error)")
            self.pulls = []
        }
    }

    func deletePull(_ pull: CardPull) {
        self.modelContext.delete(pull)
        do {
            try self.modelContext.save()
            Task {
                await self.loadHistory()
            }
        } catch {
            self.errorMessage = "Unable to delete reading. Please try again."
            print("⚠️ Failed to delete pull: \(error)")
        }
    }

    func selectPull(_ pull: CardPull) {
        self.selectedPull = pull
    }

    func startAddingNote(to pull: CardPull) {
        self.selectedPull = pull
        self.editingNote = pull.note ?? ""
        self.isEditingExistingNote = pull.hasNote
        self.showsNoteEditor = true
    }

    func saveNote() {
        guard let pull = self.selectedPull else {
            self.errorMessage = "No reading selected for note."
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
            self.errorMessage = "Failed to save note. Please try again."
            print("⚠️ Failed to save note: \(error)")
        }

        self.dismissNoteEditor()
    }

    func deleteNote(from pull: CardPull) {
        pull.note = nil
        do {
            try self.modelContext.save()
            Task {
                await self.loadHistory()
            }
        } catch {
            self.errorMessage = "Failed to delete note. Please try again."
            print("⚠️ Failed to delete note: \(error)")
        }
    }

    func dismissNoteEditor() {
        self.showsNoteEditor = false
        self.editingNote = ""
        self.selectedPull = nil
        self.isEditingExistingNote = false
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
            let oldestPulls = try self.modelContext.fetch(descriptor).prefix(count)
            oldestPulls.forEach { self.modelContext.delete($0) }
            try self.modelContext.save()
            await self.loadHistory()
            self.showsPruningAlert = false
        } catch {
            self.errorMessage = "Failed to prune history. Please try again."
            print("⚠️ Failed to prune history: \(error)")
        }
    }
}
