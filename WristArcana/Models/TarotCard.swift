//
//  TarotCard.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation

struct TarotCard: Codable, Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let imageName: String
    let suit: Suit
    let number: Int
    let upright: String
    let reversed: String
    let keywords: [String]

    init(
        id: UUID = UUID(),
        name: String,
        imageName: String,
        suit: Suit,
        number: Int,
        upright: String,
        reversed: String,
        keywords: [String] = []
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.suit = suit
        self.number = number
        self.upright = upright
        self.reversed = reversed
        self.keywords = keywords
    }

    enum Suit: String, Codable, CaseIterable {
        case majorArcana = "Major Arcana"
        case swords = "Swords"
        case wands = "Wands"
        case pentacles = "Pentacles"
        case cups = "Cups"

        var icon: String {
            switch self {
            case .majorArcana: return "⭐"
            case .swords: return "⚔️"
            case .wands: return "🪄"
            case .pentacles: return "🪙"
            case .cups: return "🏆"
            }
        }

        var cardCount: Int {
            switch self {
            case .majorArcana: return 22
            case .swords, .wands, .pentacles, .cups: return 14
            }
        }

        var sortOrder: Int {
            switch self {
            case .majorArcana: return 0
            case .swords: return 1
            case .wands: return 2
            case .pentacles: return 3
            case .cups: return 4
            }
        }
    }

    // MARK: - Computed Properties

    var displayNumber: String {
        switch suit {
        case .majorArcana:
            return romanNumeral(from: number)
        case .swords, .wands, .pentacles, .cups:
            return cardNumberName(number)
        }
    }

    var fullDisplayName: String {
        switch suit {
        case .majorArcana:
            return "\(displayNumber) - \(name)"
        case .swords, .wands, .pentacles, .cups:
            return name
        }
    }

    // MARK: - Helper Methods

    private func romanNumeral(from number: Int) -> String {
        let romanNumerals = [
            "0", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X",
            "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX", "XXI"
        ]

        guard number >= 0, number < romanNumerals.count else {
            return "\(number)"
        }

        return romanNumerals[number]
    }

    private func cardNumberName(_ number: Int) -> String {
        switch number {
        case 1: return "Ace"
        case 2...10: return "\(number)"
        case 11: return "Page"
        case 12: return "Knight"
        case 13: return "Queen"
        case 14: return "King"
        default: return "\(number)"
        }
    }
}
