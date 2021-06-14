//
//  ChatListTableViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 9/5/21.
//

import UIKit
import FirebaseFirestore

// similar to ChannelsTableViewController from the labs
class ChatListTableViewController: UITableViewController {
    private let SEGUE_MESSAGE = "messageSegue"
    private let CELL_CHAT = "chatCell"
    private let CELL_EMPTY = "emptyChatCell"
    
    var currentSender: Sender?
    private var channels = [Channel]()
    
    private var channelsRef: CollectionReference?
    private var databaseListener: ListenerRegistration?
    
    @IBOutlet weak var editUIBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(named: "Teal")
        let database = Firestore.firestore()
        channelsRef = database.collection("channels")
        
        let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
        currentSender = appDelegate?.currentSender
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        // add listener for chat channels
        databaseListener = channelsRef?.addSnapshotListener() {
         (querySnapshot, error) in
            if let _ = error {
             return
            }
            self.channels.removeAll()
            let child = self.addSpin()
            guard let senderId = self.currentSender?.senderId else {return}
            // filter chat channels that dont include the current user as a sender
            self.channelsRef?.whereField("senders", arrayContains: senderId).getDocuments() { (querySnapshot, err) in
                if let err = err{
                    return
                }
                else{
                    for document in querySnapshot!.documents {
                        let id = document.documentID
                        let name = document["name"] as! String
                        let senders = document["senders"] as! [String]
                        let channel = Channel(id: id, name: name, senders: senders)

                        self.channels.append(channel)
                    }
                    self.tableView.reloadData()
                    self.removeSpin(child)
                }
            }


            self.tableView.reloadData()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseListener?.remove()
        tableView.setEditing(false, animated: false);
        editUIBarButtonItem.style = UIBarButtonItem.Style.plain;
        editUIBarButtonItem.title = "Edit";
    }
    
    //    https://stackoverflow.com/questions/24772457/swift-reorder-uitableview-cells
    @IBAction func editTableView (sender:UIBarButtonItem)
    // enable/disable editting
    {
        if tableView.isEditing{
            tableView.setEditing(false, animated: true);
            editUIBarButtonItem.style = UIBarButtonItem.Style.plain;
            editUIBarButtonItem.title = "Edit";
        }
        else{
            tableView.setEditing(true, animated: true);
            editUIBarButtonItem.title = "Done";
            editUIBarButtonItem.style =  UIBarButtonItem.Style.done;
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if channels.count == 0{
            return 1
        }
        return channels.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // display message if no chat channels open
        if channels.count == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_EMPTY, for: indexPath)
            cell.textLabel?.text = "Message Friends Here."
            cell.detailTextLabel?.text = "Send private messages with friends."
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_CHAT, for: indexPath) as! ChatListTableViewCell
        
        let channel = channels[indexPath.row]
        
        let currentSenderName = currentSender?.displayName
        let name = channel.name
//        https://stackoverflow.com/questions/42137285/split-string-into-substring-with-component-separated-by-string-swift
        // room names in firebase are named in the format "a,b" or "b,a" depending on who messages who first. a and b are names of users. split the two names and name the room after the other user.
        let array = name.components(separatedBy: ",")
        var recipientName: String?
        for n in array{
            if n != currentSenderName{
                recipientName = n
            }
        }
        cell.profileName.text = recipientName
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        // make cell not selectable if there is no chats
        if channels.count == 0{
            return nil
        }
        return indexPath
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channels[indexPath.row]
        performSegue(withIdentifier: SEGUE_MESSAGE, sender: channel)
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if channels.count > 0 {
            return true
        }
        return false
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && channels.count > 0 {

            let channel = channels[indexPath.row]
            let database = Firestore.firestore()
            database.collection("channels").document(channel.id).delete()
            channels.remove(at: indexPath.row)
            
            if channels.count == 0{
                tableView.setEditing(false, animated: false);
                editUIBarButtonItem.style = UIBarButtonItem.Style.plain;
                editUIBarButtonItem.title = "Edit";
            }
            
        }
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == SEGUE_MESSAGE {
            let channel = sender as! Channel
            let destinationVC = segue.destination as!
                ChatMessagesViewController
            
            destinationVC.sender = currentSender
            destinationVC.currentChannel = channel
        }
     }
     
    
}
