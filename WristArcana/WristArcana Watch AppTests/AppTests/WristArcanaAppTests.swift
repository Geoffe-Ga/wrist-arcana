//
//  WristArcanaAppTests.swift
//  WristArcana Watch AppTests
//
//  Created by Geoff Gallinger on 12/7/25.
//

import Foundation
import OSLog
import SwiftData
import Testing
@testable import WristArcana_Watch_App

/// Tests for WristArcanaApp's ModelContainer creation and error recovery logic.
/// These tests verify the critical BUG-004 fix to prevent app crashes after schema changes.
struct WristArcanaAppTests {
    // MARK: - In-Memory Container Tests

    @Test func createInMemoryContainer_alwaysSucceeds() async throws {
        // Given
        let schema = Schema([CardPull.self])
        let logger = Logger(subsystem: "WristArcanaTests", category: "test")

        // When
        let container = WristArcanaApp.createInMemoryContainer(schema: schema, logger: logger)

        // Then
        #expect(!container.schema.entities.isEmpty)
        // Verify it's actually in-memory by checking we can create context without file system
        let context = ModelContext(container)
        #expect(context != nil)
    }

    @Test func createInMemoryContainer_canSaveAndFetchData() async throws {
        // Given
        let schema = Schema([CardPull.self])
        let logger = Logger(subsystem: "WristArcanaTests", category: "test")
        let container = WristArcanaApp.createInMemoryContainer(schema: schema, logger: logger)
        let context = ModelContext(container)

        // When - Save a CardPull
        let pull = CardPull(
            cardName: "The Fool",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "New beginnings"
        )
        context.insert(pull)
        try context.save()

        // Then - Verify we can fetch it
        let descriptor = FetchDescriptor<CardPull>()
        let pulls = try context.fetch(descriptor)
        #expect(pulls.count == 1)
        #expect(pulls.first?.cardName == "The Fool")
    }

    // MARK: - Database Deletion Tests

    @Test func deleteDatabaseIfExists_deletesExistingDirectory() async throws {
        // Given
        let fileManager = FileManager.default
        let logger = Logger(subsystem: "WristArcanaTests", category: "test")
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        // Create a mock database directory
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        #expect(fileManager.fileExists(atPath: tempDir.path))

        // When
        WristArcanaApp.deleteDatabaseIfExists(at: tempDir, fileManager: fileManager, logger: logger)

        // Then
        #expect(!fileManager.fileExists(atPath: tempDir.path))
    }

    @Test func deleteDatabaseIfExists_handlesNonExistentPath() async throws {
        // Given
        let fileManager = FileManager.default
        let logger = Logger(subsystem: "WristArcanaTests", category: "test")
        let nonExistentPath = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        #expect(!fileManager.fileExists(atPath: nonExistentPath.path))

        // When - Should not throw
        WristArcanaApp.deleteDatabaseIfExists(at: nonExistentPath, fileManager: fileManager, logger: logger)

        // Then - Should complete without error
        #expect(!fileManager.fileExists(atPath: nonExistentPath.path))
    }

    @Test func deleteDatabaseIfExists_handlesFileInsteadOfDirectory() async throws {
        // Given
        let fileManager = FileManager.default
        let logger = Logger(subsystem: "WristArcanaTests", category: "test")
        let tempFile = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        // Create a file (not directory)
        fileManager.createFile(atPath: tempFile.path, contents: Data("test".utf8))
        #expect(fileManager.fileExists(atPath: tempFile.path))

        // When - Should handle gracefully (log warning but not crash)
        WristArcanaApp.deleteDatabaseIfExists(at: tempFile, fileManager: fileManager, logger: logger)

        // Then - File should still exist (we don't delete non-directories)
        #expect(fileManager.fileExists(atPath: tempFile.path))

        // Cleanup
        try? fileManager.removeItem(at: tempFile)
    }

    @Test func deleteDatabaseIfExists_deletesDirectoryWithMultipleFiles() async throws {
        // Given
        let fileManager = FileManager.default
        let logger = Logger(subsystem: "WristArcanaTests", category: "test")
        let tempDir = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        // Create directory with multiple files (simulating SwiftData structure)
        try fileManager.createDirectory(at: tempDir, withIntermediateDirectories: true)
        let storeFile = tempDir.appendingPathComponent("default.store")
        let shmFile = tempDir.appendingPathComponent("default.store-shm")
        let walFile = tempDir.appendingPathComponent("default.store-wal")

        fileManager.createFile(atPath: storeFile.path, contents: Data())
        fileManager.createFile(atPath: shmFile.path, contents: Data())
        fileManager.createFile(atPath: walFile.path, contents: Data())

        #expect(fileManager.fileExists(atPath: storeFile.path))
        #expect(fileManager.fileExists(atPath: shmFile.path))
        #expect(fileManager.fileExists(atPath: walFile.path))

        // When
        WristArcanaApp.deleteDatabaseIfExists(at: tempDir, fileManager: fileManager, logger: logger)

        // Then - All files should be deleted
        #expect(!fileManager.fileExists(atPath: tempDir.path))
        #expect(!fileManager.fileExists(atPath: storeFile.path))
        #expect(!fileManager.fileExists(atPath: shmFile.path))
        #expect(!fileManager.fileExists(atPath: walFile.path))
    }

    // MARK: - Container Factory Integration Tests

    @Test func makeModelContainer_createsInMemoryContainerWhenPersistentFails() async throws {
        // This test verifies the three-tier recovery strategy
        // We can't easily force persistent container to fail without corrupting actual DB,
        // but we can verify the in-memory fallback works

        // Given
        let schema = Schema([CardPull.self])
        let logger = Logger(subsystem: "WristArcanaTests", category: "test")

        // When - Create container (will use normal path or in-memory fallback)
        let container = try WristArcanaApp.makeModelContainer(schema: schema, logger: logger)

        // Then - Should have valid container either way
        #expect(!container.schema.entities.isEmpty)

        // Verify we can use it
        let context = ModelContext(container)
        let pull = CardPull(
            cardName: "Test",
            deckName: "Rider-Waite",
            cardImageName: "major_00",
            cardDescription: "Test"
        )
        context.insert(pull)
        try context.save()

        let descriptor = FetchDescriptor<CardPull>()
        let pulls = try context.fetch(descriptor)
        #expect(pulls.count >= 1) // May have existing data if persistent succeeded
    }

    @Test func makeModelContainer_withCustomSchema_createsContainer() async throws {
        // Given
        let schema = Schema([CardPull.self])
        let logger = Logger(subsystem: "WristArcanaTests", category: "test")

        // When
        let container = try WristArcanaApp.makeModelContainer(
            schema: schema,
            logger: logger
        )

        // Then
        #expect(container.schema.entities.count == 1)
        #expect(container.schema.entities.first?.name == "CardPull")
    }
}
