//
//  Theme.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import SwiftUI

enum Theme {
    enum Colors {
        static let primaryGradient = LinearGradient(
            colors: [.purple, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        static let cardBackground = Color.black
    }

    enum Fonts {
        static let title = Font.system(size: 32, weight: .bold, design: .serif)
        static let cardName = Font.system(size: 20, weight: .semibold, design: .serif)
        static let body = Font.system(size: 14, weight: .regular)
    }

    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
}
