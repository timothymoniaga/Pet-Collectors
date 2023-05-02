//
//  SearchViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 2/5/2023.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Handle search button click event
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Handle cancel button click event
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Handle text change event
    }
    
}
