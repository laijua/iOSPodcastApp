//
//  ReplyViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 20/5/21.
//

import UIKit
import FirebaseFirestore

class ReplyViewController: UIViewController, UITextViewDelegate {

    var parentComment: ForumComment?
    var forumChannel: ForumChannel?
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var parentMessage: UILabel!
    
    @IBOutlet weak var input: UITextView!
    
//    @IBAction func Reply(_ sender: Any) {
//
//        let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
//        let sender = appDelegate?.currentSender
//
//        let database = Firestore.firestore()
//        if let forumChannel = forumChannel{
//            let channelRef = database.collection("forumChannels").document(forumChannel.id).collection("comments")
//
//            channelRef.addDocument(data: ["senderId" : sender!.senderId,
//                                          "senderName" : sender!.displayName,
//                                          "text" : input.text,
//                                          "time" : Timestamp(date: Date.init()),
//                                          "parent": parentComment?.messageId])
//        }
//        navigationController?.popViewController(animated: true)
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
//         https://stackoverflow.com/questions/27652227/add-placeholder-text-inside-uitextview-in-swift
        input.delegate = self
        input.text = "Your reply"
        input.textColor = UIColor.lightGray
        
//        https://stackoverflow.com/questions/30022780/uibarbuttonitem-in-navigation-bar-programmatically
        let replyButton = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(send))
        self.navigationItem.rightBarButtonItem  = replyButton
        
        
        if let parentComment = parentComment{
            username.text = parentComment.sender.displayName
            timestamp.text = dateFormatter(date: parentComment.sentDate)
            parentMessage.text = parentComment.message
        }
    }
    
    @objc func send(){
        let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
        let sender = appDelegate?.currentSender
        
        let database = Firestore.firestore()
        if let forumChannel = forumChannel{
            let channelRef = database.collection("forumChannels").document(forumChannel.id).collection("comments")
            
            channelRef.addDocument(data: ["senderId" : sender!.senderId,
                                          "senderName" : sender!.displayName,
                                          "text" : input.text,
                                          "time" : Timestamp(date: Date.init()),
                                          "parent": parentComment?.messageId])
        }
        navigationController?.popViewController(animated: true)
    }

    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
                textView.text = nil
                textView.textColor = UIColor.black
            }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Your reply"
            textView.textColor = UIColor.lightGray
        }
    }
    

}
