import SwiftUI
import SwiftData

@main
struct WristArcanaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [CardPull.self])
    }
}
