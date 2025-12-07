import OSLog
import SwiftData
import SwiftUI

@main
struct WristArcanaApp: App {
    /// Shared ModelContainer used by both the app and App Intents to prevent database conflicts.
    /// Creating multiple containers can cause SQLite lock issues and data inconsistency.
    /// This static property is created once at app launch, preventing race conditions.
    static let sharedModelContainer: ModelContainer = {
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
            let databaseUrl: URL
            if let configUrl = configuration.url {
                databaseUrl = configUrl
            } else {
                // Fallback: construct SwiftData's default location using FileManager
                guard let appSupportUrl = FileManager.default.urls(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask
                ).first else {
                    logger.error("Failed to get Application Support directory")
                    return Self.createInMemoryContainer(schema: schema, logger: logger)
                }

                let bundleId = Bundle.main.bundleIdentifier ?? "WristArcana"
                databaseUrl = appSupportUrl
                    .appendingPathComponent(bundleId)
                    .appendingPathComponent("default.store")
            }

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
                logger.critical("Failed to create fresh ModelContainer: \(error.localizedDescription)")
                logger.info("Falling back to in-memory container - history will not persist this session")
                return Self.createInMemoryContainer(schema: schema, logger: logger)
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(Self.sharedModelContainer)
    }

    // MARK: - Private Helper Methods

    /// Creates an in-memory ModelContainer as last resort fallback.
    /// This ensures the app can still function even if persistent storage fails.
    private static func createInMemoryContainer(schema: Schema, logger: Logger) -> ModelContainer {
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
