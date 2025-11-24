//
//  CardImageView.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import SwiftUI

struct CardImageView: View {
    // MARK: - Properties

    let imageName: String
    let cardName: String

    // MARK: - Body

    var body: some View {
        if let image = UIImage(named: imageName) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(8)
                .accessibilityLabel("Tarot card: \(self.cardName)")
        } else {
            // Fallback placeholder
            ZStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(11.0 / 19.0, contentMode: .fit)
                    .cornerRadius(8)

                VStack {
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)

                    Text(self.cardName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .accessibilityLabel("Placeholder for \(self.cardName)")
        }
    }
}

#Preview {
    VStack {
        CardImageView(imageName: "major_00", cardName: "The Fool")
            .frame(width: 150)

        CardImageView(imageName: "nonexistent", cardName: "Missing Card")
            .frame(width: 150)
    }
}
