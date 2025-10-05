import SwiftData
import SwiftUI

@main
struct WristArcanaApp: App {
    let container: ModelContainer

    init() {
        do {
            // Create a fresh container with the current schema
            // This will create a NEW database file, leaving old data behind
            let config = ModelConfiguration(
                schema: Schema([CardPull.self]),
                url: URL.documentsDirectory.appending(path: "WristArcana_v2.sqlite"),
                cloudKitDatabase: .none
            )
            self.container = try ModelContainer(for: CardPull.self, configurations: config)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(self.container)
    }
}
