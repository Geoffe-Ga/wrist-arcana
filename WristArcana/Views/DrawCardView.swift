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

            Text("Tarot")
                .font(Theme.Fonts.title)
                .foregroundStyle(.purple)

            Spacer()

            if let viewModel {
                CTAButton(
                    title: "DRAW",
                    isLoading: viewModel.isDrawing,
                    action: {
                        Task {
                            await viewModel.drawCard()
                            if viewModel.currentCard != nil {
                                if let historyViewModel {
                                    await historyViewModel.loadHistory()
                                }
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
            if
                let card = viewModel?.currentCard,
                let pull = viewModel?.currentPull,
                let historyViewModel
            {
                CardDisplayView(
                    card: card,
                    cardPull: pull,
                    viewModel: historyViewModel
                ) {
                    self.showingCard = false
                    self.viewModel?.dismissCard()
                }
            } else {
                ProgressView()
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
}

#Preview {
    DrawCardView()
        .modelContainer(for: [CardPull.self])
}

#Preview {
    DrawCardView()
        .modelContainer(for: [CardPull.self])
}
