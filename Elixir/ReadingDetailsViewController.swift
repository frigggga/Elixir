//
//  ReadingDetailsViewController.swift
//  Elixir
//
//  Created by Yinuo Zhou on 3/31/23.
//

import UIKit

protocol ReadingDetailDelegate: AnyObject {
    func readingUnfavorited()
}

class ReadingDetailsViewController: UIViewController {
    var tarotReading: TarotReading?
    weak var delegate: ReadingDetailDelegate?

    @IBOutlet var resultTextView: UITextView!
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet weak var Navbar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let tarotReading = tarotReading else { return }
        
        
        Navbar.title = tarotReading.prompt
        favoriteButton.setImage(UIImage(named: "Love"), for: .selected)
        favoriteButton.setImage(UIImage(named: "NotLove"), for: .normal)
        favoriteButton.isSelected = tarotReading.isFavorite
        favoriteButton.setTitle("", for: .normal)
        
        let cardNames = tarotReading.Tarots.map { $0.name }.joined(separator: ", ")
        
        // Create attributed strings for summary and detailed readings
        let summaryAttributedString = NSMutableAttributedString(string: tarotReading.conciseReading, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: resultTextView.font?.pointSize ?? 14)])
        let detailedReadingAttributedString = NSMutableAttributedString(string: tarotReading.fullReading, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: resultTextView.font?.pointSize ?? 14)])

        // Combine attributed strings and add an empty line between them
        let combinedAttributedString = NSMutableAttributedString()
        combinedAttributedString.append(NSAttributedString(string: "Your cards: \(cardNames)\n\nYour question: \(tarotReading.prompt)\n\n"))
        combinedAttributedString.append(summaryAttributedString)
        combinedAttributedString.append(NSAttributedString(string: "\n\n"))
        combinedAttributedString.append(detailedReadingAttributedString)
        
        // Set the combined attributed text to the UITextView
        resultTextView.attributedText = combinedAttributedString
    }

    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        favoriteButton.isSelected.toggle()
        guard var tarotReading = tarotReading else { return }
        if favoriteButton.isSelected {
            tarotReading.isFavorite = true
            ElixirModel.shared.savedReadings.append(tarotReading)
        } else {
            tarotReading.isFavorite = false
            ElixirModel.shared.savedReadings.removeAll { $0.ID == tarotReading.ID }

            // Call the delegate method
            delegate?.readingUnfavorited()
        }
    }
}

