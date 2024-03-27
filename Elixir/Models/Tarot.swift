//
//  Tarot.swift
//  Elixir
//
//  Created by Jack Stark on 3/4/23.
//

import Foundation

//   let tarot = try? JSONDecoder().decode(Tarot.self, from: jsonData)


// MARK: - Tarot
struct TarotWrapper: Codable {
    let cards: [Tarot]
}

// MARK: - Card
struct Tarot: Codable {
    let id: Int
    let name: String
    let image_url: String

    enum CodingKeys: String, CodingKey {
        case id, name, image_url
    }
}
