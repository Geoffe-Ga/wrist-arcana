//
//  MockStorageMonitor.swift
//  WristArcana Watch AppTests
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation
@testable import WristArcana_Watch_App

final class MockStorageMonitor: StorageMonitorProtocol {
    // MARK: - Mock Properties

    var isNearCapacityValue = false
    var availableStorage: Int64 = 1_000_000_000 // 1GB
    var usedStorage: Int64 = 100_000_000 // 100MB

    // MARK: - Protocol Implementation

    func isNearCapacity() -> Bool {
        self.isNearCapacityValue
    }

    func getAvailableStorage() -> Int64 {
        self.availableStorage
    }

    func getUsedStorage() -> Int64 {
        self.usedStorage
    }
}
