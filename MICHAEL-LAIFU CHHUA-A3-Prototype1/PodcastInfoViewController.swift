//
//  PodcastInfoViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit

class PodcastInfoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //    https://stackoverflow.com/questions/31673607/swift-tableview-in-viewcontroller
    
    @IBOutlet weak var podcastName: UILabel!
    @IBOutlet weak var podcastImage: UIImageView!
    
    @IBOutlet weak var podcastDescription: UITextView!
    
    
    
    var podcastID: String?
    var podcast: PodcastData?
    
    var episodes = [EpisodeData]()
    
    
    @IBOutlet weak var episodeTable: UITableView!
    let CELL_EPISODE = "episodeCell"
    
    
    @IBAction func favouriteButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let id = podcastID{
            print(id)
            if let url = URL(string: "https://listen-api-test.listennotes.com/api/v2/podcasts/4d3fe717742d4963a85562e9f84d8c79?next_episode_pub_date=1479154463000&sort=recent_first"){
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let error = error{
                        print(error)
                    }
                    
                    do{
                        let decoder = JSONDecoder()
                        self.podcast = try decoder.decode(PodcastData.self, from: data!)
                        DispatchQueue.main.async {
                            self.podcastName.text = self.podcast?.title
                            self.podcastDescription.text = self.podcast?.podcastDescription
//                            self.podcastDescription.text = "self.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptionself.podcast?.podcastDescriptions"
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
                                    print(error)
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
                        print(err)
                    }
                    
                }
                task.resume()
            }
        }
        
//        if let podcast = podcast, let image = podcast.image{
//            guard let url = URL(string:image)
//            else{return}
//            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//                if let error = error{
//                    print(error)
//                }
//                if let data = data{
//                    DispatchQueue.main.async {
//                        self.podcastImage.image = UIImage(data: data)
//                    }
//                    
//                }
//            }
//            task.resume()
//        }
        
        
        //        if let podcast = podcast, let name = podcast.title, let image = podcast.image, let podcastDescription = podcast.podcastDescription{
        //            podcastName.text = name
        //            self.podcastDescription.text = podcastDescription
        //            print(podcastDescription)
        //
        //            guard let url = URL(string:image)
        //            else{return}
        //            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        //                if let error = error{
        //                    print(error)
        //                }
        //                if let data = data{
        //                    DispatchQueue.main.async {
        //                        self.podcastImage.image = UIImage(data: data)
        //                    }
        //
        //                }
        //            }
        //            task.resume()
        //        }
        
        
        //        https://stackoverflow.com/questions/27372595/issues-adding-uitableview-inside-a-uiviewcontroller-in-swift
        //        https://stackoverflow.com/questions/29812168/could-not-cast-value-of-type-uitableviewcell-to-appname-customcellname
//        self.episodeTable.register(EpisodeTableViewCell.self,forCellReuseIdentifier: CELL_EPISODE)
        // https://stackoverflow.com/questions/29035876/swift-custom-uitableviewcell-label-is-always-nil
        self.episodeTable.delegate = self
        self.episodeTable.dataSource = self
        
        // Do any additional setup after loading the view.
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
            print("IMAGGE \(episode.image)")
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error{
                    print(error)
                }
                if let data = data{
                    DispatchQueue.main.async {
                        cell.episodeImage?.image = UIImage(data: data)
                        
                    }
                }
            }
            task.resume()
        }
    
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
//                destination.episode?.podcastName = self.podcast?.title
                destination.episode?.podcastID = self.podcast?.id
                destination.podcastName?.isHidden = true
            }
        }
     }
     
    
}
