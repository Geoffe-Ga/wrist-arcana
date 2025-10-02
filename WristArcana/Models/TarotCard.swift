//
//  TarotCard.swift
//  WristArcana
//
//  Created by Geoff Gallinger on 10/1/25.
//

import Foundation

struct TarotCard: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let imageName: String
    let arcana: ArcanaType
    let number: Int?
    let upright: String
    let reversed: String

    enum ArcanaType: String, Codable {
        case major
        case minor
    }

    init(
        id: UUID = UUID(),
        name: String,
        imageName: String,
        arcana: ArcanaType,
        number: Int? = nil,
        upright: String,
        reversed: String
    ) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.arcana = arcana
        self.number = number
        self.upright = upright
        self.reversed = reversed
    }
}
