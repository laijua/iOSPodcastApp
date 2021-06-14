//
//  HomeTableViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class HomeTableViewController: UITableViewController {
    
    private var favouritePodcastDatabaseListener: ListenerRegistration?
    private let database = Firestore.firestore()
    private let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
    
    private var idOfPodcastFollowed = [String]()
    private var episodes = [EpisodeData]()
    
    private let EPISODE_CELL = "episodeCell"
    private let NOTHING_CELL = "noPodcastFollowedCell"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 999
        tableView.rowHeight = UITableView.automaticDimension
        
        // make bar items black
        let BarButtonItemAppearance = UIBarButtonItem.appearance()
        let attributes = [NSAttributedString.Key.font:  UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body), NSAttributedString.Key.foregroundColor: UIColor.label]
        BarButtonItemAppearance.setTitleTextAttributes(attributes, for: .normal)
        BarButtonItemAppearance.setTitleTextAttributes(attributes, for: .highlighted)
        
        navigationController?.navigationBar.barTintColor = UIColor(named: "Teal")
        tabBarController?.tabBar.barTintColor = UIColor(named: "Teal")
   
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let child = addSpin()
        // add listener that listens for podcast follow/unfollows and updates episode feeds accordingly
        guard let id = appDelegate?.currentSender?.senderId else{return}
        database.collection("usernames").whereField("id", isEqualTo: id).getDocuments { (querySnapshot, error) in
            if let _ = error{
                return
            }
            else{
                var tempDocumentId: String?
                if let snapshot = querySnapshot{
                    snapshot.documents.forEach { (document) in
                        tempDocumentId = document.documentID
                    }
                }
                // find id of current user
                guard let documentId = tempDocumentId else {return}
                
                
                // add listeners
                self.favouritePodcastDatabaseListener = self.database.collection("usernames").document(documentId).collection("favourites").addSnapshotListener() {
                    (querySnapshot, error) in
                    if let _ = error {
                        return
                    }
                    guard let snapshot = querySnapshot else {
                        return
                    }
                    self.episodes.removeAll()
                    snapshot.documentChanges.forEach { (diff) in
                        if (diff.type == .added) {
                            let newIndex = Int(diff.newIndex)
                            let added = diff.document.data()["podcastId"] as! String
                            self.idOfPodcastFollowed.insert(added, at: newIndex)
                            
                        }
                        if (diff.type == .removed) {
                            let oldIndex = Int(diff.oldIndex)
                            self.idOfPodcastFollowed.remove(at: oldIndex)
                            self.tableView.reloadData()
                        }
                    }
                    self.removeSpin(child)
                    self.requestEpisodes()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        favouritePodcastDatabaseListener?.remove()
        episodes.removeAll()
        idOfPodcastFollowed.removeAll()
        tableView.reloadData()
    }
    
    
    private func requestEpisodes(){
        let child = addSpin()
        if idOfPodcastFollowed.count == 0{
            removeSpin(child)
        }
        
        
        for id in idOfPodcastFollowed{
            if let url = URL(string: "https://listen-api.listennotes.com/api/v2/podcasts/\(id)"){
                var request = URLRequest(url: url)
                    guard let appDelegate = appDelegate else {return}
                    request.addValue(appDelegate.apiKey, forHTTPHeaderField: "X-ListenAPI-Key")
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let _ = error{
                        return
                    }
                    do{
                        let decoder = JSONDecoder()
                        let podcast = try decoder.decode(PodcastData.self, from: data!)
                        
                        if let episodes = podcast.episodes{
                            episodes.forEach({episode in
                                episode.podcastName = podcast.title
                                episode.podcastID = id
                            })
                            self.episodes.append(contentsOf: episodes)
                            // https://stackoverflow.com/questions/24130026/swift-how-to-sort-array-of-custom-objects-by-property-value
                            self.episodes = self.episodes.sorted(by: {$0.ms ?? 0 > $1.ms ?? 0})

                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.removeSpin(child)
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
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Latest from podcasts you follow"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if idOfPodcastFollowed.count == 0{
            return 1
        }
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // if no podcasts followed, display message
        if idOfPodcastFollowed.count == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: NOTHING_CELL, for: indexPath) as! EmptyEpisodesTableViewCell
            
            cell.noEpisodesText.text = "No podcasts have been favourited yet. \n \n Tap Below to search for podcasts."

            cell.searchBlock = {
                self.tabBarController?.selectedIndex = 1
            }
            cell.searchUIButton.layer.cornerRadius = 10
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EPISODE_CELL, for: indexPath) as! EpisodeTableViewCell
        let episode = episodes[indexPath.row]
        
        
        if let image = episode.image, let url = URL(string: image){
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let _ = error{
                    return
                }
                if let data = data{
                    DispatchQueue.main.async {
                        cell.episodeImage?.image = UIImage(data: data)
                        
                    }
                }
            }
            task.resume()
        }
        
        cell.episodeTitle.text = episode.title
        
        cell.podcastName.text = episode.podcastName
        
        cell.dateOfUpload.text = episode.episodeDate
        cell.episodeLength.text = episode.episodeLength

        cell.forumBlock = {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let forumViewController = storyboard.instantiateViewController(identifier: "ForumViewController") as! ForumViewController
            forumViewController.episode = episode
            self.navigationController?.pushViewController(forumViewController, animated: true)
        }
        
        cell.playlistBlock = playlistButtonInitialisation(episode)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "episodeSegue", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if idOfPodcastFollowed.count == 0{
            return nil
        }
        return indexPath
    }
  
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "episodeSegue"{
            let destination = segue.destination as! EpisodeInfoViewController
            if let index = tableView.indexPathForSelectedRow?.row{
                destination.episode  = episodes[index]
                
            }
            
        }
    }
    

}
