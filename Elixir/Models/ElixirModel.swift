//
//  ElixirModel.swift
//  Elixir
//
//  Created by Jack Stark on 2/18/23.
//

import Foundation

class ElixirModel {
    static let shared = ElixirModel()
    static let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentDirectory.appendingPathComponent("savedTarotReadings").appendingPathExtension("json")
    var herbs = [Herb]()
    var tarots = [Tarot]()
    var savedReadings = [TarotReading]() {
        didSet {
            saveReadings()
        }
    }
    
    func saveReadings() {
        let jsonEncoder = JSONEncoder()
        let codedReminders = try? jsonEncoder.encode(savedReadings)
        try? codedReminders?.write(to: ElixirModel.archiveURL, options: .noFileProtection)
    }
    
    func loadTarotReadings() -> [TarotReading]? {  //need load data?
        guard let codedReadings = try? Data(contentsOf: ElixirModel.archiveURL) else { return nil }
        let jsonDecoder = JSONDecoder()
        return try? jsonDecoder.decode([TarotReading].self, from: codedReadings)
    }
    
    func loadHerbs() -> [Herb] {
        if let url = Bundle.main.url(forResource: "herbs", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                //print(data)
                let decoder = JSONDecoder()
                let herbWrapper = try decoder.decode(HerbWrapper.self, from: data)
                return herbWrapper.herbs
            } catch {
                print("error:\(error)")
            }
        } else {
            print("File not found")
        }
        return []
    }
    
    func loadTarots() -> [Tarot] {
        if let url = Bundle.main.url(forResource: "v5_tarot_compressed", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                //print(data)
                let decoder = JSONDecoder()
                let herbWrapper = try decoder.decode(TarotWrapper.self, from: data)
                return herbWrapper.cards
            } catch {
                print("error:\(error)")
            }
        } else {
            print("File not found")
        }
        return []
    }
    
}
