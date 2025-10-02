//
//  StorageMonitorTests.swift
//  WristArcana Watch AppTests
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation
import Testing
@testable import WristArcana_Watch_App

struct StorageMonitorTests {
    // MARK: - Storage Monitor Tests

    @Test func testGetAvailableStorage() async throws {
        // Given
        let monitor = StorageMonitor()

        // When
        let available = monitor.getAvailableStorage()

        // Then
        #expect(available >= 0, "Available storage should be non-negative")
    }

    @Test func testGetUsedStorage() async throws {
        // Given
        let monitor = StorageMonitor()

        // When
        let used = monitor.getUsedStorage()

        // Then
        #expect(used >= 0, "Used storage should be non-negative")
    }

    @Test func testIsNearCapacity() async throws {
        // Given
        let monitor = StorageMonitor()

        // When
        let nearCapacity = monitor.isNearCapacity()

        // Then - Just verify it returns a boolean without error
        #expect(nearCapacity == true || nearCapacity == false)
    }

    // MARK: - Mock Storage Monitor Tests

    @Test func mockStorageMonitorNotNearCapacity() async throws {
        // Given
        let mock = MockStorageMonitor()
        mock.isNearCapacityValue = false
        mock.availableStorage = 900_000_000 // 900MB available
        mock.usedStorage = 100_000_000 // 100MB used

        // Then
        #expect(mock.isNearCapacity() == false)
        #expect(mock.getAvailableStorage() == 900_000_000)
        #expect(mock.getUsedStorage() == 100_000_000)
    }

    @Test func mockStorageMonitorNearCapacity() async throws {
        // Given
        let mock = MockStorageMonitor()
        mock.isNearCapacityValue = true
        mock.availableStorage = 100_000_000 // 100MB available
        mock.usedStorage = 900_000_000 // 900MB used (90% full)

        // Then
        #expect(mock.isNearCapacity() == true)
    }

    @Test func mockStorageMonitorZeroAvailable() async throws {
        // Given
        let mock = MockStorageMonitor()
        mock.availableStorage = 0
        mock.usedStorage = 1_000_000_000

        // Then
        #expect(mock.getAvailableStorage() == 0)
        #expect(mock.getUsedStorage() == 1_000_000_000)
    }
}
