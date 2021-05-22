//
//  ChatListTableViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 9/5/21.
//

import UIKit
import FirebaseFirestore

// same as ChannelsTableViewController
class ChatListTableViewController: UITableViewController {
    let SEGUE_MESSAGE = "messageSegue"
    let CELL_CHAT = "chatCell"
    
    var currentSender: Sender?
    var channels = [Channel]()
    
    var channelsRef: CollectionReference?
    var databaseListener: ListenerRegistration?
    
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
        databaseListener = channelsRef?.addSnapshotListener() {
         (querySnapshot, error) in
            if let error = error {
             print(error)
             return
            }
            self.channels.removeAll()
            querySnapshot?.documents.forEach() { snapshot in
                // if statement here to show user's chat???????
                let id = snapshot.documentID
                let name = snapshot["name"] as! String
                let channel = Channel(id: id, name: name)
                
                self.channels.append(channel)
            }
            self.tableView.reloadData()
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseListener?.remove()
    }
    
    
    
    @IBAction func addChat(_ sender: Any) {
        let alertController = UIAlertController(title: "Add New Channel",
                                                message: "Enter channel name below", preferredStyle: .alert)
        alertController.addTextField()
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Create", style: .default) { _ in
            let channelName = alertController.textFields![0]
            var doesExist = false
            
            for channel in self.channels {
                if channel.name.lowercased() == channelName.text!.lowercased() {
                    doesExist = true
                }
            }
            if !doesExist {
                self.channelsRef?.addDocument(data: ["name" : channelName.text!])
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        self.present(alertController, animated: false, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return channels.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_CHAT, for: indexPath) as! ChatListTableViewCell
        
        let channel = channels[indexPath.row]
        
        
        cell.profileName.text = channel.name
        cell.messagePreview.text = "Good Boy"
        cell.timestamp.text = "11:46"
        cell.profileImage.image = UIImage(named: "dog")
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channels[indexPath.row]
        performSegue(withIdentifier: SEGUE_MESSAGE, sender: channel)
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
