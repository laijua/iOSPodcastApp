//
//  RecommendationViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 8/5/21.
//

import UIKit
// https://www.youtube.com/watch?v=hV1DqMpQG7A
class RecommendationViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    var searchResult:String?
    
    let MAX_ITEMS_PER_REQUEST = 20
    let MAX_REQUESTS = 10
    var currentRequestIndex: Int = 0
    
    let RECOMMEND_CELL  = "recommendCell"
    let TRENDING_CELL = "trendingCell"
    let TOP_CELL = "topPodcastCell"
    
    var topPodcasts = [PodcastData]()
    
    
    
    @IBOutlet weak var recommendCollectionView: UICollectionView!
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    @IBOutlet weak var topPodcastsCollectionView: UICollectionView!
    
    var searchController = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(named: "Teal")
        
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        if let url = URL(string: "https://listen-api-test.listennotes.com/api/v2/best_podcasts?genre_id=93&page=2&region=us&safe_mode=0"){
            var request = URLRequest(url: url)
            //                request.addValue("c975de1e599a46a6889c7e7006a493eb", forHTTPHeaderField: "X-ListenAPI-Key")
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error{
                    print(error)
                    print("lol")
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
                    print(err)
                }
                
            }
            task.resume()
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
        
        guard let searchText = searchBar.text, searchText.count > 0 else {return}
        searchResult = searchText
        URLSession.shared.invalidateAndCancel()
        performSegue(withIdentifier: "searchSegue", sender: nil)
//        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "searchTableView") as! SearchTableViewController
//        nextViewController.searchResult = searchText
//        self.present(nextViewController, animated:true, completion:nil)
    }
    
    
    // MARK: - Collection view data source
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == topPodcastsCollectionView{
            return topPodcasts.count
        }
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == recommendCollectionView{
            let cell = recommendCollectionView.dequeueReusableCell(withReuseIdentifier: RECOMMEND_CELL, for: indexPath) as! PodcastCollectionViewCell
            cell.podcastImage?.image = UIImage(named: "dog")
            cell.podcastName?.text = "Mac"
            return cell
        }
        if collectionView == trendingCollectionView{
            let cell = trendingCollectionView.dequeueReusableCell(withReuseIdentifier: TRENDING_CELL, for: indexPath) as! PodcastCollectionViewCell
            cell.podcastImage?.image = UIImage(named: "dog")
            cell.podcastName?.text = "is"
            return cell
        }
        
        let cell = topPodcastsCollectionView.dequeueReusableCell(withReuseIdentifier: TOP_CELL, for: indexPath) as! PodcastCollectionViewCell
        let podcast = topPodcasts[indexPath.row]
        cell.podcastName?.text = podcast.title
        
        if let image = podcast.image, let url = URL(string: image){
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error{
                    print(error)
                }
                if let data = data{
                    DispatchQueue.main.async {
                        cell.podcastImage?.image = UIImage(data: data)
                        
                    }
                }
            }
            task.resume()
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == topPodcastsCollectionView{
            performSegue(withIdentifier: "podcastSegue", sender: nil)
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
            if let paths = topPodcastsCollectionView.indexPathsForSelectedItems{
                let podcast = topPodcasts[paths[0].row]
                let destination = segue.destination as! PodcastInfoViewController
                destination.podcast = podcast
                destination.podcastID = podcast.id
            }
            
        }
     }
     
}
