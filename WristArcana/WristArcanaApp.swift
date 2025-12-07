import SwiftData
import SwiftUI

@main
struct WristArcanaApp: App {
    /// Shared ModelContainer used by both the app and App Intents to prevent database conflicts.
    /// Creating multiple containers can cause SQLite lock issues and data inconsistency.
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([CardPull.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // If container creation fails, this is a critical error
            fatalError("Failed to create shared ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(Self.sharedModelContainer)
    }
}
