//
//  CardResultViewController.swift
//  Elixir
//
//  Created by Jack Stark on 3/12/23.
//

import UIKit
import Kingfisher
import Foundation

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

class CardResultViewController: UIViewController, UIGestureRecognizerDelegate {
    var card1, card2, card3: Tarot!
    var question = ""
    var tarotReading: TarotReading?
    
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var questionOutlet: UILabel!
    @IBOutlet weak var upView: UIView!
    @IBOutlet weak var lowerView: UIView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet var resultTextView: UITextView!
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var anotherQuestionButton: UIButton!
    @IBOutlet weak var Navbar: UINavigationItem!
    
    override func viewWillAppear(_ animated: Bool) {
        if let url1 = URL(string: card1.image_url) {
            image1.kf.setImage(with: url1)
        }
        if let url2 = URL(string: card2.image_url) {
            image2.kf.setImage(with: url2)
        }
        if let url3 = URL(string: card3.image_url) {
            image3.kf.setImage(with: url3)
        }
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        anotherQuestionButton.tintColor = UIColor(rgb: 0x316BA0)
        favoriteButton.tintColor = UIColor(rgb: 0x316BA0)
        let backBTN = UIBarButtonItem(image: UIImage(named: "backButton.png"),
                                      style: .plain,
                                      target: navigationController,
                                      action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.leftBarButtonItem = backBTN
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        tarotReading = TarotReading(prompt: question, Tarots: [card1, card2, card3], conciseReading: "", fullReading: "", date: Date(), isFavorite: false)
        favoriteButton.setImage(UIImage(named: "Love"), for: .selected)
        favoriteButton.isEnabled = false
        favoriteButton.setTitle("", for: .normal)
        anotherQuestionButton.isEnabled = false
      //  Navbar.title = "Elixir is reading..."
//        resultTextView.text = "Your cards: " + card1.name + ", " + card2.name + ", " + card3.name + "\n\n" + "Your question: " + question
        shareButton.setTitle("", for: .normal)
        shareButton.isHidden = true     //will change this when share feature is added
        anotherQuestionButton.layer.borderWidth = 1.5
        anotherQuestionButton.layer.cornerRadius = anotherQuestionButton.frame.size.height / 2
        anotherQuestionButton.layer.masksToBounds = true
        anotherQuestionButton.layer.borderColor = UIColor(rgb: 0x6F6B9A).cgColor
        upView.layer.cornerRadius = 8
        lowerView.layer.cornerRadius = 8
        rotateImageView(image1, by: -10)
        rotateImageView(image3, by: 10)
        resultTextView.text = ""
        questionOutlet.text = question
        // Do any additional setup after loading the view.
        var GPTresponse = ""
        let summaryPrompt = "Generate a short summary of the reading within two to three sentences, with at most 100 words. Starting with \"Summary: \""
        sendMessageToChatGPT(summaryPrompt, maxTokens: 200) { [weak self] responseMessage in
            DispatchQueue.main.async {
                if let responseMessage = responseMessage {
                    GPTresponse = responseMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                    print("GPT summary: " + GPTresponse)
                    self?.tarotReading?.conciseReading = GPTresponse
                    
                    // only bold the summary
                    if let weakSelf = self, let summary = weakSelf.tarotReading?.conciseReading {
                        let summaryAttributedString = NSMutableAttributedString(string: summary, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: weakSelf.resultTextView.font?.pointSize ?? 14)])
//                        let summaryAttributedString = NSMutableAttributedString(string: summary, attributes: [NSAttributedString.Key.font: UIFont(name: "Poppins-Bold", size: weakSelf.resultTextView.font?.pointSize ?? 14)!])
                        weakSelf.resultTextView.attributedText = summaryAttributedString
                    }
                }
            }
        }

