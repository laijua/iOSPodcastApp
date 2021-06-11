//
//  PodcastInfoViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit
import FirebaseFirestore

class PodcastInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //    https://stackoverflow.com/questions/31673607/swift-tableview-in-viewcontroller
    
    @IBOutlet weak var podcastName: UILabel!
    @IBOutlet weak var podcastImage: UIImageView!
    @IBOutlet weak var episodeTable: UITableView!
    @IBOutlet weak var favouriteUIButton: UIButton!
    @IBOutlet weak var podcastDescription: UITextView!
    
    
    
    var podcastID: String?
    var podcast: PodcastData?
    
    private var episodes = [EpisodeData]()
    
    private let database = Firestore.firestore()
    private let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
    private let CELL_EPISODE = "episodeCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let child = addSpin()
        
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
                    let reference = self.database.collection("usernames").document(documentId).collection("favourites")
                    reference.whereField("podcastId", isEqualTo: self.podcastID).getDocuments() { (querySnapshot, err) in
                        if let err = err{
                            return
                        }
                        else{
                            var alreadyFavourited = false
                            var favouritedId: String?
                            // already favourited
                            for document in querySnapshot!.documents {
                                alreadyFavourited = true
                                favouritedId = document.documentID
                                break
                                // if i can loop through document, it means it exists and i can just break
                            }
                            if alreadyFavourited, let favouritedId = favouritedId{
                                self.favouriteUIButton.imageView?.image = UIImage(systemName: "star.fill")
                                
                            }
                            
                        }
                    }
                }
            }
        }
        
        
        if let id = podcastID{
            if let url = URL(string: "https://listen-api.listennotes.com/api/v2/podcasts/\(id)"){
                var request = URLRequest(url: url)
                guard let appDelegate = appDelegate else {return}
                request.addValue(appDelegate.apiKey, forHTTPHeaderField: "X-ListenAPI-Key")
                if request != nil{
                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        if let error = error{
                            return
                        }
                        
                        do{
                            let decoder = JSONDecoder()
                            self.podcast = try decoder.decode(PodcastData.self, from: data!)
                            DispatchQueue.main.async {
                                self.podcastName.text = self.podcast?.title
                                guard let podcastDesc = self.podcast?.podcastDescription else {return}
                                self.podcastDescription.text = podcastDesc.html2String
                                
                                self.removeSpin(child)
                            }
                            
                            
                            if let episodes = self.podcast?.episodes{
                                self.episodes = episodes
                                DispatchQueue.main.async {
                                    self.episodeTable.reloadData()
                                }
                                
                            }
                            
                            if let image = self.podcast?.image{
                                guard let url = URL(string: image)
                                else {return}
                                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                                    if let error = error{
                                        return
                                    }
                                    if let data = data{
                                        DispatchQueue.main.async {
                                            self.podcastImage.image = UIImage(data: data)
                                        }
                                    }
                                }
                                task.resume()
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
        
       
        
        
        //        https://stackoverflow.com/questions/27372595/issues-adding-uitableview-inside-a-uiviewcontroller-in-swift
        //        https://stackoverflow.com/questions/29812168/could-not-cast-value-of-type-uitableviewcell-to-appname-customcellname
        // https://stackoverflow.com/questions/29035876/swift-custom-uitableviewcell-label-is-always-nil
        self.episodeTable.delegate = self
        self.episodeTable.dataSource = self
    }
    
    @IBAction func favouriteButton(_ sender: Any) {
        
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
                    let reference = self.database.collection("usernames").document(documentId).collection("favourites")
                    
                    reference.whereField("podcastId", isEqualTo: self.podcastID).getDocuments() { (querySnapshot, err) in
                        if let err = err{
                            return
                        }
                        else{
                            var alreadyFavourited = false
                            var favouritedId: String?
                            // already favourited
                            for document in querySnapshot!.documents {
                                alreadyFavourited = true
                                favouritedId = document.documentID
                                break
                                // if i can loop through document, it means it exists and i can just break
                            }
                            if alreadyFavourited, let favouritedId = favouritedId{
                                self.favouriteUIButton.imageView?.image = UIImage(systemName: "star")
                                // https://stackoverflow.com/questions/57943765/swift-firestore-delete-document
                                reference.document(favouritedId).delete()
                            }
                            else{
                                reference.addDocument(data: ["podcastId" : self.podcastID])
                                self.favouriteUIButton.imageView?.image = UIImage(systemName: "star.fill")
                            }
                            
                        }
                    }
                }
            }
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_EPISODE, for: indexPath) as! EpisodeTableViewCell
        let episode = episodes[indexPath.row]
        cell.episodeTitle.text = episode.title
        cell.dateOfUpload.text = episode.episodeDate
        cell.episodeLength.text = episode.episodeLength
        
        if let image = episode.image, let url = URL(string: image){
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error{
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
        
        
        cell.forumBlock = {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let forumViewController = storyboard.instantiateViewController(identifier: "ForumViewController") as! ForumViewController
            forumViewController.episode = episode
            forumViewController.hidePodcastName = true
            self.navigationController?.pushViewController(forumViewController, animated: true)
        }
        cell.playlistBlock = playlistButtonInitialisation(episode)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        performSegue(withIdentifier: "episodeSegue", sender: nil)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "episodeSegue"{
            let destination = segue.destination as! EpisodeInfoViewController
            if let index = episodeTable.indexPathForSelectedRow?.row{
                destination.episode = episodes[index]
                destination.episode?.podcastID = self.podcast?.id
                destination.hidePodcastName = true
                
            }
        }
    }
    
    
}

