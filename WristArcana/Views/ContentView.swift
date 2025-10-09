//
//  ContentView.swift
//  WristArcana Watch App
//
//  Created by Geoff Gallinger on 10/1/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.autoSleepManager) private var autoSleepManager
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        MainView()
            .reportUserInteractions(using: self.autoSleepManager)
            .onAppear {
                self.autoSleepManager.registerInteraction()
            }
            .onChange(of: self.scenePhase) { _, newPhase in
                if newPhase == .active {
                    self.autoSleepManager.registerInteraction()
                }
            }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CardPull.self])
}