        let detailedPrompt = "Now, give the detailed readings. Starting with \"Detailed Readings: \""
        sendMessageToChatGPT(detailedPrompt, maxTokens: 900) { [weak self] responseMessage in
            DispatchQueue.main.async {
                if let responseMessage = responseMessage {
                    GPTresponse = responseMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                    print("GPT detailed reading: " + GPTresponse)
                    self?.favoriteButton.isEnabled = true
                    self?.anotherQuestionButton.isEnabled = true
                    self?.tarotReading?.fullReading = GPTresponse
                } else {
                    GPTresponse = "The server had an error while processing your request. Sorry about that!"
                }
                if let weakSelf = self, let detailedReading = weakSelf.tarotReading?.fullReading {
                    let detailedReadingAttributedString = NSMutableAttributedString(string: detailedReading, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: weakSelf.resultTextView.font?.pointSize ?? 14)])
                    
//                    let detailedReadingAttributedString = NSMutableAttributedString(string: detailedReading, attributes: [NSAttributedString.Key.font: UIFont(name: "Poppins-Regular", size: weakSelf.resultTextView.font?.pointSize ?? 14)!])
                    
                    if let summary = weakSelf.tarotReading?.conciseReading {
                        let summaryAttributedString = NSMutableAttributedString(string: summary, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: weakSelf.resultTextView.font?.pointSize ?? 14)])
                        let combinedAttributedString = NSMutableAttributedString()
                        combinedAttributedString.append(summaryAttributedString)
                        combinedAttributedString.append(NSAttributedString(string: "\n\n")) // Add an empty line
                        combinedAttributedString.append(detailedReadingAttributedString)
                        weakSelf.resultTextView.attributedText = combinedAttributedString
                    } else {
                        weakSelf.resultTextView.attributedText = detailedReadingAttributedString
                    }
                }

             //   self?.Navbar.title = "Reading Completed!"
            }
        }
    }
    
    func rotateImageView(_ imageView: UIImageView, by degrees: CGFloat) {
        let radians = degrees * (.pi / 180)
        imageView.transform = CGAffineTransform(rotationAngle: radians)
    }
    
    func sendMessageToChatGPT(_ message: String, maxTokens: Int, completion: @escaping (String?) -> Void) {
        // Set up the API request
        let apiKey = Constants.openAIAPIKey
        
        let prompt = "I asked the question: " + question + " and got three cards: " + card1.name + " for the past, " + card2.name + " for the present, and " + card3.name + " for the future." + message
        
        let parameters = [
                    "messages": [
                            ["role": "system", "content": "You are a tarot card reader. You interpret tarot cards with a certain question. The reading should specific to the question asked. Directly give the readings, never add greetings or say anything like 'as a tarot card reader, I cannot ...'"],
                            ["role": "user", "content": prompt]
                    ],
                    "model": "gpt-3.5-turbo",
                    "max_tokens": maxTokens ] as [String : Any]
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Error: cannot create URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            print("Error: cannot create JSON data")
            completion(nil)
            return
        }
        request.httpBody = httpBody

        // Send the API request and get the response
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }

            // for testing
            print(String(data: data, encoding: .utf8) ?? "Response data could not be printed")
            guard let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let choices = responseJSON["choices"] as? [[String: Any]],
                let messageArray = choices[0]["message"] as? [String: Any],
                let responseText = messageArray["content"] as? String else {
                print("Error: cannot parse API response")
                completion(nil)
                return
            }
            
            // Return the response message
            completion(responseText)
        }
        task.resume()
    }
    
    @IBAction func anotherQuestionButtonPressed(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        favoriteButton.isSelected.toggle()
        guard var tarotReading = tarotReading else { return }
        if favoriteButton.isSelected {
            tarotReading.isFavorite = true
            ElixirModel.shared.savedReadings.append(tarotReading)
        } else {
            tarotReading.isFavorite = false
            ElixirModel.shared.savedReadings.removeAll { $0.ID == tarotReading.ID}
        }
    }
    
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

