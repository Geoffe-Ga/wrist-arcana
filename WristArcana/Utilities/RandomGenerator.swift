//
//  RandomGenerator.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation

// MARK: - Protocol Definition

protocol RandomGeneratorProtocol {
    func randomCard(from cards: [TarotCard]) -> TarotCard?
}

// MARK: - Implementation

final class CryptoRandomGenerator: RandomGeneratorProtocol {
    func randomCard(from cards: [TarotCard]) -> TarotCard? {
        guard !cards.isEmpty else { return nil }
        var generator = SystemRandomNumberGenerator()
        return cards.randomElement(using: &generator)
    }
}
