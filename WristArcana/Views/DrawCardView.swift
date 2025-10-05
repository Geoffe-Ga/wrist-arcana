//
//  DrawCardView.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import SwiftData
import SwiftUI

struct DrawCardView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext

    // MARK: - State

    @State private var viewModel: CardDrawViewModel?
    @State private var historyViewModel: HistoryViewModel?
    @State private var showingCard = false
    @State private var pendingNotePull: CardPull?

    // Dependencies
    private let repository: DeckRepositoryProtocol
    private let storage: StorageMonitorProtocol

    // MARK: - Initialization

    init(
        repository: DeckRepositoryProtocol = DeckRepository(),
        storage: StorageMonitorProtocol = StorageMonitor()
    ) {
        self.repository = repository
        self.storage = storage
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            // App Title
            Text("Tarot")
                .font(Theme.Fonts.title)
                .foregroundStyle(.purple)

            Spacer()

            // Main CTA Button
            if let viewModel {
                CTAButton(
                    title: "DRAW",
                    isLoading: viewModel.isDrawing,
                    action: {
                        Task {
                            await viewModel.drawCard()
                            if viewModel.currentCard != nil {
                                self.showingCard = true
                            }
                        }
                    }
                )
                .frame(width: 140, height: 140)
            } else {
                ProgressView()
                    .frame(width: 140, height: 140)
            }

            Spacer()
        }
        .sheet(isPresented: self.$showingCard) {
            if let card = viewModel?.currentCard {
                let dismissCard: () -> Void = {
                    self.showingCard = false
                    self.viewModel?.dismissCard()
                }

                CardDisplayView(
                    card: card,
                    cardPull: self.viewModel?.currentCardPull,
                    onAddNote: makeAddNoteHandler(
                        stageNote: { pull in
                            self.pendingNotePull = pull
                        },
                        dismissCard: dismissCard
                    ),
                    onDismiss: dismissCard
                )
            }
        }
        .onChange(of: self.showingCard) { _, isShowingCard in
            guard !isShowingCard,
                  let histViewModel = self.historyViewModel,
                  let pull = drainPendingNotePull(&self.pendingNotePull)
            else {
                return
            }

            histViewModel.startAddingNote(to: pull)
        }
        .sheet(isPresented: Binding(
            get: { self.historyViewModel?.showsNoteEditor ?? false },
            set: { if !$0 { self.historyViewModel?.dismissNoteEditor() } }
        )) {
            if let historyViewModel = self.historyViewModel {
                NoteEditorView(
                    note: Binding(
                        get: { self.historyViewModel?.editingNote ?? "" },
                        set: { self.historyViewModel?.editingNote = $0 }
                    ),
                    onSave: {
                        self.historyViewModel?.saveNote()
                    },
                    onCancel: {
                        self.historyViewModel?.dismissNoteEditor()
                    }
                )
            }
        }
        .alert("Storage Warning", isPresented: Binding(
            get: { self.viewModel?.showsStorageWarning ?? false },
            set: { if !$0 { self.viewModel?.acknowledgeStorageWarning() } }
        )) {
            Button("OK") {
                self.viewModel?.acknowledgeStorageWarning()
            }
        } message: {
            Text("Your card history is using significant storage. Consider deleting old readings.")
        }
        .alert("Error", isPresented: Binding(
            get: { self.viewModel?.errorMessage != nil },
            set: { if !$0 { self.viewModel?.errorMessage = nil } }
        )) {
            Button("OK") {
                self.viewModel?.errorMessage = nil
            }
        } message: {
            if let error = viewModel?.errorMessage {
                Text(error)
            }
        }
        .onAppear {
            if self.viewModel == nil {
                // Create ViewModel with proper environment context
                self.viewModel = CardDrawViewModel(
                    repository: self.repository,
                    storageMonitor: self.storage,
                    modelContext: self.modelContext
                )
            }
            if self.historyViewModel == nil {
                // Create HistoryViewModel for note-taking
                self.historyViewModel = HistoryViewModel(
                    modelContext: self.modelContext,
                    storageMonitor: self.storage
                )
            }
        }
    }
}

#Preview {
    DrawCardView()
        .modelContainer(for: [CardPull.self])
}

#Preview {
    DrawCardView()
        .modelContainer(for: [CardPull.self])
}

func makeAddNoteHandler(
    stageNote: @escaping (CardPull) -> Void,
    dismissCard: @escaping () -> Void
) -> (CardPull) -> Void {
    { pull in
        stageNote(pull)
        dismissCard()
    }
}

func drainPendingNotePull(_ pendingPull: inout CardPull?) -> CardPull? {
    guard let pull = pendingPull else { return nil }
    pendingPull = nil
    return pull
}
