//
//  TeaCollectionViewCell.swift
//  Elixir
//
//  Created by Jack Stark on 2/19/23.
//

import UIKit
import Kingfisher

class TeaCollectionViewCell: UICollectionViewCell {
    static let identifier = "teaCell"
    static let placeholderImage = UIImage(named: "logo")
    @IBOutlet var teaImage: UIImageView!
    @IBOutlet var teaNameLabel: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(with herb: Herb) {
        teaNameLabel.text = herb.name
        let url = URL(string: herb.imageURL)
        teaImage.kf.indicatorType = .activity
        let processor = ResizingImageProcessor(referenceSize: teaImage.frame.size, mode: .aspectFill) |> CroppingImageProcessor(size: teaImage.frame.size) |> RoundCornerImageProcessor(cornerRadius: 20)
        teaImage.kf.setImage(with: url, placeholder: TeaCollectionViewCell.placeholderImage, options: [.cacheSerializer(FormatIndicatedCacheSerializer.png), .transition(.fade(0.2)), .processor(processor), .scaleFactor(UIScreen.main.scale)]) { result in
            switch result {
            case .success(let value):
                break
                // From where the image was retrieved:
                // - .none - Just downloaded.
                // - .memory - Got from memory cache.
                // - .disk - Got from disk cache.
                // print(value.cacheType)
            case .failure(let error):
                print(error) // The error happens
            }
        }
    }
    
}
