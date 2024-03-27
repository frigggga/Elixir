//
//  HomeViewController.swift
//  Elixir
//
//  Created by Jack Stark on 2/12/23.
//

import UIKit
import Kingfisher

var herbs: [Herb] = ElixirModel.shared.loadHerbs()
class CustomizedCell: UITableViewCell {
    @IBOutlet weak var herbPrice: UILabel!
    @IBOutlet weak var herbName: UILabel!
    @IBOutlet weak var teaImage: UIImageView!
    @IBOutlet weak var addButton: UIImageView!
    
    func updateUI(with herb: Herb) {
        herbName.text = herb.name
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

class HomeViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var greeting: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var settingButton: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
        //Get the current time to say the greeting words
        let today = Date()
        let hours = (Calendar.current.component(.hour, from: today))
        if hours >= 5 && hours < 12 {
            //morning
            greeting.text = "Good morning,"
        } else if hours >= 12 && hours < 17 {
            //afternoon
            greeting.text = "Good afternoon,"
        } else {
            //night
            greeting.text = "Good night,"
        }
        
        //adjust the cell height according to screen size
        let cellDefaultHeight: Double = 100.0
        let screenDefaultHeight: Double = 1179.0
        let factor: Double = cellDefaultHeight / screenDefaultHeight
        let firstScene = UIApplication.shared.connectedScenes.first // may be nil
        var screenHeight: CGFloat = 0.0
        if let w = firstScene as? UIWindowScene {
            screenHeight = w.screen.bounds.height
        }
        tableView.rowHeight = factor * screenHeight
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func makeImageRounded(imageView: UIImageView) {
        imageView.layer.cornerRadius = 8.0
        imageView.clipsToBounds = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recommendationCell")! as! CustomizedCell
        //fill the add button
        cell.addButton.image = UIImage(named: "+ button")
        //update tea's image, name, and price
        let data = herbs[indexPath.row]
        cell.updateUI(with: data)
        return cell
    }
}
