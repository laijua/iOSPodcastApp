//
//  HomeTableViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit
import FirebaseAuth

class HomeTableViewController: UITableViewController {
//MAKE SHT PRIVATE LATER
    @IBAction func signOut(_ sender: Any) {
        
        do {
         try Auth.auth().signOut()
        } catch {
         print("Log out error: \(error.localizedDescription)")
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginNavController = storyboard.instantiateViewController(identifier: "LoginNavigationController")

            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(loginNavController)
    }
    
    var idOfPodcastFollowed = [String]()
    var episodes = [EpisodeData]()
    
    var placeHolderImage: UIImage?
    
    let SECTION_TODAY = 0
    let SECTION_YESTERDAY = 1
    let SECTION_THIS_WEEK = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(named: "Teal")
        tabBarController?.tabBar.barTintColor = UIColor(named: "Teal")
        // Phone Sc*m Exposed, TWiP
//        idOfPodcastFollowed.append("18c90e34ce5b48448f8c0b82b819e471")
//        idOfPodcastFollowed.append("5de9e82f0d8a4c1f889a599e32694ae1") // H3LIUM Crew Podcast
        idOfPodcastFollowed.append("4929146b433f4699b37a0354293d3bbe") // H3 Podcast, Hash House

//        title = "DiscussPodcast"
        
        for id in idOfPodcastFollowed{
            print(id)
//            if let url = URL(string: "https://listen-api.listennotes.com/api/v2/podcasts/\(id)?next_episode_pub_date=1479154463000&sort=recent_first"){
                if let url = URL(string: "https://listen-api-test.listennotes.com/api/v2/podcasts/4d3fe717742d4963a85562e9f84d8c79?next_episode_pub_date=1479154463000&sort=recent_first"){
                var request = URLRequest(url: url)
//                request.addValue("c975de1e599a46a6889c7e7006a493eb", forHTTPHeaderField: "X-ListenAPI-Key")
                let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if let error = error{
                        print(error)
                        print("lol")
                    }
                    do{
                        let decoder = JSONDecoder()
                        let podcast = try decoder.decode(PodcastData.self, from: data!)
                        print(podcast.title)
                        if let episodes = podcast.episodes{
                            episodes.forEach({episode in
                                episode.podcastName = podcast.title
                                episode.podcastID = id
                            })
                            self.episodes.append(contentsOf: episodes)
                            self.episodes = self.episodes.sorted(by: {$0.ms ?? 0 > $1.ms ?? 0})
                            print("SD")
                            print(self.episodes.first?.podcastName)
                            print(self.episodes.first?.episodeDescription)
                            if let image = episodes.first?.image, let url = URL(string: image){
                                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                                    if let error = error{
                                        print(error)
                                    }
                                    if let data = data{
                                        self.placeHolderImage = UIImage(data: data)
                                    }
                                }
                                task.resume()
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
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
        
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }

    // Create a standard header that includes the returned text.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        // create headers for each section
        
        //today, yesterday, this week, older
        
        switch section {
        case SECTION_TODAY:
            return "Today"
        case SECTION_YESTERDAY:
            return "Yesterday"
        case SECTION_THIS_WEEK:
            return "This Week"
        default:
            return "Older"
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell", for: indexPath) as! EpisodeTableViewCell
        let episode = episodes[indexPath.row]
        
        
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
//        cell.episodeImage?.image = placeHolderImage
        
        cell.episodeTitle.text = episode.title
        print("title \(episode.title)")
        cell.podcastName.text = episode.podcastName
//        cell.episodeDescription.text = "WASD"
       // cell.episodeDescription.text = episode.episodeDescription
        print("DESCRIPTION \(episode.episodeDescription)")
        cell.dateOfUpload.text = episode.episodeDate
        cell.episodeLength.text = episode.episodeLength

        cell.forumBlock = {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let forumViewController = storyboard.instantiateViewController(identifier: "ForumViewController") as! ForumViewController
            forumViewController.episode = episode
            self.navigationController?.pushViewController(forumViewController, animated: true)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "episodeSegue", sender: nil)
    }
  
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "episodeSegue"{
            let destination = segue.destination as! EpisodeInfoViewController
            if let index = tableView.indexPathForSelectedRow?.row{
                destination.episode  = episodes[index]
                print(destination.episode?.podcastID)
            }
            
        }
    }
    

}
