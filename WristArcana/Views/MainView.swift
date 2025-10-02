//
//  MainView.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import SwiftUI

struct MainView: View {
    // MARK: - State

    @State private var selectedTab = 0

    // MARK: - Body

    var body: some View {
        TabView(selection: self.$selectedTab) {
            DrawCardView()
                .tag(0)

            HistoryView()
                .tag(1)
        }
        .tabViewStyle(.page)
    }
}

#Preview {
    MainView()
        .modelContainer(for: [CardPull.self])
}
