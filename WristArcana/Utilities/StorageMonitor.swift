//
//  StorageMonitor.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation

// MARK: - Protocol Definition

protocol StorageMonitorProtocol {
    func isNearCapacity() -> Bool
    func getAvailableStorage() -> Int64
    func getUsedStorage() -> Int64
}

// MARK: - Implementation

final class StorageMonitor: StorageMonitorProtocol {
    // MARK: - Private Properties

    private let warningThreshold: Double = 0.80 // 80% capacity

    // MARK: - Public Methods

    func isNearCapacity() -> Bool {
        let available = self.getAvailableStorage()
        let used = self.getUsedStorage()
        let total = available + used

        guard total > 0 else { return false }

        let usedPercentage = Double(used) / Double(total)
        return usedPercentage > self.warningThreshold
    }

    func getAvailableStorage() -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(
                forPath: NSHomeDirectory()
            )
            if let freeSpace = attributes[.systemFreeSize] as? Int64 {
                return freeSpace
            }
        } catch {
            print("⚠️ Failed to get storage info: \(error)")
        }
        return 0
    }

    func getUsedStorage() -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfFileSystem(
                forPath: NSHomeDirectory()
            )
            if let totalSpace = attributes[.systemSize] as? Int64,
               let freeSpace = attributes[.systemFreeSize] as? Int64
            {
                return totalSpace - freeSpace
            }
        } catch {
            print("⚠️ Failed to get storage info: \(error)")
        }
        return 0
    }
}
