//
//  SearchTableViewController.swift
//  MICHAEL-LAIFU CHHUA-A3-Prototype1
//
//  Created by Michael-Laifu Chhua on 26/4/21.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    var searchResult: String?
    
    let MAX_ITEMS_PER_REQUEST = 20
    let MAX_REQUESTS = 10
    var currentRequestIndex: Int = 0
    
    let CELL_SEARCH = "searchCell"
    let REQUEST_STRING = "https://listen-api-test.listennotes.com/api/v2/search?q=star%20wars&sort_by_date=0&type=episode&offset=0&len_min=10&len_max=30&genre_ids=68%2C82&published_before=1580172454000&published_after=0&only_in=title%2Cdescription&language=English&safe_mode=0"
    
    var newResults = [PodcastData]()
    
    var indicator = UIActivityIndicatorView()
    
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
        
        if let searchResult = searchResult{
            requestResultsNamed(searchResult)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.popViewController(animated: true)
        
    }
    
    func requestResultsNamed(_ resultName: String){
        
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "listen-api-test.listennotes.com"
        searchURLComponents.path = "/api/v2/search"
        searchURLComponents.queryItems = [
            URLQueryItem(name: "maxResults", value: "\(MAX_ITEMS_PER_REQUEST)"),
            URLQueryItem(name: "startIndex", value: "\(currentRequestIndex * MAX_ITEMS_PER_REQUEST)"),
            URLQueryItem(name: "q", value: resultName)
        ]
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }
        
//        guard let queryString = resultName.addingPercentEncoding(withAllowedCharacters:
//        .urlQueryAllowed) else {
//        print("Query string can't be encoded.")
//        return
//        }
//        guard let requestURL = URL(string: "https://listen-api.listennotes.com/api/v2/search?q=h3%20podcast&sort_by_date=0&type=podcast&offset=0&len_min=10&len_max=30&published_before=1580172454000&published_after=0&only_in=title&language=English&safe_mode=0" ) else {
//        print("Invalid URL.")
//        return
//        }
        
        var request = URLRequest(url: requestURL)
//        request.addValue("c975de1e599a46a6889c7e7006a493eb", forHTTPHeaderField: "X-ListenAPI-Key")
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            
            if let error = error {
                print(error)
                return
            }
            
            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                for i in 0...100{
                    print(" ")
                }
                print(jsonString)
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
                print(err)
            }
            
            
        }
        task.resume()
        
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        newResults.removeAll()
        tableView.reloadData()
        
        guard let searchText = searchBar.text, searchText.count > 0 else {return}
        
        indicator.startAnimating()
        URLSession.shared.invalidateAndCancel()
        requestResultsNamed(searchText)
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newResults.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_SEARCH, for: indexPath)
        
        let result = newResults[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.podcastDescription
        
        
        
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
