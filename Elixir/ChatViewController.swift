//
//  ChatViewController.swift
//  Elixir
//
//  Created by Jack Stark on 2/4/23.
//
// Reference: https://ibjects.medium.com/simple-text-chat-app-using-firebase-in-swift-5-b9fa91730b6c

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Kingfisher
import Foundation

enum ChatMode {
case tea
case tarot
}

class ChatViewController: MessagesViewController {
    
    var mode = ChatMode.tea
    
    // Dummy variables for testing purposes
    var card_1 = "The Devil"
    var card_2 = "Ace of Cups"
    var card_3 = "Four of Pentacles"
    
    //var currentUser: User = Auth.auth().currentUser!
    private var docReference: DocumentReference?
    var messages: [Message] = []
    
    var currentUserName: String = "Guest"
    var currentuserImageUrl: String = "https://images.unsplash.com/photo-1543083115-638c32cd3d58?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=3732&q=80"
    var currentUserUID: String = UUID().uuidString
    
    var user2Name: String = "Elixir"
    var user2ImgUrl: String = "https://images.unsplash.com/photo-1581860221490-c43bc1e653f4?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1335&q=80"
    var user2UID: String = UUID().uuidString
    
    @IBOutlet weak var NavBar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = user2Name
        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnInputBarHeightChanged = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
        messageInputBar.inputTextView.tintColor = .systemBlue
        messageInputBar.sendButton.setTitleColor(.systemTeal, for: .normal)
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        loadChat()
    }
    
    // MARK: Helper Functions
    func loadChat() {
        //Fetch all the chats which has current user in it
        let db = Firestore.firestore().collection("Chats").whereField("users", arrayContains: Auth.auth().currentUser?.uid ?? "Not Found User 1")
        
        db.getDocuments { (chatQuerySnap, error) in
            if let error = error {
                print("Error: \(error)")
                return
            } else {
                //Count the no. of documents returned
                guard let queryCount = chatQuerySnap?.documents.count else { return }
                if queryCount == 0 {
                    //If documents count is zero that means there is no chat available and we need to create a new instance
                    self.createNewChat()
                    
                    //Firstly, start with a guiding question depending on the mode
                    var opening = ""
                    
                    // add a mode check here, if mode == tarot, send tarot card message
                    switch self.mode {
                    case .tarot:
                        opening = "Ask me a question and I will draw three tarot cards for you."
                    case .tea:
                        opening = "Hi, how can I help with you today? Tell me about yourself and I can give you some tea recommendations!"
                    }
                    
                    let GPTOpening = Message(id: UUID().uuidString, content: opening, created: Timestamp(), senderID: self.user2UID, senderName: self.user2Name)
                    //calling function to insert and save message
                    self.insertNewMessage(GPTOpening)
                    // not sure if we need to save this message or not
                    // save(GPTOpening)
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                    // messagesCollectionView.scrollToBottom(animated: true)
                    
                } else if queryCount >= 1 {
                    //Chat(s) found for currentUser
                    for doc in chatQuerySnap!.documents {
                        let chat = Chat(dictionary: doc.data())
                        //Get the chat which has user2 id
                        if (chat?.users.contains(self.user2UID )) == true {
                            self.docReference = doc.reference
                            //fetch it's thread collection
                            doc.reference.collection("thread")
                                .order(by: "created", descending: false)
                                .addSnapshotListener(includeMetadataChanges: true, listener: { (threadQuery, error) in
                                    if let error = error {
                                        print("Error: \(error)")
                                        return
                                    } else {
                                        self.messages.removeAll()
                                        for message in threadQuery!.documents {
                                            let msg = Message(dictionary: message.data())
                                            self.messages.append(msg!)
                                            print("Data: \(msg?.content ?? "No message found")")
                                        }
                                        //We'll edit viewDidload below which will solve the error
                                        self.messagesCollectionView.reloadData()
                                        self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                                    }
                                })
                            return
                        } //end of if
                    } //end of for
                    self.createNewChat()
                } else {
                    print("Let's hope this error never prints!")
                }
            }
        }
    }
    
    func createNewChat() {
        let users = [self.currentUserUID, self.user2UID]
        let data: [String: Any] = [
            "users":users
        ]
        let db = Firestore.firestore().collection("Chats")
        db.addDocument(data: data) { (error) in
            if let error = error {
                print("Unable to create chat! \(error)")
                return
            } else {
                self.loadChat()
            }
        }
    }
    
    private func insertNewMessage(_ message: Message) {
        //add the message to the messages array and reload it
        messages.append(message)
        messagesCollectionView.reloadData()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        }
    }
    
    private func save(_ message: Message) {
        //Preparing the data as per our firestore collection
        let data: [String: Any] = [
            "content": message.content,
            "created": message.created,
            "id": message.id,
            "senderID": message.senderID,
            "senderName": message.senderName
        ]
        //Writing it to the thread using the saved document reference we saved in load chat function
        docReference?.collection("thread").addDocument(data: data, completion: { (error) in
            if let error = error {
                print("Error Sending message: \(error)")
                return
            }
            self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        })
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


extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //When use press send button this method is called.
        let message = Message(id: UUID().uuidString, content: text, created: Timestamp(), senderID: currentUserUID, senderName: currentUserName)
        //calling function to insert and save message
        insertNewMessage(message)
        save(message)
        //clearing input field
        inputBar.inputTextView.text = ""
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
        // messagesCollectionView.scrollToBottom(animated: true)
        
        // Get chatGPT response
        NavBar.title = "Elixir is typing..."
        var GPTresponse = ""
        sendMessageToChatGPT(text) { [weak self] responseMessage in
            DispatchQueue.main.async {
                if let responseMessage = responseMessage {
                    // For testing purposes
                    GPTresponse = responseMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                    print("GPT responsding: " + GPTresponse)
                }else{
                    GPTresponse = "The server had an error while processing your request. Sorry about that!"
                }
                let GPTMessage = Message(id: UUID().uuidString, content: GPTresponse, created: Timestamp(), senderID: self!.user2UID, senderName: self!.user2Name)
                self?.insertNewMessage(GPTMessage)
                self?.save(GPTMessage)
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                self?.NavBar.title = "Elixir"
            }
        }
    }
    
    func sendMessageToChatGPT(_ message: String, completion: @escaping (String?) -> Void) {
        // Set up the API request
        let apiKey = Constants.openAIAPIKey
        var prompt = ""
        
        // add a mode check here, if mode == tarot, send tarot card message
        switch mode {
        case .tarot:
            prompt = "Pretending that you are a tarot reader, I asked the question: " + message + " and got three cards: " + card_1 + " for the past, " + card_2 + " for the present, and " + card_3 + " for the future. Could you elaborate on my background and the question to tell me the meaning behind it?"
        case .tea:
            prompt = message + "Recommend a tea for me."
        }
        
        let parameters = [
            "messages": [
                    ["role": "system", "content": "You are a chatbot that is recommending tea for users. You only answer tea related questions."],
                    ["role": "user", "content": prompt]
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

extension ChatViewController: MessagesDataSource {
    var currentSender: MessageKit.SenderType {
        return ChatUser(senderId: currentUserUID, displayName: currentUserName)
    }
    
//    func currentSender() -> SenderType {
//
//        // return Sender(id: Auth.auth().currentUser!.uid, displayName: Auth.auth().currentUser?.displayName ?? "Name not found")
//    }
    
    //This return the MessageType which we have defined to be text in Messages.swift
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    //Return the total number of messages
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        if messages.count == 0 {
            print("There are no messages")
            return 0
        } else {
            return messages.count
        }
    }
}

extension ChatViewController: MessagesLayoutDelegate, MessagesDisplayDelegate{
    // We want the default avatar size. This method handles the size of the avatar of user that'll be displayed with message
    private func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    //Explore this delegate to see more functions that you can implement but for the purpose of this tutorial I've just implemented one function.
    
    //Background colors of the bubbles
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .blue: .lightGray
    }
    
    //THis function shows the avatar
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        //If it's current user show current user photo.
        if message.sender.senderId == currentUserUID {
            avatarView.kf.setImage(with: URL(string: currentuserImageUrl))
        } else {
            avatarView.kf.setImage(with: URL(string: user2ImgUrl))
        }
    }
    
    //Styling the bubble to have a tail
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight: .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}


