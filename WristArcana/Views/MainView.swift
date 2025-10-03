//
//  MainView.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import SwiftUI

struct MainView: View {
    // MARK: - State

    @State private var selectedTab = 1

    // MARK: - Body

    var body: some View {
        TabView(selection: self.$selectedTab) {
            CardReferenceView()
                .tag(0)
                .tabItem {
                    Label("Reference", systemImage: "book.fill")
                }

            DrawCardView()
                .tag(1)
                .tabItem {
                    Label("Draw", systemImage: "sparkles")
                }

            HistoryView()
                .tag(2)
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
        }
        .tabViewStyle(.page)
    }
}

#Preview {
    MainView()
        .modelContainer(for: [CardPull.self])
}
