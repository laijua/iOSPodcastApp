//
//  AccountViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 9/5/21.
//

import UIKit

class AccountViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var favouritePodcastsCollectionView: UICollectionView!
    var favouritePodcasts = [PodcastData]()
    let FAVOURITE_CELL = "favouriteCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
        
        
        username.text = appDelegate?.currentSender?.displayName

        navigationController?.navigationBar.barTintColor = UIColor(named: "Teal")
        
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
                        self.favouritePodcasts = podcasts
                        DispatchQueue.main.async {
                            self.favouritePodcastsCollectionView.reloadData()
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
        let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
        let display = appDelegate?.currentSender?.displayName
        
        username.text = appDelegate?.currentSender?.displayName
    }
    
    // MARK: - Collection view data source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favouritePodcasts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = favouritePodcastsCollectionView.dequeueReusableCell(withReuseIdentifier: FAVOURITE_CELL, for: indexPath) as! PodcastCollectionViewCell
        let podcast = favouritePodcasts[indexPath.row]
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
