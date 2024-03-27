//
//  TarotSelectionViewController.swift
//  Elixir
//
//  Created by Jack Stark on 3/27/23.
//

import UIKit

class TarotSelectionViewController: UIViewController, UIGestureRecognizerDelegate {
    var prompt: String!
    
    @IBOutlet var randomSelectionButton: UIButton!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet var manualselectionButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        promptLabel.text = prompt
        let backBTN = UIBarButtonItem(image: UIImage(named: "backButton.png"),
                                      style: .plain,
                                      target: navigationController,
                                      action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.leftBarButtonItem = backBTN
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        randomSelectionButton.tintColor = UIColor(rgb: 0x316BA0)
        manualselectionButton.tintColor = UIColor(rgb: 0x316BA0).withAlphaComponent(0.5)
        randomSelectionButton.layer.cornerRadius = 15
        randomSelectionButton.layer.borderWidth = 1.0
        randomSelectionButton.layer.borderColor = UIColor(rgb: 0x316BA0).cgColor
        randomSelectionButton.clipsToBounds = true
        manualselectionButton.layer.cornerRadius = 15
        manualselectionButton.layer.borderWidth = 1.0
        manualselectionButton.layer.borderColor = UIColor(rgb: 0x316BA0).withAlphaComponent(0.5).cgColor
        manualselectionButton.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction func randomSelectionButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toRandomSelectionSegue", sender: self)
    }
    
    @IBAction func manualSelectionButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toManualSelectionSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "toRandomSelectionSegue":
            let vc = segue.destination as! RandomSelectionViewController
            vc.question = prompt
        case "toManualSelectionSegue":
            let vc = segue.destination as! ManualSelectionViewController
            vc.question = prompt
        default:
            return
        }
    }

}
