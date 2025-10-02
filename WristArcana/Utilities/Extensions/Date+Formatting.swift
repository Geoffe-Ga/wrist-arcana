//
//  Date+Formatting.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation

extension Date {
    /// Formats the date as a short, readable string (e.g., "Oct 1, 2025")
    var shortFormat: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Formats the date with time (e.g., "Oct 1, 2025 at 3:45 PM")
    var fullFormat: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}
