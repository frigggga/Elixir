//
//  TarotReadingsCellTableViewCell.swift
//  Elixir
//
//  Created by Yinuo Zhou on 3/30/23.
//

import UIKit

class TarotReadingsCellTableViewCell: UITableViewCell {
    static let identifier = "readingCell"

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
   
    weak var delegate: TarotReadingsCellDelegate?

    var thisReading: TarotReading?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateUI(with tarotReading:TarotReading) {
        questionLabel.text = tarotReading.prompt
        
        thisReading = tarotReading
        // Create Date Formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        // Convert Date to String
        dateLabel.text = dateFormatter.string(from: tarotReading.date)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        favoriteButton.setTitle("", for: .normal)
        shareButton.setTitle("", for: .normal)
        shareButton.isHidden = true // Will change this when share feature is ready
    }

    @IBAction func favoriteButtonIsPressed(_ sender: UIButton) {
        delegate?.favoriteButtonTapped(for: self)
    }
}

protocol TarotReadingsCellDelegate: AnyObject {
    func favoriteButtonTapped(for cell: TarotReadingsCellTableViewCell)
}

