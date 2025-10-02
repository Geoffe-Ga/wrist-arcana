//
//  AppConstants.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation

enum AppConstants {
    static let maxHistoryItems = 500
    static let storageWarningThreshold = 0.80
    static let minimumDrawDuration: UInt64 = 500_000_000 // 0.5 seconds in nanoseconds
    static let defaultDeckId = "rider-waite-smith"
}

enum FeatureFlags {
    static let multiDeckEnabled = false // Set to true when IAP ready
}
