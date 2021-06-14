//
//  ForumViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 10/5/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class ForumViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, TabBarSwitchDelegate, UITextFieldDelegate{
    
    
    
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var podcastName: UIButton!
    @IBOutlet weak var episodeName: UILabel!
    
    private var hiddenSections = Set<Int>() // used for collapsing replies
    
    var forumChannel: ForumChannel?
    var episode: EpisodeData?
    var sender: Sender?
    
    private var parentCommentList = [ForumComment]()
    private var childCommentList = [String:[ForumComment]]()
    // a dictionary of array of comments, the key for the dictionary is the parent comment's id
    
    private var channelRef: CollectionReference?
    private var channelDatabaseListener: ListenerRegistration?
    
    private var commentDatabaseListener: ListenerRegistration?
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm dd/MM/yy"
        return formatter
    }()

    private let CELL_FORUM = "forumCell"
    
    private let database = Firestore.firestore()
    private let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
    var hidePodcastName = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // for pushing view up when keyboard is shown
//        https://fluffy.es/move-view-when-keyboard-is-shown/#tldr
        
        // call the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
          
              // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        if hidePodcastName{
            podcastName.isHidden = true
            podcastName.isEnabled = false
        }
        
        commentTableView.backgroundColor = UIColor(named: "forumColor")
        
        // https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift?page=1&tab=votes#tab-top
        
        //Looks for single or multiple taps. Dismisses keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        
        // this is for custom section header
        let nib = UINib(nibName: "CommentHeader", bundle: nil)
        commentTableView.register(nib, forHeaderFooterViewReuseIdentifier: "commentHeader")
        
        
        // https://stackoverflow.com/questions/44195986/uitableview-header-dynamic-height-in-run-time
        commentTableView.sectionHeaderHeight = UITableView.automaticDimension
        commentTableView.estimatedSectionHeaderHeight = 999;
        
        
        self.sender = appDelegate?.currentSender

        if let episode = episode{
            episodeName.text = episode.title
            podcastName.setTitle(episode.podcastName, for: .normal)
            
            
            let channelName = episode.title
            var doesExist = false
            
            
            
            
            database.collection("forumChannels").whereField("name", isEqualTo: channelName).getDocuments { (querySnapshot, error) in
                if let _ = error{
                    return
                }
                if let snapshot = querySnapshot{
                    for _ in snapshot.documents{
                            doesExist = true
                            break
                        // if i can loop through document, it means it exists and i can just break
                    }
                    // if forum thread doesnt already exists, create one in firebase
                    if !doesExist {
                        self.database.collection("forumChannels").addDocument(data: ["name" : channelName])
                    }
                }
                
            }
            
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let child = addSpin()
        let database = Firestore.firestore()
        channelDatabaseListener = database.collection("forumChannels").addSnapshotListener() { [self]
            (querySnapshot, error) in
            if let _ = error {
                return
            }
            childCommentList.removeAll()
            parentCommentList.removeAll()
            // find the forum thread we in, i only discovered wherefield after i had coded this monster and i dont have time to change it to use wherefield instead.
            querySnapshot?.documents.forEach() { snapshot in
                guard let name  = episode?.title else {return}
                if snapshot["name"] as! String == name{
                    let id = snapshot.documentID
                    let name = snapshot["name"] as! String
                    self.forumChannel = ForumChannel(id: id, name: name)
                    // add listener for comment in that forum thread
                    
                    commentDatabaseListener = database.collection("forumChannels").document(id).collection("comments").order(by:"time").addSnapshotListener() {
                        (querySnapshot, error) in
                        if let _ = error {
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
                                
                                let parent:String? = snapshot["parent"] as? String
                                
                                let sender = Sender(id: senderId, name: senderName)
                                let comment = ForumComment(sender: sender, messageId: id,
                                                           sentDate: sentDate, message: messageText)
                                comment.parent = parent
                                
                                // https://stackoverflow.com/questions/28129401/determining-if-swift-dictionary-contains-key-and-obtaining-any-of-its-values
                                if let parent = parent, parent.count > 0{
                                    // store replies/ child comments
                                    if self.childCommentList[parent] != nil{
                                        // if key in dictionary already exists
                                        self.childCommentList[parent]?.append(comment)
                                    }
                                    else{
                                        self.childCommentList[parent] = [comment]
                                    }
                                }
                                else{
                                    self.parentCommentList.append(comment)
                                }
                                self.commentTableView.reloadData()
                            }
                        }
                        removeSpin(child)
                    }
                }
            }
        }
        
        
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        channelDatabaseListener?.remove()
        commentDatabaseListener?.remove()
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
            
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           // if keyboard size is not available for some reason, dont do anything
           return
        }
      
      // move the root view up by the distance of keyboard height
      self.view.frame.origin.y = 0 - keyboardSize.height
    }

    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
    }
    
    
    @IBAction func toPodcast(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let podcastViewController = storyboard.instantiateViewController(identifier: "PodcastViewController") as! PodcastInfoViewController
        podcastViewController.podcastID = episode?.podcastID
        self.navigationController?.pushViewController(podcastViewController, animated: true)
    }
    
    @IBAction func send(_ sender: Any) {
        if input.text?.count == 0{
            return
        }
        
        if let forumChannel = forumChannel{
            let channelRef = database.collection("forumChannels").document(forumChannel.id).collection("comments")
            //            https://stackoverflow.com/questions/61909665/how-to-make-null-value-in-a-field-in-firestore-document-using-swift
            channelRef.addDocument(data: ["senderId" : self.sender!.senderId,
                                          "senderName" : self.sender!.displayName,
                                          "text" : input.text,
                                          "time" : Timestamp(date: Date.init()),
                                          "parent": NSNull()])
        }
        input.text = ""
    }
    
    // delegate for TabBarSwitchDelegate, explained in Delegate.swift
    func switchTab(_ tabNumber: Int, _ sender: Sender, _ channel: Channel) {
        // https://stackoverflow.com/questions/25325923/programmatically-switching-between-tabs-within-swift
        self.tabBarController?.selectedIndex = tabNumber
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatMessagesViewController = storyboard.instantiateViewController(identifier: "ChatMessagesViewController") as! ChatMessagesViewController
        chatMessagesViewController.sender = sender
        chatMessagesViewController.currentChannel = channel
        // https://stackoverflow.com/questions/43540728/push-to-another-tabs-viewcontroller
        let nav = self.tabBarController?.viewControllers?[tabNumber] as! UINavigationController
        nav.pushViewController(chatMessagesViewController, animated: true)
        
    }
    

    // dismiss keyboard when user presses return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    // MARK: - Table view data source
    
    // the parent comment is displayed here, through the customer header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if parentCommentList.count == 0{
            let header = self.commentTableView.dequeueReusableHeaderFooterView(withIdentifier: "commentHeader") as! CommentHeader
            header.comment.text = "No one has commented on this thread yet. \nBe the first to share what you think!!!"
            header.comment.textAlignment = .center
            header.username.setTitle("", for: .normal)
            header.timestamp.text = ""
            header.replyUIButton.isHidden = true
            header.replyUIButton.isEnabled = false
            
            header.collapseUIButton.isHidden = true
            header.collapseUIButton.isEnabled = false
            return header
        }
        
        // Dequeue with the reuse identifier
        let header = self.commentTableView.dequeueReusableHeaderFooterView(withIdentifier: "commentHeader") as! CommentHeader
        header.comment.textAlignment = .left
        header.replyUIButton.isHidden = false
        header.replyUIButton.isEnabled = true
        
        header.collapseUIButton.isHidden = false
        header.collapseUIButton.isEnabled = true
        
        let comment = parentCommentList[section]
        
        header.username.setTitle(comment.sender.displayName, for: .normal)
        header.timestamp.text = dateFormatter(date: comment.sentDate)
        
        header.comment.text = comment.message
        
        
        
        header.replyBlock = {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let replyViewController = storyBoard.instantiateViewController(withIdentifier: "replyView") as! ReplyViewController
            replyViewController.forumChannel = self.forumChannel
            replyViewController.commentToReplyTo = comment
            replyViewController.parentId = comment.messageId
            self.navigationController?.pushViewController(replyViewController, animated: true)
            
        }
        
        header.collapseBlock = { [self] in
            // https://programmingwithswift.com/expand-collapse-uitableview-section-with-swift/
            // Add indexPathsForSection method
            let parentComment = parentCommentList[section]
            func indexPathsForSection() -> [IndexPath] {
                var indexPaths = [IndexPath]()
 
                if let replies = self.childCommentList[parentComment.messageId]{
                    for row in 0..<replies.count {
                        indexPaths.append(IndexPath(row: row,
                                                    section: section))
                    }
                }
                
                
                return indexPaths
            }
            // Logic to add/remove sections to/from hiddenSections, and delete and insert functionality for tableView
            
            if self.hiddenSections.contains(section) {
                self.hiddenSections.remove(section)
                self.commentTableView.insertRows(at: indexPathsForSection(),
                                                 with: .fade)
                
                let image = UIImage(systemName: "arrowtriangle.right.fill.and.line.vertical.and.arrowtriangle.left.fill")
                header.collapse.setImage(image, for: .normal)
            } else {
                self.hiddenSections.insert(section)
                self.commentTableView.deleteRows(at: indexPathsForSection(),
                                                 with: .fade)
                let image = UIImage(systemName: "arrowtriangle.left.fill.and.line.vertical.and.arrowtriangle.right.fill")
                
                header.collapse.setImage(image, for: .normal)
            }
        }
        
        if let name = header.username.titleLabel?.text{
            header.usernameBlock = usernameTapped(name, self, false)
        }
        
        return header
    }
    
