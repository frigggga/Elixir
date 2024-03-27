//
//  PromptConfirmationViewController.swift
//  Elixir
//
//  Created by Jack Stark on 3/27/23.
//

import UIKit

class PromptConfirmationViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var userPrompt: String!
    var originalQuestion: String!
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet var confirmationButton: UIButton!
    @IBOutlet var rephraseButton: UIButton!
    @IBOutlet weak var keepQuestionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let buttonTitle = rephraseButton.title(for: .normal) ?? ""
        let button2Title = keepQuestionButton.title(for: .normal) ?? ""
        let attributedTitle = NSAttributedString(string: buttonTitle, attributes: [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        let attributedTitle2 = NSAttributedString(string: button2Title, attributes: [
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        confirmationButton.tintColor = UIColor(rgb: 0x316BA0)
        confirmationButton.layer.cornerRadius = 15
        confirmationButton.layer.borderWidth = 1.0
        confirmationButton.layer.borderColor = UIColor(rgb: 0x316BA0).cgColor
        confirmationButton.clipsToBounds = true
        rephraseButton.setAttributedTitle(attributedTitle, for: .normal)
        keepQuestionButton.setAttributedTitle(attributedTitle2, for: .normal)
        promptLabel.text = userPrompt
        originalQuestion = userPrompt
        rephrase()
        let backBTN = UIBarButtonItem(image: UIImage(named: "backButton.png"),
                                      style: .plain,
                                      target: navigationController,
                                      action: #selector(UINavigationController.popViewController(animated:)))
        navigationItem.leftBarButtonItem = backBTN
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "toTarotSelectionSegue" else {
            return
        }
        let vc = segue.destination as! TarotSelectionViewController
        vc.prompt = userPrompt  //TODO: change to GPT refined response
    }
    
    @IBAction func confirmationButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "toTarotSelectionSegue", sender: self)
    }
    
    @IBAction func rephraseButtonPressed(_ sender: UIButton) {
        // call chatgpt api
        rephrase();
    }
    
    
    @IBAction func keepQuestionButtonPressed(_ sender: UIButton) {
        self.userPrompt = originalQuestion
        self.promptLabel.text = originalQuestion
    }
    
    func rephrase(){
        promptLabel.text = "Rephrasing Question..."
        var GPTresponse = ""
        sendMessageToChatGPT(originalQuestion) { [weak self] responseMessage in
            DispatchQueue.main.async {
                if let responseMessage = responseMessage {
                    // For testing purposes
                    GPTresponse = responseMessage.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
                    self?.userPrompt = GPTresponse
                    self?.promptLabel.text = self?.userPrompt
                    // print("GPT responsding: " + GPTresponse)
                }else{
                    GPTresponse = "The server had an error while processing your request. Sorry about that!"
                    self?.promptLabel.text = GPTresponse
                }
            }
        }
    }
    
    func sendMessageToChatGPT(_ message: String, completion: @escaping (String?) -> Void) {
        // Set up the API request
        let apiKey = Constants.openAIAPIKey
        
        let parameters = [
            "messages": [
                    ["role": "system", "content": "You are processing user input for a tarot reading app. The user may include random input but you must rephrase the user input to a concise question. However, don't include word \"tarot\" in the question."],
                    ["role": "user", "content": "Rephrase the following content into a concise question for tarot reading: " + message]
            ],
            "model": "gpt-3.5-turbo",
            "max_tokens": 1000 ] as [String : Any]
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
    
    
    
}
