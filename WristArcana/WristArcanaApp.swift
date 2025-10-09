import SwiftData
import SwiftUI

@main
struct WristArcanaApp: App {
    private let autoSleepManager = AutoSleepManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.autoSleepManager, self.autoSleepManager)
        }
        .modelContainer(for: [CardPull.self])
    }
}
