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
    @State private var showingPreview = false
    @State private var showingDetail = false
    @State private var pendingNotePull: CardPull?
    @State private var showNoteEditor = false

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
        GeometryReader { geometry in
            ZStack {
                Color.clear
            }
            .safeAreaInset(edge: .top) {
                // Title positioned directly under clock
                Text("Tarot")
                    .font(.system(
                        size: self.scaledTitleSize(
                            for: geometry.size.height,
                            safeAreaInsets: geometry.safeAreaInsets
                        ),
                        weight: .bold,
                        design: .serif
                    ))
                    .foregroundStyle(.purple)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .safeAreaInset(edge: .bottom) {
                // Button at bottom - glow extends to absolute edge
                if let viewModel {
                    CTAButton(
                        title: "DRAW",
                        isLoading: viewModel.isDrawing,
                        action: {
                            Task {
                                await viewModel.drawCard()
                                if viewModel.currentCard != nil {
                                    self.showingPreview = true
                                }
                            }
                        }
                    )
                    .frame(
                        width: self.scaledButtonSize(
                            for: geometry.size,
                            safeAreaInsets: geometry.safeAreaInsets
                        ),
                        height: self.scaledButtonSize(
                            for: geometry.size,
                            safeAreaInsets: geometry.safeAreaInsets
                        )
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityIdentifier("draw-button")
                } else {
                    ProgressView()
                        .frame(
                            width: self.scaledButtonSize(
                                for: geometry.size,
                                safeAreaInsets: geometry.safeAreaInsets
                            ),
                            height: self.scaledButtonSize(
                                for: geometry.size,
                                safeAreaInsets: geometry.safeAreaInsets
                            )
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .sheet(isPresented: self.$showingPreview) {
            if let card = viewModel?.currentCard {
                let dismissCard: () -> Void = {
                    self.showingPreview = false
                    self.viewModel?.dismissCard()
                }

                CardPreviewView(
                    card: card,
                    onDismiss: dismissCard,
                    onShowDetail: {
                        // Dismiss preview first, then show detail
                        self.showingPreview = false
                        self.showingDetail = true
                    }
                )
            }
        }
        .fullScreenCover(isPresented: self.$showingDetail) {
            if let card = viewModel?.currentCard, let viewModel = self.viewModel {
                CardDisplayView(
                    card: card,
                    cardPull: viewModel.currentCardPull,
                    onAddNote: makeAddNoteHandler(
                        stageNote: { pull in
                            self.pendingNotePull = pull
                        },
                        dismissCard: {
                            // Dismiss detail view only
                            self.showingDetail = false
                            self.viewModel?.dismissCard()
                        }
                    ),
                    onDismiss: {
                        // Dismiss detail view, return directly to DrawCardView
                        self.showingDetail = false
                        self.viewModel?.dismissCard()
                    }
                )
            }
        }
        .onChange(of: self.showingPreview) { _, isShowing in
            guard !isShowing, !self.showingDetail,
                  let histViewModel = self.historyViewModel,
                  let pull = drainPendingNotePull(&self.pendingNotePull)
            else {
                return
            }

            histViewModel.startAddingNote(to: pull)
            self.showNoteEditor = true
        }
        .sheet(isPresented: self.$showNoteEditor) {
            if let historyViewModel = self.historyViewModel {
                NoteEditorView(
                    note: Binding(
                        get: { historyViewModel.editingNote },
                        set: { historyViewModel.editingNote = $0 }
                    ),
                    onSave: {
                        historyViewModel.saveNote()
                        self.showNoteEditor = false
                    },
                    onCancel: {
                        historyViewModel.dismissNoteEditor()
                        self.showNoteEditor = false
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
                self.viewModel = CardDrawViewModel(
                    repository: self.repository,
                    storageMonitor: self.storage,
                    modelContext: self.modelContext
                )
            }
            if self.historyViewModel == nil {
                self.historyViewModel = HistoryViewModel(
                    modelContext: self.modelContext,
                    storageMonitor: self.storage
                )
            }
        }
    }

    // MARK: - Responsive Sizing Helpers

    /// Calculate scaled button size based on screen dimensions
    /// - Formula: 70% of screen width, constrained between 120-160pt
    /// - Returns square dimension (width == height)
    /// - Respects safe area insets to prevent collisions with title
    private func scaledButtonSize(for screenSize: CGSize, safeAreaInsets: EdgeInsets) -> CGFloat {
        let baseSize = screenSize.width * 0.7
        let availableHeight = screenSize.height - safeAreaInsets.top - safeAreaInsets.bottom

        // Cap button height to prevent collision with title when safe area shrinks space
        let maxButtonHeight = availableHeight * 0.6

        return max(120, min(160, min(baseSize, maxButtonHeight)))
    }

    /// Calculate scaled title font size based on screen height
    /// - Formula: 12% of screen height, constrained between 28-36pt
    /// - Ensures readable title on all Apple Watch sizes
    /// - Respects safe area insets for consistent positioning
    private func scaledTitleSize(for screenHeight: CGFloat, safeAreaInsets: EdgeInsets) -> CGFloat {
        let availableHeight = screenHeight - safeAreaInsets.top - safeAreaInsets.bottom
        let baseSize = availableHeight * 0.12
        return max(28, min(36, baseSize))
    }
}

#Preview("41mm Watch") {
    DrawCardView()
        .modelContainer(for: [CardPull.self])
}

#Preview("45mm Watch") {
    DrawCardView()
        .modelContainer(for: [CardPull.self])
}

#Preview("49mm Ultra") {
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
