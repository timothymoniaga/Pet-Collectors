//
//  TradeViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 1/5/2023.
//  ✅ TODO: Create firebase login auth for users and add to database etc...

import UIKit
import Firebase

class TradeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var tradeCards: [TradeCard] = []
    private let REUSE_IDENTIFIER = CardViewCell.reuseIdentifier
    private let firestoreDatabase = Firestore.firestore()
    private var tradesListener: ListenerRegistration?
    let cardsForTradeLabel = UILabel()
    var collectionView: UICollectionView!
    let addButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Trade"
        setup()
        fetchTradeCards()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tradeCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: REUSE_IDENTIFIER, for: indexPath) as! CardViewCell
        let card = tradeCards[indexPath.row]
        cell.configureTrade(with: card)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIUtil.displayMessageContinueCancel("Remove card from available trades", "This will automatically reject all offers with this card.", self) { isContinue in
            if isContinue {
                let tradeCard = self.tradeCards[indexPath.item]
                let cardReference = tradeCard.cardReference
                
                // Delete the reference from Firebase collection
                cardReference.delete { error in
                    if let error = error {
                        print("Error deleting card reference: \(error)")
                    } else {}
                }
            }
        }
    }

    
    /**
     Fetches the trade cards from the Firestore database and updates the collection view.

     This method listens for changes in the "trades" collection in Firestore and retrieves the corresponding trade card data. It populates the `tradeCards` array with `TradeCard` objects and reloads the collection view to display the updated data.

     The method handles asynchronous operations using a dispatch group to ensure all card data is fetched before updating the collection view.

     Note: The method assumes that the Firestore database has a "trades" collection containing trade card documents with the following fields: "cardReference" (DocumentReference), "user" (String), "breed" (String), "statistics" (String), "rarity" (Int32), "details" (String), and "imageURL" (String).

     Make sure to call this method during the setup phase of your view controller to populate the initial trade card data.

     */
    func fetchTradeCards() {
        tradesListener = firestoreDatabase.collection("trades").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            // Clear the existing trade cards array and reload the collection view
            self.tradeCards = []
            self.collectionView.reloadData()

            if let error = error {
                print("Error fetching trade cards: \(error)")
                return
            }

            // Check if there are any trade card documents available
            guard let documents = snapshot?.documents else {
                print("No trade cards available")
                return
            }

            let dispatchGroup = DispatchGroup() // Create a dispatch group to wait for async operations

            // Iterate through the trade card documents
            for document in documents {
                let documentReference = document.reference
                let data = document.data()
                let cardReference = data["cardReference"] as? DocumentReference

                dispatchGroup.enter() // Enter the dispatch group

                // Fetch the card data from the cardReference document
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

                    // Check if the card belongs to the current user's UID
                    if Auth.auth().currentUser?.uid == data["user"] as? String {
                        let breed = cardData["breed"] as? String ?? ""
                        let statistics = cardData["statistics"] as? String ?? ""
                        let rarity = Rarity(rawValue: cardData["rarity"] as? Int32 ?? 0) ?? .common
                        let details = cardData["details"] as? String ?? ""
                        let imageURL = cardData["imageURL"] as? String ?? ""

                        if let cardReference = cardReference { // Unwrap the optional cardReference
                            let tradeCard = TradeCard(breed: breed, statistics: statistics, rarity: rarity, details: details, imageURL: imageURL, cardReference: documentReference)
                            self.tradeCards.append(tradeCard)
                        }
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                // Update the tradeCards array and reload the collection view on the main queue
                self.tradeCards = self.tradeCards
                self.collectionView.reloadData()
            }
        }
    }

    
    /**
     Sets up the UI elements and their constraints on the cell.
     */
    private func setup() {
        cardsForTradeLabel.text = "Your cards currently for trade:"
        cardsForTradeLabel.textAlignment = .center
        cardsForTradeLabel.font = .boldSystemFont(ofSize: 18)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 20
        layout.itemSize = CGSize(width: 96, height: 160)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(CardViewCell.self, forCellWithReuseIdentifier: REUSE_IDENTIFIER)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        addButton.backgroundColor = UIColor.systemBlue
        addButton.setTitle("Add Card", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.layer.cornerRadius = 5
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        view.addSubview(addButton)
        view.addSubview(cardsForTradeLabel)
        view.addSubview(collectionView)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        cardsForTradeLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardsForTradeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cardsForTradeLabel.widthAnchor.constraint(equalToConstant: view.frame.width),
            cardsForTradeLabel.heightAnchor.constraint(equalToConstant: 50),
            
            collectionView.topAnchor.constraint(equalTo: cardsForTradeLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            
            addButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 10),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 125),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -125)
        ])
    }
    
    /**
     Handles the tap event of the add button.

     This method displays a message dialog with the title "Add card to trade" and a message instructing the user to select a card from their collection and click the '+' button in the top right corner to initiate a trade.

     Upon tapping the "Continue" button in the message dialog, the method sets the selected tab of the tab bar controller to the first tab, which is typically the collection view of the user's cards.

     - Parameter sender: The object that triggered the action.
     */
    @objc func addButtonTapped() {
        UIUtil.displayMessageContinueCancel("Add card to trade", "To trade, select a card from your collection and click the '+' in the top right corner", self) { isContinue in
            if isContinue {
                // Using the tab bar controller to reduce use of segues
                if let tabBarController = self.tabBarController {
                    tabBarController.selectedIndex = 0
                }
            } else {
                // Handle cancel action if desired
            }
        }
    }

}
