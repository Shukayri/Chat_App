//
//  DatabaseManager.swift
//  Chat_App
//
//  Created by administrator on 1/8/22.
//

import Foundation
import FirebaseDatabase
final class DatabaseManger {
    
    static let shared = DatabaseManger()
    
    // reference the database below
    
    private let database = Database.database().reference()
    
    // create a simple write function
    
    
    
    public func test() {
        // NoSQL - JSON (keys and objects)
        // child refers to a key that we want to write data to
        // in JSON, we can point it to anything that JSON supports - String, another object
        // for users, we might want a key that is the user's email address
        
        database.child("foo").setValue(["something":true])
    }
    
    static func safeEmail(emailAddress:String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}
// MARK: - account management
extension DatabaseManger {
    
    // have a completion handler because the function to get data out of the database is asynchrounous so we need a completion block
    
    
    public func userExists(with email:String, completion: @escaping ((Bool) -> Void)) {
        // will return true if the user email does not exist
        
        // firebase allows you to observe value changes on any entry in your NoSQL database by specifying the child you want to observe for, and what type of observation you want
        // let's observe a single event (query the database once)
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            // snapshot has a value property that can be optional if it doesn't exist
            
            guard snapshot.value as? String != nil else {
                // otherwise... let's create the account
                completion(false)
                return
            }
            
            // if we are able to do this, that means the email exists already!
            
            completion(true) // the caller knows the email exists already
        }
    }
    
    /// Insert new user to database
    public func insertUser(with user: ChatAppUser , completion: @escaping (Bool) -> Void){
        let userDic = ["first_name":user.firstName,"last_name":user.lastName, "E_mail" : user.emailAddress]
        database.child(user.safeEmail).setValue(userDic){ error , _ in
            self.userExists(with: user.emailAddress) { isNotInsert in
                if isNotInsert == true {
                    print("ez")
                    completion(false)
                }else {
                    
                    self.database.child("users").observeSingleEvent(of: .value) { snapshot in
                        if var usersCollection = snapshot.value as? [[String : String]] {
                            // append to users dictionary
                            
                            let newElement = [
                                "name": user.firstName + " " + user.lastName,
                                "email": user.safeEmail
                            ]
                            
                            usersCollection.append(newElement)
                            
                            self.database.child("users").setValue(usersCollection) { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            }
                            
                        } else {
                            // create that array
                            let newCollection: [[String: String]] = [
                                [
                                    "name": user.firstName + " " + user.lastName,
                                    "email": user.safeEmail
                                ]
                            ]
                            self.database.child("users").setValue(newCollection) { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                print("ez1")

                                completion(true)
                            }
                        }
                        
                        
                        
                        
                        print("ez2")
                        
                    }
                }
            }
        }
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
            database.child("users").observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [[String: String]] else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                completion(.success(value))
                
            }
        }
        
        public enum DatabaseError: Error {
            case failedToFetch
        }
    
    
}


// MARK : - sending messages / cinverstion

extension DatabaseManger {
    /// creates a new conversation with target user email and first message sent
    public func createNewConversation(with otherUserEmail: String,  firstMessage: Message, completion: @escaping (Bool) -> Void) {
            // put conversation in the user's conversation collection, and then 2. once we create that new entry, create the root convo with all the messages in it
            guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String
                  else {
                return
            }
            let safeEmail = DatabaseManger.safeEmail(emailAddress: currentEmail)
        let ref = database.child("\(safeEmail)")

        // cant have certain characters as keys
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            
            guard var userNode = snapshot.value as? [String: Any] else {
                          // we should have a user
                          completion(false)
                          print("user not found")
                          return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.datsFormatter.string(from: messageDate)
            var message = ""
                       
                       switch firstMessage.kind {
                       case .text(let messageText):
                           message = messageText
                       case .attributedText(_):
                           break
                       case .photo(_):
                           break
                       case .video(_):
                           break
                       case .location(_):
                           break
                       case .emoji(_):
                           break
                       case .audio(_):
                           break
                       case .contact(_):
                           break
                       case .linkPreview(_):
                           break
                       case .custom(_):
                           break
                       }
            let conversationId = "Conversation\(firstMessage.messageId)"
            
            let newConversationData: [String:Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                    
                ],
                
            ]
            
            if var Conversations = userNode["Conversations"] as? [[String:Any]]{
                
                Conversations.append(newConversationData)
                userNode["Conversations"]  = Conversations
                ref.setValue(userNode , withCompletionBlock:  { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.finishCreatingConversation(conversationID: conversationId, firstMessage: firstMessage, completion: completion)                })
            }
            else {
                userNode["Conversations"] = [
                newConversationData
                ]
              
                ref.setValue(userNode , withCompletionBlock:  { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                })
    }
        
    }
        
    }
    private func finishCreatingConversation(conversationID:String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        
        
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.datsFormatter.string(from: messageDate)
        var message = ""
                
                switch firstMessage.kind {
                case .text(let messageText):
                    message = messageText
                case .attributedText(_):
                    break
                case .photo(_):
                    break
                case .video(_):
                    break
                case .location(_):
                    break
                case .emoji(_):
                    break
                case .audio(_):
                    break
                case .contact(_):
                    break
                case .linkPreview(_):
                    break
                case .custom(_):
                    break
                }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String
              else {
                  completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManger.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
                    "id": firstMessage.messageId,
                    "type": firstMessage.kind.messageKindString,
                    "content": message,
                    "date": dateString,
                    "sender_email": currentUserEmail,
                    "is_read": false,
                    
                ]
        
        let value: [String:Any] = [
                  "messages": [
                    collectionMessage
                  ]
              ]
        print("adding con\(conversationID)")
        database.child("\(conversationID)").setValue(value) { error, _ in
                  guard error == nil else {
                      completion(false)
                      return
                  }
                  completion(true)
              }
        
    }
    
    /// Fetches and returns all conversations for the user with

    public func getAllConversation(with email : String , completion:@escaping (Result<String , Error>) -> Void){
        
        
    }
    
    /// gets all messages from a given conversation
        public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
            
        }
    
    
    ///// Sends a message with target conversation and message
        public func sendMessage(to conversation: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
            
        }
}





    struct ChatAppUser {
        let firstName: String
        let lastName: String
        let emailAddress: String
        var profilePictureFileName: String {
            
            return "\(safeEmail)_profile_picture.png"
        }
        
        // create a computed property safe email
        
        var safeEmail: String {
            var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
            return safeEmail
        }
    }
    

