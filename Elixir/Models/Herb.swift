//
//  Herb.swift
//  Elixir
//
//  Created by Jack Stark on 2/18/23.
//

import Foundation

// MARK: - HerbWrapper
struct HerbWrapper: Codable {
    let herbs: [Herb]
    enum CodingKeys: String, CodingKey {
        case herbs = "teas"
    }
    
}

// MARK: - Herb
struct Herb: Codable {
    let id, name: String
    let imageURL: String
    let description: String
    let benefits: [String]
    let amazonURL: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case imageURL = "image_url"
        case description, benefits
        case amazonURL = "amazon_url"
    }
}
