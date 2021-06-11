//
//  AccountViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 9/5/21.
//

import UIKit
import FirebaseFirestore

class AccountViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, TabBarSwitchDelegate {
    
    @IBOutlet weak var searchUIBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var favouritePodcastsCollectionView: UICollectionView!
    @IBOutlet weak var followCollectionView: UICollectionView!
    @IBOutlet weak var messageUIButton: UIButton!
    @IBOutlet weak var followUIButton: UIButton!
    
    private var following = [String]()
    private var favouritePodcasts = [PodcastData?]()
    private let FAVOURITE_CELL = "favouriteCell"
    private let FOLLOW_CELL =  "followCell"
    
    private var favouritePodcastDatabaseListener: ListenerRegistration?
    private var followDatabaseListener: ListenerRegistration?
    
    var tabBarSwitchDelegate: TabBarSwitchDelegate?
    var usernameOfAnother: String?
    var idOfAnother: String?
    var favouritePodcastsIds = [String]()
    
    private let database = Firestore.firestore()
    private let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(named: "Teal")
        messageUIButton.layer.cornerRadius = 10
        followUIButton.layer.cornerRadius = 10
        
        let currentUserId = appDelegate?.currentSender?.senderId
        
        // check if profile current user is on is followed or not
        database.collection("usernames").whereField("id", isEqualTo: currentUserId).getDocuments() { (querySnapshot, err) in
            if let err = err{
                return
            }
            else{
                var documentId: String?
                for document in querySnapshot!.documents {
                    documentId = document.documentID
                    break
                    // if i can loop through document, it means it exists and i can just break
                }
                
                if let documentId = documentId{
                    let reference = self.database.collection("usernames").document(documentId).collection("following")
                    reference.whereField("name", isEqualTo: self.usernameOfAnother).getDocuments() { (querySnapshot, err) in
                        if let err = err{
                            return
                        }
                        else{
                            var alreadyFollowed = false
                            var followId: String?
                            // already followed
                            for document in querySnapshot!.documents {
                                alreadyFollowed = true
                                followId = document.documentID
                                break
                                // if i can loop through document, it means it exists and i can just break
                            }
                            if alreadyFollowed{
                                let image = UIImage(systemName: "person.fill.checkmark")
                                self.followUIButton.setImage(image, for: .normal)
                                
                            }
                            
                        }
                    }
                }
            }
        }
        
        
        // if on another user's profile
        if let usernameOfAnother = usernameOfAnother, usernameOfAnother != appDelegate?.currentSender?.displayName{
            username.text = usernameOfAnother
        }
        else{
            messageUIButton.isHidden = true
            followUIButton.isHidden = true
            username.text = appDelegate?.currentSender?.displayName
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let username = username.text else {return}
        database.collection("usernames").whereField("username", isEqualTo: username).getDocuments { (querySnapshot, error) in
            if let error = error{
                return
            }
            else{
                var tempDocumentId: String?
                if let snapshot = querySnapshot{
                    snapshot.documents.forEach { (document) in
                        tempDocumentId = document.documentID
                    }
                }
                guard let documentId = tempDocumentId else {return}
                
                // add listeners
                self.favouritePodcastDatabaseListener = self.database.collection("usernames").document(documentId).collection("favourites").addSnapshotListener() {
                    (querySnapshot, error) in
                    if let error = error {
                        return
                    }
                    guard let snapshot = querySnapshot else {
                        return
                    }
                    //https://firebase.google.com/docs/firestore/query-data/listen
                    snapshot.documentChanges.forEach { diff in
                        if (diff.type == .added) {
                            let newIndex = Int(diff.newIndex)
                            let added = diff.document.data()["podcastId"] as! String
                            self.favouritePodcastsIds.insert(added, at: newIndex)
                            self.favouritePodcasts.insert(nil, at: newIndex)
                            self.requestPodcastAt(newIndex)
                        }
                        if (diff.type == .removed) {
                            let oldIndex = Int(diff.oldIndex)
                            self.favouritePodcasts.remove(at: oldIndex)
                            self.favouritePodcastsIds.remove(at: oldIndex)
                            self.favouritePodcastsCollectionView.reloadData()
                        }
                    }
                }
                
                
                self.followDatabaseListener = self.database.collection("usernames").document(documentId).collection("following").addSnapshotListener() {
                    (querySnapshot, error) in
                    if let error = error {
                        return
                    }
                    guard let snapshot = querySnapshot else {
                        return
                    }
                    //https://firebase.google.com/docs/firestore/query-data/listen
                    snapshot.documentChanges.forEach { diff in
                        if (diff.type == .added) {
                            let newIndex = Int(diff.newIndex)
                            let added = diff.document.data()["name"] as! String
                            self.following.insert(added, at: newIndex)
                            self.followCollectionView.reloadData()
                        }
                        if (diff.type == .removed) {
                            let oldIndex = Int(diff.oldIndex)
                            self.following.remove(at: oldIndex)
                            self.followCollectionView.reloadData()
                        }
                    }
                }
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        followDatabaseListener?.remove()
        favouritePodcastDatabaseListener?.remove()
        following.removeAll()
        favouritePodcasts.removeAll()
        favouritePodcastsIds.removeAll()
    }
    
    @IBAction func message(_ sender: Any) {
        var doesExist = false
        guard let currentUsername = appDelegate?.currentSender?.displayName else{return}
        guard let usernameOfAnother = usernameOfAnother else{return}
        // room names in firebase are named in the format "a,b" or "b,a" depending on who messages who first. a and b are names of users
        let roomName = "\(currentUsername),\(usernameOfAnother)"
        let alternativeRoomName = "\(usernameOfAnother),\(currentUsername)"
        // due to limitation of firebase, cant arrayContains twice, so going to check if chat room name exists instead
        
        // commented out code below to demonstrate what i wanted to do, but cant cause firebase limitations. Solution was to do a,b and b,a room name instead
        //        database.collection("channels").whereField("senders", arrayContains: idOfAnother).whereField("senders", arrayContains: appDelegate?.currentSender?.senderId)
        
        
        database.collection("channels").whereField("name", isEqualTo: roomName).getDocuments { (querySnapshot, error) in
            if let error = error{
                return
            }
            var documentId: String?
            var name: String?
            var senders: [String]?
            if let snapshot = querySnapshot{
                snapshot.documents.forEach { (snapshot) in
                    doesExist = true
                    documentId = snapshot.documentID
                    name = snapshot["name"] as! String
                    senders = snapshot["senders"] as! [String]
                }
                
                // the if else statements below is going to check if room exists already, else create it and switch views to it
                if !doesExist{
                    self.database.collection("channels").whereField("name", isEqualTo: alternativeRoomName).getDocuments { (querySnapshot, error) in
                        if let error = error{
                            return
                        }
                      
                        if let snapshot = querySnapshot{
                            snapshot.documents.forEach { (snapshot) in
                                doesExist = true
                                documentId = snapshot.documentID
                                name = snapshot["name"] as! String
                                senders = snapshot["senders"] as! [String]
                            }
                        }
                        if !doesExist{
                            guard let currentSender = self.appDelegate?.currentSender else{return}
                            let senderId = currentSender.senderId
                            guard let idOfAnother = self.idOfAnother else {return}
                            let senders = [senderId, idOfAnother]
                            let ref =
                                self.database.collection("channels").addDocument(data: ["name" : roomName,
                                                                                        "senders": senders])
                            
                            let documentId = ref.documentID
                            let channel = Channel(id: documentId, name: roomName, senders: senders)
                            self.dismiss(animated: true, completion: nil)
                            self.tabBarSwitchDelegate?.switchTab(4, currentSender, channel)
                            
                            
                        }
                        else{
                            guard let documentId = documentId else{return}
                            guard let name = name else{return}
                            guard let senders = senders else {return}
                            guard let currentSender = self.appDelegate?.currentSender else{return}
                            
                            let channel = Channel(id: documentId, name: name, senders: senders)
                            self.dismiss(animated: true, completion: nil)
                            self.tabBarSwitchDelegate?.switchTab(4, currentSender, channel)
                            
                        }
                    }
                }
                else{
                    guard let documentId = documentId else{return}
                    guard let name = name else{return}
                    guard let senders = senders else {return}
                    guard let currentSender = self.appDelegate?.currentSender else{return}
                    
                    let channel = Channel(id: documentId, name: name, senders: senders)
                    self.dismiss(animated: true, completion: nil)
                        self.tabBarSwitchDelegate?.switchTab(4, currentSender, channel)

                }
            }
        }
    }
    
    @IBAction func follow(_ sender: Any)  {
        
        let currentUserId = appDelegate?.currentSender?.senderId
        
        var documentId: String?
        database.collection("usernames").whereField("id", isEqualTo: currentUserId).getDocuments() { (querySnapshot, err) in
            if let err = err{
                return
            }
            else{
                for document in querySnapshot!.documents {
                    documentId = document.documentID
                    break
                    // if i can loop through document, it means it exists and i can just break
                }
                
                if let documentId = documentId{
                    let reference = self.database.collection("usernames").document(documentId).collection("following")
                    reference.whereField("name", isEqualTo: self.usernameOfAnother).getDocuments() { (querySnapshot, err) in
                        if let err = err{
                            return
                        }
                        else{
                            var alreadyFollowed = false
                            var followId: String?
                            // check if already followed
                            for document in querySnapshot!.documents {
                                alreadyFollowed = true
                                followId = document.documentID
                                break
                                // if i can loop through document, it means it exists and i can just break
                            }
                            if alreadyFollowed, let followId = followId{
                                
                                let image = UIImage(systemName: "person.fill.badge.plus")
                                self.followUIButton.setImage(image, for: .normal)
                                // https://stackoverflow.com/questions/57943765/swift-firestore-delete-document
                                reference.document(followId).delete()
                            }
                            else{
                                reference.addDocument(data: ["name" : self.usernameOfAnother])
                                
                                let image = UIImage(systemName: "person.fill.checkmark")
                                self.followUIButton.setImage(image, for: .normal)
                            }
                            
                        }
                    }
                }
            }
        }
        
    }
    
    
    
   
    
    func requestPodcastAt(_ index: Int){
        
        let podcastId = favouritePodcastsIds[index]
        
        
        if let url = URL(string: "https://listen-api.listennotes.com/api/v2/podcasts/\(podcastId)?next_episode_pub_date=1479154463000"){
            var request = URLRequest(url: url)
            guard let appDelegate = appDelegate else {return}
            request.addValue(appDelegate.apiKey, forHTTPHeaderField: "X-ListenAPI-Key")
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error{
                    return
                }
                do{
                    let decoder = JSONDecoder()
                    let podcast = try decoder.decode(PodcastData.self, from: data!)
                    // quick fix for when user switch between this view and another view back and forth really quickly and this task is still happening. in viewWillDisappear I empty the array and if array is empty in this execution, it means this view is in the background.
                    if self.favouritePodcasts.count != 0{
                        self.favouritePodcasts[index] = podcast
                        DispatchQueue.main.async {
                            self.favouritePodcastsCollectionView.reloadData()
                        }
                    }
                }
                catch let err{
                    return
                }
                
            }
            task.resume()
        }
        
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
    
    
    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == followCollectionView{
            return following.count
        }
        return favouritePodcasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView == followCollectionView{
            let cell = followCollectionView.dequeueReusableCell(withReuseIdentifier: FOLLOW_CELL, for: indexPath) as! FollowCollectionViewCell
            let username = following[indexPath.row]
            cell.username.text = username
            return cell
        }
        
        
        
        let cell = favouritePodcastsCollectionView.dequeueReusableCell(withReuseIdentifier: FAVOURITE_CELL, for: indexPath) as! PodcastCollectionViewCell
        let podcast = favouritePodcasts[indexPath.row] 
        cell.podcastName?.text = podcast?.title
        
        if let image = podcast?.image, let url = URL(string: image){
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error{
                    return
                }
                if let data = data{
                    DispatchQueue.main.async {
                        cell.podcastImage?.image = UIImage(data: data)
                        
                    }
                }
            }
            task.resume()
        }
        
        cell.podcastImage.layer.cornerRadius = 10
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if collectionView == followCollectionView{
            let profile = following[indexPath.row]
            usernameTapped(profile, self, true)()
        }
        
        if collectionView == favouritePodcastsCollectionView{
            let podcastId = favouritePodcastsIds[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let podcastInfoViewController = storyboard.instantiateViewController(identifier: "PodcastViewController") as! PodcastInfoViewController
            podcastInfoViewController.podcastID = podcastId
            self.navigationController?.pushViewController(podcastInfoViewController, animated: true)
            
            
        }
    }
    
}
