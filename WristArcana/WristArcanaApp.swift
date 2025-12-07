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
        do {
            return try Self.makeModelContainer(logger: logger)
        } catch {
            fatalError("Critical: Failed to create ModelContainer: \(error)")
        }
    }()

    // MARK: - Container Factory (Testable)

    /// Creates a ModelContainer with graceful error handling and migration support.
    /// This method is extracted to be testable, unlike the static property.
    ///
    /// Recovery strategy:
    /// 1. Try normal initialization
    /// 2. On failure, delete corrupted database and retry
    /// 3. If still failing, use in-memory container (app works without persistence)
    ///
    /// - Parameters:
    ///   - schema: SwiftData schema (default: CardPull)
    ///   - logger: Logger for debugging (default: creates new logger)
    ///   - fileManager: FileManager for file operations (injectable for testing)
    /// - Returns: ModelContainer (persistent or in-memory)
    /// - Note: See Issue #33 - this prevents "app refuses to open after update" crashes
    static func makeModelContainer(
        schema: Schema = Schema([CardPull.self]),
        logger: Logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "WristArcana", category: "app"),
        fileManager: FileManager = .default
    ) throws -> ModelContainer {
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        // STEP 1: Attempt normal initialization
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // STEP 2: Migration failure - attempt database reset
            logger.error("ModelContainer initialization failed: \(error.localizedDescription)")
            logger.warning("Attempting database reset to recover...")

            // Delete corrupted/incompatible database directory
            // For v1.0, losing history is acceptable to keep app functional.
            // Future versions should implement proper VersionedSchema migrations.
            // Note: configuration.url is always set by ModelConfiguration
            Self.deleteDatabaseIfExists(at: configuration.url, fileManager: fileManager, logger: logger)

            // STEP 3: Attempt to create fresh container after cleanup
            do {
                let freshContainer = try ModelContainer(for: schema, configurations: [configuration])
                logger.info("Successfully created fresh ModelContainer after database reset")
                return freshContainer
            } catch {
                // STEP 4: Last resort - in-memory container
                logger.critical("Failed to create fresh ModelContainer: \(error.localizedDescription)")
                logger.info("Falling back to in-memory container - history will not persist this session")
                return Self.createInMemoryContainer(schema: schema, logger: logger)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(Self.sharedModelContainer)
    }

    // MARK: - Helper Methods (Testable)

    /// Deletes the database directory if it exists.
    /// SwiftData stores databases as directories with multiple SQLite files (.store, .store-shm, .store-wal).
    ///
    /// - Parameters:
    ///   - url: Database directory URL
    ///   - fileManager: FileManager instance (injectable for testing)
    ///   - logger: Logger for debugging
    static func deleteDatabaseIfExists(at url: URL, fileManager: FileManager, logger: Logger) {
        var isDirectory: ObjCBool = false
        let exists = fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory)

        guard exists else {
            logger.info("Database not found at \(url.path) - nothing to delete")
            return
        }

        guard isDirectory.boolValue else {
            logger.warning("Database path exists but is not a directory: \(url.path)")
            return
        }

        do {
            let start = Date()
            try fileManager.removeItem(at: url)
            let duration = Date().timeIntervalSince(start)
            logger.info("Deleted database directory at \(url.path) (took \(String(format: "%.3f", duration))s)")
        } catch let error as NSError {
            // File not found is expected if database was already deleted
            if error.domain == NSCocoaErrorDomain, error.code == NSFileNoSuchFileError {
                logger.info("Database file not found during deletion (already deleted or never created)")
            } else {
                logger.error("Failed to delete database: \(error.localizedDescription)")
                logger.warning("Fresh container initialization may still fail")
            }
        }
    }

    /// Creates an in-memory ModelContainer as last resort fallback.
    /// This ensures the app can still function even if persistent storage fails.
    ///
    /// - Parameters:
    ///   - schema: SwiftData schema
    ///   - logger: Logger for debugging
    /// - Returns: In-memory ModelContainer
    static func createInMemoryContainer(schema: Schema, logger: Logger) -> ModelContainer {
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
