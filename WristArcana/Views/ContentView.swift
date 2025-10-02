//
//  ContentView.swift
//  WristArcana Watch App
//
//  Created by Geoff Gallinger on 10/1/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        MainView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [CardPull.self])
}
