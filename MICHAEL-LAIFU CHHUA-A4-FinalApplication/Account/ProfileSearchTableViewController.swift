//
//  ProfileSearchTableViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 6/5/21.
//

import UIKit
import FirebaseFirestore

class ProfileSearchTableViewController: UITableViewController, UISearchBarDelegate, TabBarSwitchDelegate {

    private var indicator = UIActivityIndicatorView()
    private let CELL_PROFILE = "profileCell"
    private var newProfiles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Add a loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerYAnchor)
        ])
        
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        // https://stackoverflow.com/questions/55600639/find-which-tab-bar-item-is-selected
        // reason for doing this is because if i enter a text into the search bar and then move to a different tab controller, this function gets called for some reason
        if tabBarController?.selectedIndex == 3{
            // viewController is visible
            newProfiles.removeAll()
            tableView.reloadData()
            
            guard let searchText = searchBar.text, searchText.count > 0 else {return}
            
            indicator.startAnimating()
            URLSession.shared.invalidateAndCancel()
            requestResultsNamed(searchText)
            
        }
    }
    
    func requestResultsNamed(_ resultName: String){
        let database = Firestore.firestore()
        let usernameRef = database.collection("usernames")
        usernameRef.getDocuments { (querySnapshot, error) in
            if let error = error{
                return
            }
            var arrayOfUsers = [String]()
            if let snapshot = querySnapshot{
                snapshot.documents.forEach { (snapshot) in
                    let user = snapshot["username"] as! String
                    arrayOfUsers.append(user)
                }
                // I am doing it this way as to my knowledge, firebase does not support substring matching
                let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
                let currentUserDisplayName = appDelegate?.currentSender?.displayName
                for user in arrayOfUsers{
                    if user.lowercased().contains(resultName.lowercased()) && user != currentUserDisplayName{
                        self.newProfiles.append(user)
                    }
                }
                self.indicator.stopAnimating()
                self.tableView.reloadData()
            }
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newProfiles.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_PROFILE, for: indexPath)
        let profile = newProfiles[indexPath.row]
        cell.textLabel?.text = profile
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let profile = newProfiles[indexPath.row]
        usernameTapped(profile, self, true)()
    }
    

    
}
