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
            case .majorArcana: "⭐"
            case .swords: "⚔️"
            case .wands: "🪄"
            case .pentacles: "🪙"
            case .cups: "🏆"
            }
        }

        var cardCount: Int {
            switch self {
            case .majorArcana: 22
            case .swords, .wands, .pentacles, .cups: 14
            }
        }

        var sortOrder: Int {
            switch self {
            case .majorArcana: 0
            case .swords: 1
            case .wands: 2
            case .pentacles: 3
            case .cups: 4
            }
        }
    }

    // MARK: - Static Fallback

    /// Emergency fallback card array used when DecksData.json fails to load.
    /// Contains The Fool card to ensure CardRepository never has empty cards.
    /// Prevents CardReferenceView from displaying empty lists.
    /// - Note: See Issue #35 (BUG-006) - prevents silent initialization failure
    static var emergencyFallback: [TarotCard] {
        [
            TarotCard(
                name: "The Fool",
                imageName: "major_00",
                suit: .majorArcana,
                number: 0,
                upright: "New beginnings, optimism, trust in life. The universe is ready to support your journey.",
                reversed: "Recklessness, taken advantage of, inconsideration. Pause before leaping.",
                keywords: ["beginnings", "innocence", "spontaneity", "free spirit"]
            )
        ]
    }

    // MARK: - Computed Properties

    var displayNumber: String {
        switch self.suit {
        case .majorArcana:
            self.romanNumeral(from: self.number)
        case .swords, .wands, .pentacles, .cups:
            self.cardNumberName(self.number)
        }
    }

    var fullDisplayName: String {
        switch self.suit {
        case .majorArcana:
            "\(self.displayNumber) - \(self.name)"
        case .swords, .wands, .pentacles, .cups:
            self.name
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
        case 1: "Ace"
        case 2 ... 10: "\(number)"
        case 11: "Page"
        case 12: "Knight"
        case 13: "Queen"
        case 14: "King"
        default: "\(number)"
        }
    }
}
