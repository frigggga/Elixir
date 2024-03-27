//
//  SelectCardViewController.swift
//  Elixir
//
//  Created by Jack Stark on 3/4/23.
//

import UIKit
import Kingfisher

class RandomSelectionViewController: UIViewController, UIGestureRecognizerDelegate {
    var tarots: [Tarot] = ElixirModel.shared.tarots
    var selectedTarots = [Tarot]()  //should be 3 cards selected
    var question = ""
    
    @IBOutlet var confirmationButton: UIButton!
    @IBOutlet weak var deckCards: UIPickerView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var card1: UIImageView!
    @IBOutlet weak var card2: UIImageView!
    @IBOutlet weak var card3: UIImageView!
    var card1Default: Bool = true
    var card2Default: Bool = true
    var card3Default: Bool = true
    var cardsPicker: CardsPicker!
    var offset: Double = 0.0
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: animated)
        tarots.shuffle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmationButton.tintColor = UIColor(rgb: 0xD9D9D9)
        updateButtonState()
        confirmationButton.layer.cornerRadius = 15
        confirmationButton.layer.borderWidth = 1.0
        confirmationButton.layer.borderColor = UIColor(rgb: 0xD9D9D9).cgColor
        confirmationButton.clipsToBounds = true
        selectButton.setImage(UIImage(named: "select.png"), for: .selected)
        selectButton.addTarget(self, action: #selector(buttonPressed), for: .touchDown)
        selectButton.addTarget(self, action: #selector(buttonReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        let backBTN = UIBarButtonItem(image: UIImage(named: "backButton.png"),
                                      style: .plain,
                                      target: navigationController,
                                      action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.leftBarButtonItem = backBTN
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        ElixirModel.shared.tarots = ElixirModel.shared.loadTarots()
        tarots = ElixirModel.shared.tarots
        selectButton.titleLabel?.adjustsFontSizeToFitWidth = true
        selectButton.titleLabel?.minimumScaleFactor = 0.5
        cardsPicker = CardsPicker()
        let y = deckCards.frame.origin.y
        deckCards.transform = CGAffineTransform(rotationAngle: -90 * (.pi / 180))
        //adjust the cell height according to screen size
        let cellDefaultWidth: Double = 138.0
        let screenDefaultWidth: Double = 393.0
        let factor: Double = cellDefaultWidth / screenDefaultWidth
        let firstScene = UIApplication.shared.connectedScenes.first // may be nil
        var screenWidth: CGFloat = 0.0
        if let w = firstScene as? UIWindowScene {
            screenWidth = w.screen.bounds.width
        }
        offset = factor * screenWidth
        deckCards.frame = CGRect(x: -offset, y: y, width: view.frame.width + offset * 2, height: offset)
        deckCards.delegate = cardsPicker
        deckCards.dataSource = cardsPicker
        deckCards.selectRow(10, inComponent: 0, animated: true)
        deckCards.translatesAutoresizingMaskIntoConstraints = false
        deckCards.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deckCards.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        deckCards.widthAnchor.constraint(equalToConstant: offset).isActive = true
        deckCards.heightAnchor.constraint(equalToConstant: view.frame.width + offset * 2).isActive = true
        let verticalOffset: CGFloat = -85.0 // Adjust this value to move the picker view up or down
        deckCards.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: verticalOffset).isActive = true
        deckCards.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        shuffleAnimation()
    }
    
    func shuffleAnimation() {
        // Scale down the height of the UIPickerView
        UIView.animate(withDuration: 0.3, animations: {
            self.deckCards.transform = self.deckCards.transform.scaledBy(x: 1, y: 0.2)
        }) { _ in
            // Scale back the height of the UIPickerView to its original size
            UIView.animate(withDuration: 0.3) {
                self.deckCards.transform = CGAffineTransform(rotationAngle: -90 * (.pi / 180))
            }
        }
    }
    
    @objc func buttonPressed() {
           selectButton.setImage(UIImage(named: "select.png"), for: .normal)
    }
       
   @objc func buttonReleased() {
       selectButton.setImage(UIImage(named: "selectUpdated.png"), for: .normal)
   }
    
    @IBAction func selectPressed(_ sender: UIButton) {
        if card1Default {
            setupImages(iv: card1)
            selectedTarots.append(tarots[deckCards.selectedRow(inComponent: 0)])
            card1Default = false
        } else if card2Default {
            setupImages(iv: card2)
            selectedTarots.append(tarots[deckCards.selectedRow(inComponent: 0)])
            card2Default = false
        } else if card3Default{
            setupImages(iv: card3)
            selectedTarots.append(tarots[deckCards.selectedRow(inComponent: 0)])
            card3Default = false
            selectButton.isEnabled = false
        }
        tarots.remove(at: deckCards.selectedRow(inComponent: 0))
        cardsPicker.tarots.remove(at: deckCards.selectedRow(inComponent: 0))
        deckCards.reloadAllComponents()
        updateButtonState()
    }
    
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "fromRandomToCardsResult", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "fromRandomToCardsResult" else {
            return
        }
        let vc = segue.destination as! CardResultViewController
        vc.card1 = selectedTarots[0]
        vc.card2 = selectedTarots[1]
        vc.card3 = selectedTarots[2]
        vc.question = question
        
    }
    
    func setupImages(iv: UIImageView) {
            let url = URL(string: tarots[deckCards.selectedRow(inComponent: 0)].image_url)
            let processor = ResizingImageProcessor(referenceSize: iv.frame.size, mode: .aspectFit) |> CroppingImageProcessor(size: iv.frame.size) |> RoundCornerImageProcessor(cornerRadius: 5)
            iv.kf.setImage(with: url, placeholder: UIImage(named: "tarot"), options: [.cacheSerializer(FormatIndicatedCacheSerializer.png), .transition(.fade(0.2)), .processor(processor), .scaleFactor(UIScreen.main.scale)])
    }
    
    func updateButtonState() {
        let count = selectedTarots.count
//        confirmationButton.isEnabled = count == 3 ? true : false
        if count == 3 {
            confirmationButton.isEnabled = true
            confirmationButton.layer.borderColor = UIColor(rgb: 0x316BA0).cgColor
            confirmationButton.tintColor = UIColor(rgb: 0x316BA0)
        } else {
            confirmationButton.isEnabled = false
            confirmationButton.tintColor = UIColor(rgb: 0xD9D9D9)
        }
    }
}
