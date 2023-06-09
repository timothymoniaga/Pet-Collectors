//
//  SearchViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 2/5/2023.
//

import UIKit
import Firebase
import FirebaseFirestore

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    let CELL_IDENTIFIER = CardTableViewCell.reuseIdentifier
    private var tradeCards: [TradeCard] = []
    private let firestoreDatabase = Firestore.firestore()
    private var tradesListener: ListenerRegistration?
    var selectedTradeCard: TradeCard?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        fetchTradeCards()
    }
    
    deinit {
        tradesListener?.remove()
    }
    /**
     Fetches trade cards from the Firestore database and populates the trade card collection.

     This method listens to changes in the "trades" collection in Firestore and retrieves trade card documents. It excludes trade cards that belong to the current user by comparing the `cardReference` path to the current user's ID. The fetched trade card documents are then used to fetch the corresponding card data.

     Upon retrieving the card data, it creates `TradeCard` objects and appends them to the `tradeCards` array. The `tradeCard` objects contain information such as breed, statistics, rarity, details, image URL, and a reference to the Firestore document.

     The method uses a dispatch group to wait for the asynchronous operations of fetching card data to complete. Once all the operations are completed, it updates the `tradeCards` array and reloads the table view.

     - Note: This method is typically used to populate the trade card collection or table view in the user interface.

     - SeeAlso: `TradeCard`, `tableView`, `Auth.auth().currentUser?.uid`, `firestoreDatabase`
     */
    func fetchTradeCards() {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            print("Current user ID not found")
            return
        }
        
        tradesListener = firestoreDatabase.collection("trades").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching trade cards: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No trade cards available")
                return
            }
            
            var tradeCards: [TradeCard] = []
            let dispatchGroup = DispatchGroup() // Create a dispatch group to wait for async operations
            
            for document in documents {
                let documentReference = document.reference
                let data = document.data()
                let cardReference = data["cardReference"] as? DocumentReference
                
                // Check if the cardReference contains the current user ID
                if let cardReferencePath = cardReference?.path, cardReferencePath.contains(currentUserId) {
                    continue // Skip this trade document
                }
                
                dispatchGroup.enter() // Enter the dispatch group
                
                cardReference?.getDocument { cardSnapshot, cardError in
                    defer {
                        dispatchGroup.leave() // Leave the dispatch group when the async operation completes
                    }
                    
                    if let cardError = cardError {
                        print("Error fetching card: \(cardError)")
                        return
                    }
                    
                    guard let cardData = cardSnapshot?.data() else {
                        print("Card data not found")
                        return
                    }
                    
                    let breed = cardData["breed"] as? String ?? ""
                    let statistics = cardData["statistics"] as? String ?? ""
                    let rarity = Rarity(rawValue: cardData["rarity"] as? Int32 ?? 0) ?? .common
                    let details = cardData["details"] as? String ?? ""
                    let imageURL = cardData["imageURL"] as? String ?? ""
                    
                    if let cardReference = cardReference { // Unwrap the optional cardReference
                        let tradeCard = TradeCard(breed: breed, statistics: statistics, rarity: rarity, details: details, imageURL: imageURL, cardReference: documentReference)
                        tradeCard.originalRarity = rarity // Assign the original rarity
                        tradeCards.append(tradeCard)
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.tradeCards = tradeCards
                self.tableView.reloadData()
            }
        }
    }
    
    /**
     Sets up the UI elements and their constraints on the cell.
     */
    private func setup() {
        tableView.register(CardTableViewCell.self, forCellReuseIdentifier: "tradeCardCell")
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tradeCards.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER, for: indexPath) as! CardTableViewCell
        
        let card = tradeCards[indexPath.row]
        cell.configure(with: card)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTradeCard = tradeCards[indexPath.row]
        performSegue(withIdentifier: "offerSegue", sender: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           guard let searchText = searchBar.text else { return }
           
           // Filter the tradeCards array based on the search text
           let filteredCards = tradeCards.filter { card in
               let cardDetails = "\(card.breed) \(card.statistics) \(card.rarity) \(card.details)"
               return cardDetails.localizedCaseInsensitiveContains(searchText)
           }
           
           // Update the filtered tradeCards array and reload the table view
           tradeCards = filteredCards
           tableView.reloadData()
       }

       func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchBar.text = nil
           tradeCards = [] // Clear the filtered tradeCards array
           fetchTradeCards() // Refetch all trade cards
       }

       func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           guard let searchText = searchBar.text else { return }
           
           // Filter the tradeCards array based on the search text
           let filteredCards = tradeCards.filter { card in
               let cardDetails = "\(card.breed) \(card.statistics) \(card.rarity) \(card.details)"
               return cardDetails.localizedCaseInsensitiveContains(searchText)
           }
           
           // Update the filtered tradeCards array and reload the table view
           tradeCards = filteredCards
           tableView.reloadData()
           
       }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "offerSegue" {
               if let destinationVC = segue.destination as? OfferViewController {
                   // Pass any necessary data to the destination view controller
                   destinationVC.selectedCard = selectedTradeCard
               }
           }
    }
}
