//
//  ChatMessagesViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 15/5/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class ChatMessagesViewController: MessagesViewController,MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    var sender: Sender?
    
    var currentChannel: Channel?
    
    private var messagesList = [ChatMessage]()
    
    private var channelRef: CollectionReference?
    private var databaseListener: ListenerRegistration?
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm dd/MM/yy"
        return formatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        if currentChannel != nil {
            let database = Firestore.firestore()
            channelRef = database.collection("channels")
                .document(currentChannel!.id).collection("messages")
            
            // room names in firebase are named in the format "a,b" or "b,a" depending on who messages who first. a and b are names of users
            let currentSenderName = sender?.displayName
            guard let name = currentChannel?.name else{return}
            // split the two names and name the room after the other user.
            let array = name.components(separatedBy: ",")
            var recipientName: String?
            for n in array{
                if n != currentSenderName{
                    recipientName = n
                }
            }
            if let recipientName = recipientName{
                navigationItem.title = "\(recipientName)"
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseListener = channelRef?.order(by:"time").addSnapshotListener() {
            (querySnapshot, error) in
            if let error = error {
                
                return
            }
            querySnapshot?.documentChanges.forEach() { change in
                if change.type == .added {
                    let snapshot = change.document
                    
                    let id = snapshot.documentID
                    let senderId = snapshot["senderId"] as! String
                    let senderName = snapshot["senderName"] as! String
                    let messageText = snapshot["text"] as! String
                    let sentTimestamp = snapshot["time"] as! Timestamp
                    let sentDate = sentTimestamp.dateValue()
                    
                    let sender = Sender(id: senderId, name: senderName)
                    let message = ChatMessage(sender: sender, messageId: id,
                                              sentDate: sentDate, message: messageText)
                    self.messagesList.append(message)
                    self.messagesCollectionView.insertSections([self.messagesList.count-1])
                }
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseListener?.remove()
    }
    
    func currentSender() -> SenderType {
        guard let sender = sender else {
            return Sender(id: "",name: "")
        }
        
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messagesList[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messagesList.count
    }
    
    func messageTopLabelAttributedText(for message: MessageType,
                                       at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes:
                                    [NSAttributedString.Key.font:UIFont.preferredFont(
                                        forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType,
                                          at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes:
                                    [NSAttributedString.Key.font:UIFont.preferredFont(
                                        forTextStyle: .caption2)])
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView,
                  didPressSendButtonWith text: String) {
        if text.replacingOccurrences(of: " ", with: "").isEmpty {
            return
        }
        
        channelRef?.addDocument(data: [
            "senderId" : sender!.senderId,
            "senderName" : sender!.displayName,
            "text" : text,
            "time" : Timestamp(date: Date.init())
        ])
        inputBar.inputTextView.text = ""
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath:
                                IndexPath, in messagesCollectionView: MessagesCollectionView)
    -> CGFloat {
        return 18
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath:
                                IndexPath, in messagesCollectionView: MessagesCollectionView)
    -> CGFloat {
        return 17
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath:
                                IndexPath, in messagesCollectionView: MessagesCollectionView)
    -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath:
                                    IndexPath, in messagesCollectionView: MessagesCollectionView)
    -> CGFloat {
        return 16
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView)
    -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
}
