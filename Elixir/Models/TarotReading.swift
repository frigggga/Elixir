//
//  TarotReading.swift
//  Elixir
//
//  Created by Jack Stark on 3/28/23.
//

import Foundation

struct TarotReading: Codable {
    var ID = UUID()
    var prompt: String
    var Tarots: [Tarot]
    var conciseReading: String
    var fullReading: String
    var date: Date
    var isFavorite: Bool
}
