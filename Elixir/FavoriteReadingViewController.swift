//
//  FavoriteReadingViewController.swift
//  Elixir
//
//  Created by Yinuo Zhou on 3/30/23.
//

import UIKit

class CustomFooterView: UIView {

    // Initialize the custom view
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    // Required initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    // Set up the custom view components
    private func setupView() {
        // Create a UIImageView with the desired image
        let imageView = UIImageView(image: UIImage(named: "endLine"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        
        // Set constraints for the image view
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.8)
        ])
    }
}

class FavoriteReadingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ElixirModel.shared.savedReadings = ElixirModel.shared.loadTarotReadings()!
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
        // Create an instance of the custom footer view
        let customFooterView = CustomFooterView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80))
        // Set the custom footer view as the tableFooterView
        tableView.tableFooterView = customFooterView
        tableView.rowHeight = 120
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ElixirModel.shared.savedReadings = ElixirModel.shared.loadTarotReadings()!
        super.viewWillAppear(animated)
        //refresh table view
        self.tableView.reloadData()
    }
    
    /*
    // MARK: - Navigation
    */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showReadingDetails",
           let indexPath = tableView.indexPathForSelectedRow,
           let readingDetailsViewController = segue.destination as? ReadingDetailsViewController {
            let selectedTarotReading = ElixirModel.shared.savedReadings[indexPath.row]
            readingDetailsViewController.tarotReading = selectedTarotReading
            
            // Set the delegate
            readingDetailsViewController.delegate = self
        }
    }
}

extension FavoriteReadingViewController: UITableViewDelegate, UITableViewDataSource, ReadingDetailDelegate, TarotReadingsCellDelegate{
    
    func readingUnfavorited() {
        ElixirModel.shared.savedReadings = ElixirModel.shared.loadTarotReadings()!
        self.tableView.reloadData()
    }
    
    func favoriteButtonTapped(for cell: TarotReadingsCellTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              var tarotReading = cell.thisReading else { return }
        
        if !tarotReading.isFavorite {
            tarotReading.isFavorite = true
            cell.favoriteButton.setImage(UIImage(named: "Love"), for: .normal)
            cell.favoriteButton.setTitleColor(UIColor.orange, for: .normal)
            ElixirModel.shared.savedReadings.append(tarotReading)
        } else {
            tarotReading.isFavorite = false
            cell.favoriteButton.setImage(UIImage(systemName: "NotLove"), for: .normal)
            cell.favoriteButton.setTitleColor(UIColor.orange, for: .normal)
            ElixirModel.shared.savedReadings.removeAll { $0.ID == tarotReading.ID }
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ElixirModel.shared.savedReadings.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "readingCell", for: indexPath) as! TarotReadingsCellTableViewCell
        let fav = ElixirModel.shared.savedReadings[indexPath.row]
        
        cell.updateUI(with: fav)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

