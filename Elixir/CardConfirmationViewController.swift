//
//  CardConfirmationViewController.swift
//  Elixir
//
//  Created by Jack Stark on 3/4/23.
//

import UIKit
import Kingfisher

class CardConfirmationViewController: UIViewController {
    var selectedCards = [Tarot]()
    var question = ""
    
    @IBOutlet var card1ImageView: UIImageView!
    @IBOutlet var card2ImageView: UIImageView!
    @IBOutlet var card3ImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImages()
        // Do any additional setup after loading the view.
    }
    
    func setupImages() {
        guard selectedCards.count == 3 else {
            return
        }
        let imageViews = [card1ImageView, card2ImageView, card3ImageView]
        
        for i in imageViews.indices {
            let url = URL(string: selectedCards[i].image_url)
            let iv = imageViews[i]
            
            let processor = ResizingImageProcessor(referenceSize: iv!.frame.size, mode: .aspectFill) |> CroppingImageProcessor(size: iv!.frame.size) |> RoundCornerImageProcessor(cornerRadius: 5)
            iv!.kf.setImage(with: url, placeholder: UIImage(named: "logo"), options: [.cacheSerializer(FormatIndicatedCacheSerializer.png), .transition(.fade(0.2)), .processor(processor), .scaleFactor(UIScreen.main.scale)])
        }
        
    }
    
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? CardResultViewController else { return }
        vc.card1 = selectedCards[0]
        vc.card2 = selectedCards[1]
        vc.card3 = selectedCards[2]
        vc.question = question
    }
    
    

}