//    https://programmingwithswift.com/expand-collapse-uitableview-section-with-swift/
    @objc
    private func hideSection(sender: UIButton) {
        // Create section let
        let section = sender.tag
        // Add indexPathsForSection method
        let parentComment = parentCommentList[section]
        func indexPathsForSection() -> [IndexPath] {
            var indexPaths = [IndexPath]()
            
            for row in 0..<self.childCommentList[parentComment.messageId]!.count {
                indexPaths.append(IndexPath(row: row,
                                            section: section))
            }
            
            return indexPaths
        }
        // Logic to add/remove sections to/from hiddenSections, and delete and insert functionality for tableView
        
        if self.hiddenSections.contains(section) {
            self.hiddenSections.remove(section)
            self.commentTableView.insertRows(at: indexPathsForSection(),
                                             with: .fade)
        } else {
            self.hiddenSections.insert(section)
            self.commentTableView.deleteRows(at: indexPathsForSection(),
                                             with: .fade)
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if parentCommentList.count == 0{
            return 1
        }
        return parentCommentList.count
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if parentCommentList.count == 0{
            return 0
        }
        if self.hiddenSections.contains(section) {
            return 0
        }
        
        let parentCommentId = parentCommentList[section].messageId
        if let replies = childCommentList[parentCommentId]{
            return replies.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_FORUM, for: indexPath) as! ForumTableViewCell
        let parentCommentId = parentCommentList[indexPath.section].messageId
        
        if let comment = childCommentList[parentCommentId]?[indexPath.row]{
            
            cell.username.setTitle(comment.sender.displayName, for: .normal)
            cell.timestamp.text = dateFormatter(date: comment.sentDate)
            
            cell.comment.text = comment.message
            
            
            
            cell.replyBlock = {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let replyViewController = storyBoard.instantiateViewController(withIdentifier: "replyView") as! ReplyViewController
                replyViewController.forumChannel = self.forumChannel
                replyViewController.commentToReplyTo = comment
                replyViewController.parentId = comment.parent
                self.navigationController?.pushViewController(replyViewController, animated: true)
                
            }
            cell.usernameBlock = usernameTapped(comment.sender.displayName, self, false)
            
        }
        
        
        cell.replyUIButton.layer.cornerRadius = 10
        cell.contentView.backgroundColor = UIColor(named: "forumColor")
        return cell
        
        
        
    }
    
    
}
