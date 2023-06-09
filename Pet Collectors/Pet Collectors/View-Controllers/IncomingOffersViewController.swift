//
//  UsersTableViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 2/5/2023.
//

import UIKit

class IncomingOffersViewController: UITableViewController {
    
    let CELL_IDENTIFIER = OfferTableViewCell.reuseIdentifier
    var offers: [Offer] = []
    var selectedOffer: Offer?
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        tableView.register(OfferTableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        
        
        databaseController?.listenForOffers { [weak self] (offers, error) in
            if let error = error {
                // Handle the error
                print("Error listening for offers: \(error)")
                return
            }
            
            // Update the offers and reload the table view
            self?.offers = offers ?? []
            self?.tableView.reloadData()
        }
        
        // setup()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return offers.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER, for: indexPath) as! OfferTableViewCell
        let offer = offers[indexPath.row]
        cell.configure(with: offer)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOffer = offers[indexPath.row]
        performSegue(withIdentifier: "incomingOfferSegue", sender: nil)
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "incomingOfferSegue" {
            if let destinationVC = segue.destination as? OfferViewController {
                // Pass any necessary data to the destination view controller
                destinationVC.activeOffer = true
                destinationVC.selectedOffer = self.selectedOffer
            }
        }
    }
}
