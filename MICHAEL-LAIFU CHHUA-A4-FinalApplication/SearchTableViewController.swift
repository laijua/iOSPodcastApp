//
//  SearchTableViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    var searchResult: String? // search string passed from RecommendationViewController
    
    private let MAX_ITEMS_PER_REQUEST = 20
    private let MAX_REQUESTS = 10
    private var currentRequestIndex: Int = 0
    
    private let CELL_SEARCH = "searchCell"

    private let appDelegate = (UIApplication.shared.delegate) as? AppDelegate
    private var newResults = [PodcastData]()
    
    private var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.text = searchResult
        
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
        
        // search the string passed through
        if let searchResult = searchResult{
            requestResultsNamed(searchResult)
        }
    }
    

    
    private func requestResultsNamed(_ resultName: String){
  
                guard let queryString = resultName.addingPercentEncoding(withAllowedCharacters:
                .urlQueryAllowed) else {
                
                return
                }

        guard let requestURL = URL(string: "https://listen-api.listennotes.com/api/v2/search?q=\(queryString)&type=podcast&offset=0&language=English&safe_mode=0" ) else {
        
        return
        }
        
        var request = URLRequest(url: requestURL)
        guard let appDelegate = appDelegate else {return}
        request.addValue(appDelegate.apiKey, forHTTPHeaderField: "X-ListenAPI-Key")
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            
            if let error = error {
                return
            }
            do {
                let decoder = JSONDecoder()
                let searchResultsData = try decoder.decode(SearchResultData.self, from: data!)
                if let searchResults = searchResultsData.results {
                    self.newResults.append(contentsOf: searchResults)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    if searchResults.count == self.MAX_ITEMS_PER_REQUEST,
                       self.currentRequestIndex + 1 < self.MAX_REQUESTS {
                        self.currentRequestIndex += 1
                        self.requestResultsNamed(resultName)
                    }
                }
            } catch let err {
                return
            }
            
            
        }
        task.resume()
        
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        // https://stackoverflow.com/questions/55600639/find-which-tab-bar-item-is-selected
        // reason for doing this is because if i enter a text into the search bar and then move to a different tab controller, this function gets called for some reason
        if tabBarController?.selectedIndex == 1{
            // viewController is visible
            newResults.removeAll()
            tableView.reloadData()
            
            guard let searchText = searchBar.text, searchText.count > 0 else {return}
            
            indicator.startAnimating()
            URLSession.shared.invalidateAndCancel()
            requestResultsNamed(searchText)
            
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newResults.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_SEARCH, for: indexPath) as! PodcastSearchTableViewCell
        
        let result = newResults[indexPath.row]
        cell.podcastName.text = result.title
        cell.podcastDescription.text = result.podcastDescription
        
        if let image = result.image, let url = URL(string: image){
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error{
                    return
                }
                if let data = data{
                    DispatchQueue.main.async {
                        cell.podcastImage.image = UIImage(data: data)
                        cell.podcastImage.layer.cornerRadius = 10
                    }
                }
            }
            task.resume()
        }
        
        return cell
    }
    
    
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "podcastSegue"{
            let destination = segue.destination as! PodcastInfoViewController
            if let index = tableView.indexPathForSelectedRow?.row{
                destination.podcastID = newResults[index].id
            }
        }
    }
    
    
}

