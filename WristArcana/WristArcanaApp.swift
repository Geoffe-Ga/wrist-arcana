import OSLog
import SwiftData
import SwiftUI

@main
struct WristArcanaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(self.makeModelContainer())
    }

    // MARK: - Private Methods

    /// Creates a ModelContainer with proper error handling and migration support.
    /// If migration fails (e.g., after schema changes), deletes the old database and starts fresh.
    /// This is acceptable for v1.0 as the app stores user history only (no critical data loss).
    private func makeModelContainer() -> ModelContainer {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WristArcana", category: "app")
        let schema = Schema([CardPull.self])
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // Log the migration failure
            logger.error("ModelContainer initialization failed: \(error.localizedDescription)")
            logger.warning("Attempting database reset to recover...")

            // Delete corrupted/incompatible database file
            let url = URL.applicationSupportDirectory.appending(path: "default.store")
            do {
                try FileManager.default.removeItem(at: url)
                logger.info("Deleted incompatible database at: \(url.path)")
            } catch {
                logger.error("Failed to delete database: \(error.localizedDescription)")
            }

            // Create fresh container - this should always succeed with a clean slate
            do {
                let freshContainer = try ModelContainer(for: schema, configurations: [configuration])
                logger.info("Successfully created fresh ModelContainer after reset")
                return freshContainer
            } catch {
                // If this fails, something is seriously wrong with the environment
                fatalError("Failed to create fresh ModelContainer: \(error)")
            }
        }
    }
}
