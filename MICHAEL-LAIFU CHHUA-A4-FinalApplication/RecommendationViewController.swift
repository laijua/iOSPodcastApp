//
//  RecommendationViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 8/5/21.
//

import UIKit
import FirebaseFirestore

// https://www.youtube.com/watch?v=hV1DqMpQG7A
class RecommendationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    private var searchResult:String?
    
    private let MAX_ITEMS_PER_REQUEST = 20
    private let MAX_REQUESTS = 10
    private var currentRequestIndex: Int = 0
    
    private let RECOMMEND_CELL  = "recommendCell"
    
    private let TOP_CELL = "topPodcastCell"
    
    private var topPodcasts = [PodcastData]()
    private var recommendedPodcasts = [PodcastData]()
    private let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
    private let database = Firestore.firestore()
    
    @IBOutlet weak var recommendCollectionView: UICollectionView!
    
    @IBOutlet weak var topPodcastsCollectionView: UICollectionView!
    
    private var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(named: "Teal")
        
        
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        
        // data for top podcasts
        if let url = URL(string: "https://listen-api-test.listennotes.com/api/v2/best_podcasts?genre_id=93&page=2&region=us&safe_mode=0"){
            var request = URLRequest(url: url)
            guard let appDelegate = appDelegate else {return}
            request.addValue(appDelegate.apiKey, forHTTPHeaderField: "X-ListenAPI-Key")
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let _ = error{
                    return
                }
                do{
                    let decoder = JSONDecoder()
                    let podcasts = try decoder.decode(ListOfPodcastData.self, from: data!)
                    if let podcasts = podcasts.podcasts{
                        self.topPodcasts = podcasts
                        DispatchQueue.main.async {
                            self.topPodcastsCollectionView.reloadData()
                        }
                        
                    }
                    
                }
                catch let err{
                    return
                }
                
            }
            task.resume()
        }
        
        
        // data for recommended podcasts
        // recommended podcast will update next time user logs into app, rather than changing in real time when they favourite a podcast
        database.collection("usernames").whereField("id", isEqualTo: appDelegate?.currentSender?.senderId).getDocuments { (querySnapshot, error) in
            if let _ = error{
                return
            }
            var tempDocumentId: String?
            querySnapshot?.documents.forEach{ (snapshot) in
                tempDocumentId = snapshot.documentID
            }
            guard let documentId = tempDocumentId else {return}
            
            self.database.collection("usernames").document(documentId).collection("favourites").getDocuments { (querySnapshot, error) in
                if let _ = error{
                    return
                }
                var tempPodcastId: String?
                for document in querySnapshot!.documents{
                    tempPodcastId = document["podcastId"] as! String
                    break // just getting the first podcast id that appears
                }
                
                if tempPodcastId == nil{
                    tempPodcastId = "5de9e82f0d8a4c1f889a599e32694ae1" // some default value if no podcats followed
                }
                
                guard let podcastId = tempPodcastId else {return}
                
                
                if let url = URL(string: "https://listen-api.listennotes.com/api/v2/podcasts/\(podcastId)/recommendations?safe_mode=0"){
                    var request = URLRequest(url: url)
                    guard let appDelegate = self.appDelegate else {return}
                    request.addValue(appDelegate.apiKey, forHTTPHeaderField: "X-ListenAPI-Key")
                    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                        if let _ = error{
                            return
                        }
                        do{
                            let decoder = JSONDecoder()
                            let podcasts = try decoder.decode(ListOfPodcastData.self, from: data!)
                            if let podcasts = podcasts.podcasts{
                                self.recommendedPodcasts = podcasts
                                DispatchQueue.main.async {
                                    self.recommendCollectionView.reloadData()
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
        
  
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.searchBar.text = nil
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // https://stackoverflow.com/questions/55600639/find-which-tab-bar-item-is-selected
        // reason for doing this is because if i enter a text into the search bar and then move to a different tab controller, this function gets called for some reason
        if tabBarController?.selectedIndex == 1{
            guard let searchText = searchBar.text, searchText.count > 0 else {return}
            searchResult = searchText
            URLSession.shared.invalidateAndCancel()
            performSegue(withIdentifier: "searchSegue", sender: nil)
           
        }
        
        
    }
    
    // MARK: - Collection view data source
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topPodcastsCollectionView{
            return topPodcasts.count
        }
        return recommendedPodcasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == recommendCollectionView{
            let cell = recommendCollectionView.dequeueReusableCell(withReuseIdentifier: RECOMMEND_CELL, for: indexPath) as! PodcastCollectionViewCell
        
            
            let podcast = recommendedPodcasts[indexPath.row]
            cell.podcastName?.text = podcast.title
            
            if let image = podcast.image, let url = URL(string: image){
                
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let _ = error{
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
        
        
        let cell = topPodcastsCollectionView.dequeueReusableCell(withReuseIdentifier: TOP_CELL, for: indexPath) as! PodcastCollectionViewCell
        let podcast = topPodcasts[indexPath.row]
        cell.podcastName?.text = podcast.title
        
        if let image = podcast.image, let url = URL(string: image){
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let _ = error{
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
        if collectionView == topPodcastsCollectionView{
            performSegue(withIdentifier: "podcastSegue", sender: topPodcasts[indexPath.row])
        }
        else{
            performSegue(withIdentifier: "podcastSegue", sender: recommendedPodcasts[indexPath.row])
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchSegue"{
            let destination = segue.destination as! SearchTableViewController
            destination.searchResult = searchResult
        }
        
        if segue.identifier == "podcastSegue"{
            let podcast = sender as! PodcastData
            let destination = segue.destination as! PodcastInfoViewController
            destination.podcast = podcast
            destination.podcastID = podcast.id
            
        }
    }
    
}
