//
//  TarotCategoryViewController.swift
//  Elixir
//
//  Created by Youzhi Liu on 2023/3/6.
//

import UIKit

private var PaddingKey: UInt8 = 0

extension UITextField {

    var padding: UIEdgeInsets {
        get {
            return objc_getAssociatedObject(self, &PaddingKey) as? UIEdgeInsets ?? UIEdgeInsets.zero
        }
        set {
            objc_setAssociatedObject(self, &PaddingKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            updatePadding()
        }
    }

    private func updatePadding() {
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: padding.left, height: bounds.height))
        self.leftView = leftView
        self.leftViewMode = .always

        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: padding.right, height: bounds.height))
        self.rightView = rightView
        self.rightViewMode = .always
    }
}

class TarotPromptViewController: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var askYourOutlet: UILabel!
    @IBOutlet weak var suggestionsButton: UIButton!
    @IBOutlet weak var questionOutlet: UILabel!
    @IBOutlet weak var tipsOrSuggestionsImage: UIImageView!
    @IBOutlet weak var tipsButton: UIButton!
    @IBOutlet var questionTextField: UITextField!
    @IBOutlet weak var sendButtonOutlet: UIButton!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var suggestionLeadingConstraint: NSLayoutConstraint!
    
    func isDeviceMaxSeries() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .phone {
            let screenSize = UIScreen.main.bounds.size

            // List of iPhone Max series and other specified screen sizes
            let targetSizes: [CGSize] = [
                CGSize(width: 414, height: 896), // iPhone XS Max, iPhone 11 Pro Max, iPhone 11, iPhone 12, iPhone 13
                CGSize(width: 428, height: 926), // iPhone 12 Pro Max, iPhone 13 Pro Max
                // iPhone 14 pro max
                CGSize(width: 430, height: 932)
            ]

            return targetSizes.contains(screenSize)
        }
        return false
    }
    
    func leadingConstraintUpdateValue() -> CGFloat {
        if UIScreen.main.bounds.size == CGSize(width: 414, height: 896) {
            return -5
        }
        return isDeviceMaxSeries() ? -8 : 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        print("Screen width: \(screenWidth) points")
        print("Screen height: \(screenHeight) points")
        // Do any additional setup after loading the view.
        questionTextField.delegate = self
        sendButtonOutlet.isEnabled = false
//        askYourOutlet.adjustsFontSizeToFitWidth = true
//        questionOutlet.adjustsFontSizeToFitWidth = true
        suggestionsButton.isSelected = true
        tipsButton.isSelected = false
        tipsButton.setTitleColor(UIColor(rgb: 0x316BA0), for: .selected)
        tipsButton.setTitleColor(.black, for: .normal)
        suggestionsButton.setTitleColor(UIColor(rgb: 0x316BA0), for: .selected)
        suggestionsButton.setTitleColor(.black, for: .normal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        questionTextField.layer.cornerRadius = 15
        questionTextField.layer.borderWidth = 1.0
        questionTextField.layer.borderColor = UIColor(rgb: 0xFDF8DB).cgColor
        questionTextField.clipsToBounds = true
        questionTextField.padding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 23)
        viewBG.layer.cornerRadius = 15
        let updateValue = leadingConstraintUpdateValue()
        suggestionLeadingConstraint.constant += updateValue
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Poppins-Medium", size: 14)!], for: .normal)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        sendButtonOutlet.isEnabled = !(questionTextField.text?.isEmpty ?? true)
    }
    
    @IBAction func suggestionsDidTapped(_ sender: UIButton) {
        suggestionsButton.isSelected = true
        tipsButton.isSelected = false
        tipsOrSuggestionsImage.image = UIImage(named: "suggestionsUpdate.png")
    }
    
    @IBAction func tipsDidTapped(_ sender: UIButton) {
        suggestionsButton.isSelected = false
        tipsButton.isSelected = true
        tipsOrSuggestionsImage.image = UIImage(named: "tips.png")
    }
    
    
    @IBAction func EditingEndsPrimaryAction(_ sender: UITextField) {
        guard let question = questionTextField.text, !question.isEmpty else {return}
        performSegue(withIdentifier: "toPromptSegue", sender: self)
    }
    
    
    @IBAction func sendDidTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toPromptSegue", sender: sender)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "toPromptSegue" else {
            return
        }
        let vc = segue.destination as! PromptConfirmationViewController
        vc.userPrompt = questionTextField.text!
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
