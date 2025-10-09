//
//  CTAButton.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import SwiftUI

struct CTAButton: View {
    // MARK: - Properties

    @Environment(\.autoSleepManager) private var autoSleepManager

    let title: String
    let isLoading: Bool
    let action: () -> Void

    // MARK: - Body

    var body: some View {
        Button(action: {
            self.autoSleepManager.registerInteraction()
            self.action()
        }) {
            ZStack {
                Circle()
                    .fill(Theme.Colors.primaryGradient)
                    .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 5)

                if self.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(self.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(self.isLoading)
        .accessibilityLabel(self.isLoading ? "Drawing card" : "Draw a tarot card")
        .accessibilityHint("Draws a random card from the deck")
    }
}

#Preview {
    VStack(spacing: 20) {
        CTAButton(title: "DRAW", isLoading: false) {
            print("Draw tapped")
        }
        .frame(width: 140, height: 140)

        CTAButton(title: "DRAW", isLoading: true) {
            print("Draw tapped")
        }
        .frame(width: 140, height: 140)
    }
}
