//
//  QueueTableViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit

class QueueTableViewController: UITableViewController {
    
    let SECTION_NOW_PLAYING = 0
    let SECTION_QUEUE = 1
    
    let NOW_PLAYING_CELL = "nowPlayingCell"
    let QUEUE_CELL = "queueCell"
    
    var queue = [EpisodeData]()
    var nowPlaying: EpisodeData?

    
    
    var idOfPodcastFollowed = ["4929146b433f4699b37a0354293d3bbe"]
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor(named: "Teal")
        
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 999;
        
        
        for id in idOfPodcastFollowed{
            print(id)
//            if let url = URL(string: "https://listen-api.listennotes.com/api/v2/podcasts/\(id)?next_episode_pub_date=1479154463000&sort=recent_first"){
                if let url = URL(string: "https://listen-api-test.listennotes.com/api/v2/podcasts/4d3fe717742d4963a85562e9f84d8c79?next_episode_pub_date=1479154463000&sort=recent_first"){
                var request = URLRequest(url: url)
//                request.addValue("c975de1e599a46a6889c7e7006a493eb", forHTTPHeaderField: "X-ListenAPI-Key")
                    let task = URLSession.shared.dataTask(with: request) { [self] (data, response, error) in
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
                            self.queue.append(contentsOf: episodes)
                            self.queue = self.queue.sorted(by: {$0.ms ?? 0 > $1.ms ?? 0})
                            print("SD")
                            print(self.queue.first?.podcastName)
                            print(self.queue.first?.episodeDescription)
                            nowPlaying = queue.first
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
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == SECTION_NOW_PLAYING{
            return 1
        }
        return queue.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_NOW_PLAYING{
            let cell = tableView.dequeueReusableCell(withIdentifier: NOW_PLAYING_CELL, for: indexPath) as! EpisodeTableViewCell
            cell.episodeTitle.text = nowPlaying?.title
            cell.podcastName.text = nowPlaying?.podcastName
            
            if let image = nowPlaying?.image, let url = URL(string: image){
                print("IMAGGE \(nowPlaying?.image)")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: QUEUE_CELL, for: indexPath) as! EpisodeTableViewCell
        
        let episode = queue[indexPath.row]
        cell.episodeTitle.text = episode.title
        cell.podcastName.text = episode.podcastName
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
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
