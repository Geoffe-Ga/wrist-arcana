//
//  CardPull.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation
import SwiftData

@Model
final class CardPull {
    @Attribute(.unique) var id: UUID
    var date: Date
    var cardName: String
    var deckName: String
    var cardImageName: String

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        cardName: String,
        deckName: String,
        cardImageName: String
    ) {
        self.id = id
        self.date = date
        self.cardName = cardName
        self.deckName = deckName
        self.cardImageName = cardImageName
    }
}
