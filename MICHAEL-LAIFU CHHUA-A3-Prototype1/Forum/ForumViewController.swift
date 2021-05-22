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

class ForumViewController: UIViewController,UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var input: UITextField!
    @IBAction func send(_ sender: Any) {
        let database = Firestore.firestore()
        if let forumChannel = forumChannel{
            let channelRef = database.collection("forumChannels").document(forumChannel.id).collection("comments")
            
            channelRef.addDocument(data: ["senderId" : self.sender!.senderId,
                                          "senderName" : self.sender!.displayName,
                                          "text" : input.text,
                                          "time" : Timestamp(date: Date.init()),
                                          "parent": NSNull()])
        }
        
    }
    @IBOutlet weak var commentTableView: UITableView!
    
    var hiddenSections = Set<Int>()
    
    var forumChannel: ForumChannel?
    
    var sender: Sender?
    
    var parentCommentList = [ForumComment]()
    var childCommentList = [String:[ForumComment]]()
    
    var channelRef: CollectionReference?
    var channelDatabaseListener: ListenerRegistration?
    
    var messageDatabaseListener: ListenerRegistration?
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm dd/MM/yy"
        return formatter
    }()
    
    
    var episode: EpisodeData?
    @IBOutlet weak var podcastName: UIButton!
    @IBOutlet weak var episodeName: UILabel!
    
    let CELL_FORUM = "forumCell"
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        commentTableView.backgroundColor = UIColor(named: "forumColor")
        
        // https://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift?page=1&tab=votes#tab-top
        
        //Looks for single or multiple taps.
             let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

            tap.cancelsTouchesInView = false

            view.addGestureRecognizer(tap)
        
        
        
        let nib = UINib(nibName: "CommentHeader", bundle: nil)
        commentTableView.register(nib, forHeaderFooterViewReuseIdentifier: "commentHeader")
        
        
        // https://stackoverflow.com/questions/44195986/uitableview-header-dynamic-height-in-run-time
        commentTableView.sectionHeaderHeight = UITableView.automaticDimension
        commentTableView.estimatedSectionHeaderHeight = 999;
        
        
        let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
        self.sender = appDelegate?.currentSender
        
        
        let database = Firestore.firestore()
        //        database.collection("forumChannels").addDocument(data: ["name" : "."])
        
        if let episode = episode{
            episodeName.text = episode.title
            podcastName.setTitle(episode.podcastName, for: .normal)
            
            
            let channelName = episode.title
            var doesExist = false
            
            database.collection("forumChannels").getDocuments { (querySnapshot, error) in
                if let error = error{
                    return
                }
                if let snapshot = querySnapshot{
                    snapshot.documents.forEach { snapshot in
                        let name = snapshot["name"] as! String
                        if channelName?.lowercased() == name.lowercased(){
                            doesExist = true
                        }
                    }
                    if !doesExist {
                        database.collection("forumChannels").addDocument(data: ["name" : channelName])
                    }
                }
                
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let database = Firestore.firestore()
        channelDatabaseListener = database.collection("forumChannels").addSnapshotListener() { [self]
         (querySnapshot, error) in
            if let error = error {
             print(error)
             return
            }
            childCommentList.removeAll()
            parentCommentList.removeAll()
            querySnapshot?.documents.forEach() { snapshot in
                guard let name  = episode?.title else {return}
                if snapshot["name"] as! String == name{
                    let id = snapshot.documentID
                    let name = snapshot["name"] as! String
                    self.forumChannel = ForumChannel(id: id, name: name)
                    
                    
                    messageDatabaseListener = database.collection("forumChannels").document(id).collection("comments").order(by:"time").addSnapshotListener() {
                        (querySnapshot, error) in
                        if let error = error {
                            print(error)
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
                                    if self.childCommentList[parent] != nil{
                                        self.childCommentList[parent]?.append(comment)
//                                        let a = self.childCommentList[parent]
//                                        a?.append(comment)
                                    }
                                    else{
                                        self.childCommentList[parent] = [comment]
                                    }
                                    
                                }
                                else{
                                    self.parentCommentList.append(comment)
                                }
                                
//                                self.childCommentList.append(comment)
                                self.commentTableView.reloadData()
//                                self.commentTableView.reloadSections(IndexSet(0..<1), with: .automatic)
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        channelDatabaseListener?.remove()
        messageDatabaseListener?.remove()
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Dequeue with the reuse identifier
        let header = self.commentTableView.dequeueReusableHeaderFooterView(withIdentifier: "commentHeader") as! CommentHeader
        
        let comment = parentCommentList[section]
        
        header.username.text = comment.sender.displayName
        header.timestamp.text = dateFormatter(date: comment.sentDate)
//        header.timestamp.text = "\(comment.sentDate)"
        header.comment.text = comment.messageId
        header.comment.text = comment.message
        
        
        
        header.actionBlock = {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let replyViewController = storyBoard.instantiateViewController(withIdentifier: "replyView") as! ReplyViewController
            replyViewController.forumChannel = self.forumChannel
            replyViewController.parentComment = comment
            self.navigationController?.pushViewController(replyViewController, animated: true)
//            self.present(replyViewController, animated:true, completion:nil)
        }
        
        header.collapseBlock = { [self] in
            
            // Add indexPathsForSection method
            let parentComment = parentCommentList[section]
            func indexPathsForSection() -> [IndexPath] {
                var indexPaths = [IndexPath]()
                let c = parentComment.messageId
                let d = self.childCommentList
                let b = d[c]
                let a = b?.count
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
                header.collapse.setTitle("Collapse", for: .normal)
            } else {
                self.hiddenSections.insert(section)
                self.commentTableView.deleteRows(at: indexPathsForSection(),
                                                 with: .fade)
                header.collapse.setTitle("Expand", for: .normal)
            }
        }
        
        
        return header
    }
    
    
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
        return parentCommentList.count
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 100
//    }

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            cell.username.text = comment.sender.displayName
            cell.timestamp.text = dateFormatter(date: comment.sentDate)
//            cell.comment.text = comment.messageId
            cell.comment.text = comment.message
        }
        cell.contentView.backgroundColor = UIColor(named: "forumColor")
        
        return cell
        
        
       
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
