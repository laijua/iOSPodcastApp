//
//  QueueTableViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit

class QueueTableViewController: UITableViewController {
    
    private let SECTION_NOW_PLAYING = 0
    private let SECTION_QUEUE = 1
    
    private let NOW_PLAYING_CELL = "nowPlayingCell"
    private let QUEUE_CELL = "queueCell"
    private let NOTHING_CELL = "whenQueueEmptyCell"
    
    private var queue = [EpisodeData]()
    private var nowPlaying = [EpisodeData]()
    private let appDelegate = (UIApplication.shared.delegate) as? AppDelegate


    @IBOutlet weak var editUIBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var playUIBarButtonItem: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // I do not remove observer as it needs to be active in the background when episodes are playing in playerViewController
        NotificationCenter.default.addObserver(self, selector: #selector(userDefaultsDidChange), name: UserDefaults.didChangeNotification, object: nil)
        
        updateQueue()
        navigationController?.navigationBar.barTintColor = UIColor(named: "Teal")
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 999;
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if queue.count == 0 && nowPlaying.count == 0{
        playUIBarButtonItem.isEnabled = false
        playUIBarButtonItem.tintColor = UIColor.clear
        }
        else{
            playUIBarButtonItem.isEnabled = true
            playUIBarButtonItem.tintColor = UIColor.label
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setEditing(false, animated: false);
        editUIBarButtonItem.style = UIBarButtonItem.Style.plain;
        editUIBarButtonItem.title = "Edit";
    }

    
    @objc func userDefaultsDidChange(_ notification: Notification) {
        updateQueue()
        tableView.reloadData()
    }
    
    
    // everytime the episode currently playing ends, the first element in queue is removed and is now the one currently playing. In this app, only the latest previous episode that has been played is saved at a time, meaning you can go only one episode in the player.
    private func updateQueue(){
        nowPlaying = appDelegate?.nowPlaying ?? []
        if self.nowPlaying.count == 0 && appDelegate?.queueArray.count ?? 0 > 0{
            guard let episode = appDelegate?.queueArray.removeFirst() else{return}
            nowPlaying.append(episode)
            appDelegate?.nowPlaying.append(episode)
        }
        if let queueArray = appDelegate?.queueArray{
            queue = queueArray
        }
    }
    
    
    @IBAction func playQueue(_ sender: Any) {
        if let nowPlaying = nowPlaying.first{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
            nextViewController.episode = nowPlaying
            navigationController?.pushViewController(nextViewController, animated: true)
            
        }
    }
    
    
    
//    https://stackoverflow.com/questions/24772457/swift-reorder-uitableview-cells
    @IBAction func editTableView (sender:UIBarButtonItem)
    {
        // enable/disable editting
        if tableView.isEditing{
            tableView.setEditing(false, animated: true);
            editUIBarButtonItem.style = UIBarButtonItem.Style.plain;
            editUIBarButtonItem.title = "Edit";
        }
        else{
            tableView.setEditing(true, animated: true);
            editUIBarButtonItem.title = "Done";
            editUIBarButtonItem.style =  UIBarButtonItem.Style.done;
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if queue.count > 0 || nowPlaying.count > 0{
            return 2
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if queue.count == 0 && nowPlaying.count == 0{
            return 1
        }
        if section == SECTION_NOW_PLAYING{
            return nowPlaying.count
        }
        return queue.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if queue.count == 0 && nowPlaying.count == 0{
            return ""
        }
        if section == SECTION_NOW_PLAYING{
            return "To Play"
        }
        return "In Queue"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if queue.count == 0 && nowPlaying.count == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: NOTHING_CELL, for: indexPath) as! EmptyEpisodesTableViewCell
            cell.noEpisodesText.text = "No episodes have been queued yet. \n \n Tap Below to search for podcasts."
            cell.searchBlock = {
                self.tabBarController?.selectedIndex = 1
            }
            cell.searchUIButton.layer.cornerRadius = 10
            return cell
        }
        
        
        if indexPath.section == SECTION_NOW_PLAYING{
            let cell = tableView.dequeueReusableCell(withIdentifier: QUEUE_CELL, for: indexPath) as! EpisodeTableViewCell
            let episode = nowPlaying.first
            cell.episodeTitle.text = episode?.title
            cell.podcastName.text = episode?.podcastName
            cell.dateOfUpload.text = episode?.episodeDate
            cell.episodeLength.text = episode?.episodeLength
            
            if let image = episode?.image, let url = URL(string: image){
                
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
            
            cell.forumBlock = {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let forumViewController = storyboard.instantiateViewController(identifier: "ForumViewController") as! ForumViewController
                forumViewController.episode = self.nowPlaying.first
                forumViewController.hidePodcastName = true
                self.navigationController?.pushViewController(forumViewController, animated: true)
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

        
        cell.forumBlock = {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let forumViewController = storyboard.instantiateViewController(identifier: "ForumViewController") as! ForumViewController
            forumViewController.episode = episode
            forumViewController.hidePodcastName = true
            self.navigationController?.pushViewController(forumViewController, animated: true)
        }
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.section == SECTION_QUEUE{
            return true
        }
        return false
    }
    
    
    // SAFE TO NOT UPDATE self.queue IN WHEN DELETING OR REORDERING AS THE OBSERVER/LISTENER DOES IT ANYWAYS
    
//    https://stackoverflow.com/questions/4945092/reordering-cells-in-uitableview
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_QUEUE {
            let index = indexPath.row
            appDelegate?.queueArray.remove(at: index)
            let queueData = NSKeyedArchiver.archivedData(withRootObject: appDelegate?.queueArray)
            UserDefaults.standard.set(queueData, forKey: "queue")
            
            if appDelegate?.queueArray.count == 0{
                tableView.setEditing(false, animated: false);
                editUIBarButtonItem.style = UIBarButtonItem.Style.plain;
                editUIBarButtonItem.title = "Edit";
            }
        }
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        guard let itemToMove = appDelegate?.queueArray[fromIndexPath.row] else {return}
        appDelegate?.queueArray.remove(at: fromIndexPath.row)
        appDelegate?.queueArray.insert(itemToMove, at: to.row)
        
        let queueData = NSKeyedArchiver.archivedData(withRootObject: appDelegate?.queueArray)
        UserDefaults.standard.set(queueData, forKey: "queue")
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_QUEUE{
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if appDelegate?.nowPlaying.count == 0 && appDelegate?.queueArray.count == 0{
            return
        }
        
        let index = indexPath.row
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let episodeInfoViewController = storyboard.instantiateViewController(identifier: "EpisodeInfoViewController") as! EpisodeInfoViewController
        if indexPath.section == SECTION_NOW_PLAYING{
            episodeInfoViewController.episode = appDelegate?.nowPlaying[index]
        }
        else if indexPath.section == SECTION_QUEUE{
            episodeInfoViewController.episode = appDelegate?.queueArray[index]
        }
        self.navigationController?.pushViewController(episodeInfoViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if appDelegate?.nowPlaying.count == 0 && appDelegate?.queueArray.count == 0{
            return nil
        }
        return indexPath
    }
    
}
