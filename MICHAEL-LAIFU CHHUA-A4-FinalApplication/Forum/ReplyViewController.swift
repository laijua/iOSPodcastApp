//
//  ReplyViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 20/5/21.
//

import UIKit
import FirebaseFirestore

class ReplyViewController: UIViewController, UITextViewDelegate {

    var commentToReplyTo: ForumComment? // parent comment
    var forumChannel: ForumChannel?
    var parentId: String?
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var RepliedToComment: UILabel!
    
    @IBOutlet weak var input: UITextView!
    
    @IBOutlet weak var scrollView: UIScrollView!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+1000)
//         https://stackoverflow.com/questions/27652227/add-placeholder-text-inside-uitextview-in-swift
        input.delegate = self
        input.text = "Your reply"
        input.textColor = UIColor.lightGray
        
//        https://stackoverflow.com/questions/30022780/uibarbuttonitem-in-navigation-bar-programmatically
        let replyButton = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(send))
        self.navigationItem.rightBarButtonItem  = replyButton
        
        
        if let commentToReplyTo = commentToReplyTo{
            username.text = commentToReplyTo.sender.displayName
            timestamp.text = dateFormatter(date: commentToReplyTo.sentDate)
            RepliedToComment.text = commentToReplyTo.message
        }
    }
    
    @objc func send(){
        // checking if not grey, as grey is placeholder text
        if input.text.count == 0 || input.textColor == UIColor.lightGray{
            displayMessage(title: "Reply can't be empty", message: "")
            return
        }
        
        let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
        let sender = appDelegate?.currentSender
        
        let database = Firestore.firestore()
        if let forumChannel = forumChannel{
            let channelRef = database.collection("forumChannels").document(forumChannel.id).collection("comments")
            
            channelRef.addDocument(data: ["senderId" : sender!.senderId,
                                          "senderName" : sender!.displayName,
                                          "text" : input.text,
                                          "time" : Timestamp(date: Date.init()),
                                          "parent": parentId])
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
