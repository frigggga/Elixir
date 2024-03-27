//
//  ManualSelectionViewController.swift
//  Elixir
//
//  Created by Jack Stark on 3/27/23.
//

import UIKit
import Kingfisher

extension UITextField {

    @IBInspectable
    var paddingLeft: CGFloat {
        get {
            return leftView?.frame.width ?? 0
        }
        set {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.height))
            leftView = paddingView
            leftViewMode = .always
        }
    }

}

class ManualCustomizedCell: UITableViewCell {
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var cardName: UILabel!
    var buttonTappedHandler: (() -> Void)?
    @IBAction func selectDidTapped(_ sender: UIButton) {
        buttonTappedHandler?()
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}
class ManualSelectionViewController: UIViewController, UIGestureRecognizerDelegate {
    func didSelectButton(in cell: ManualCustomizedCell) {
            if let indexPath = tableView.indexPath(for: cell) {
                tableView(tableView, didSelectRowAt: indexPath)
            }
        }
    var question: String!

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var imageView1: UIImageView!
    @IBOutlet var imageView2: UIImageView!
    @IBOutlet var imageView3: UIImageView!
    @IBOutlet var confirmButton: UIButton!
    @IBOutlet weak var BGView: UIView!
    var allTarotCards: [Tarot] = ElixirModel.shared.loadTarots()
    var tarotDataSource: [Tarot] = ElixirModel.shared.loadTarots()
    var index = 0
    let empty = Tarot(id: -1, name: "", image_url: "")
    var selectedTarots: [Tarot] = []
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        BGView.layer.cornerRadius = 15
        imageView1.kf.indicatorType = .activity
        imageView2.kf.indicatorType = .activity
        imageView3.kf.indicatorType = .activity
        imageView1.image = UIImage(named: "tarot")
        imageView2.image = UIImage(named: "tarot")
        imageView3.image = UIImage(named: "tarot")
        tableView.layer.cornerRadius = 15
        tableView.reloadData()
        tableView.allowsMultipleSelection = true
        selectedTarots = [empty, empty, empty]
        updateButtonState()
        confirmButton.tintColor = UIColor(rgb: 0xD9D9D9)
        confirmButton.layer.cornerRadius = 15
        confirmButton.layer.borderWidth = 1.0
        confirmButton.layer.borderColor = UIColor(rgb: 0xD9D9D9).cgColor
        confirmButton.clipsToBounds = true
        searchBar.searchTextField.backgroundColor = UIColor(rgb: 0xFDF8DB)
        searchBar.tintColor = UIColor(rgb: 0x414443)
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 10.0, vertical: 0.0)
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.font = UIFont(name: "Poppins-Regular", size: 14)
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        let backBTN = UIBarButtonItem(image: UIImage(named: "backButton.png"),
                                      style: .plain,
                                      target: navigationController,
                                      action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.leftBarButtonItem = backBTN
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }

    
    @IBAction func confirmationButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "fromManualToCardsResult", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "fromManualToCardsResult" else {
            return
        }
        let vc = segue.destination as! CardResultViewController
        vc.question = self.question
        vc.card1 = selectedTarots[0]
        vc.card2 = selectedTarots[1]
        vc.card3 = selectedTarots[2]
    }
    
    func loadAllTarotData() {
        tarotDataSource = allTarotCards
        tableView.reloadData()
    }
    
    func updateButtonState() {
        let count = selectedTarots.filter({ !$0.name.isEmpty }).count
        if count == 3 {
            confirmButton.isEnabled = true
            confirmButton.layer.borderColor = UIColor(rgb: 0x316BA0).cgColor
            confirmButton.tintColor = UIColor(rgb: 0x316BA0)
        } else {
            confirmButton.isEnabled = false
            confirmButton.tintColor = UIColor(rgb: 0xD9D9D9)
        }
    }
}

extension ManualSelectionViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tarotDataSource.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tarotCell", for: indexPath) as! ManualCustomizedCell
        let name: String = "\(indexPath.row + 1). " + tarotDataSource[indexPath.row].name
        cell.cardName.text = name
        if selectedTarots.contains(where: {$0.name == tarotDataSource[indexPath.row].name}) {
            cell.selectButton.setImage(UIImage(named: "selectedButton"), for: .normal)
            cell.selectButton.tintColor = UIColor(rgb: 0x316BA0)
        } else {
            cell.selectButton.setImage(UIImage(named: "notSelected"), for: .normal)
            cell.selectButton.tintColor = UIColor(rgb: 0x316BA0)
        }
        cell.selectButton.setTitle("", for: .normal)
        cell.selectButton.isEnabled = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard selectedTarots.filter({ $0.name.isEmpty }).count > 0, let index = selectedTarots.firstIndex(where: { $0.name.isEmpty}) else {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        let cell = tableView.cellForRow(at: indexPath)! as! ManualCustomizedCell
        cell.selectButton.setImage(UIImage(named: "selectedButton"), for: .normal)
        cell.selectButton.tintColor = UIColor(rgb: 0x316BA0)
        let tarot = tarotDataSource[indexPath.row]
        selectedTarots[index] = tarot
        let url = URL(string: tarot.image_url)
        
        switch index {
        case 0:
            imageView1.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        case 1:
            imageView2.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        case 2:
            imageView3.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        default:
            return
        }
        updateButtonState()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! ManualCustomizedCell
        cell.selectButton.setImage(UIImage(named: "notSelected"), for: .normal)
        cell.selectButton.tintColor = UIColor(rgb: 0x316BA0)
        let tarot = tarotDataSource[indexPath.row]
        let index = selectedTarots.firstIndex { $0.name == tarot.name}
        selectedTarots[index!] = empty
        switch index {
        case 0:
            imageView1.image = UIImage(named: "tarot")
        case 1:
            imageView2.image = UIImage(named: "tarot")
        case 2:
            imageView3.image = UIImage(named: "tarot")
        default:
            return
        }
        updateButtonState()
    }
    
}

extension ManualSelectionViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if ((searchBar.text?.isEmpty) != nil) {
            searchBar.resignFirstResponder()
            return
        }
        searchBar.text = ""
        tarotDataSource = allTarotCards
        tableView.reloadData()
        reselectCards()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if ((searchBar.text?.isEmpty) != nil) {
            return
        }
        guard let text = searchBar.text else {return}
        tarotDataSource = allTarotCards.filter({$0.name.contains(text)})
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchBar.resignFirstResponder()
            tarotDataSource = allTarotCards
            tableView.reloadData()
            reselectCards()
            return
        }
        
        tarotDataSource = allTarotCards.filter({$0.name.contains(searchText)})
        tableView.reloadData()
    }
    
    func reselectCards() {
        for card in selectedTarots {
            if let index = tarotDataSource.firstIndex(where: {$0.name == card.name}) {
                tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .top)
            }
        }
    }
}
