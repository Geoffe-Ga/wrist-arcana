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

            // Delete corrupted/incompatible database directory
            // SwiftData stores the database as a directory with SQLite files inside
            let databaseUrl = configuration.url ?? URL.applicationSupportDirectory.appending(path: "default.store")

            // Check if database exists and remove entire directory structure
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: databaseUrl.path, isDirectory: &isDirectory) {
                do {
                    try FileManager.default.removeItem(at: databaseUrl)
                    logger.info("Deleted incompatible database directory at: \(databaseUrl.path)")
                } catch let deleteError as NSError {
                    logger.error("Failed to delete database: \(deleteError.localizedDescription)")

                    // If file doesn't exist, that's fine - continue with recovery
                    // Otherwise, warn that fresh container init may still fail
                    if deleteError.domain != NSCocoaErrorDomain || deleteError.code != NSFileNoSuchFileError {
                        logger.warning("Database may still be corrupted, fresh container init may fail")
                    }
                }
            }

            // Attempt to create fresh container
            do {
                let freshContainer = try ModelContainer(for: schema, configurations: [configuration])
                logger.info("Successfully created fresh ModelContainer after reset")
                return freshContainer
            } catch {
                // Last resort: use in-memory container to keep app functional
                // User can still draw cards even if history won't persist
                logger.critical("Failed to create fresh ModelContainer: \(error.localizedDescription)")
                logger.info("Falling back to in-memory container - history will not persist this session")

                let memoryConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )

                do {
                    // In-memory containers should always succeed (no file system dependencies)
                    return try ModelContainer(for: schema, configurations: [memoryConfig])
                } catch {
                    // If even in-memory container fails, this is a critical system error
                    fatalError("Critical: Failed to create in-memory ModelContainer: \(error)")
                }
            }
        }
    }
}
