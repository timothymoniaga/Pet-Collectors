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
        // Do any additional setup after loading the view.
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
                    } else {
                        // Delete the item from the tradeCards array
                        // Items do not need to be manually deleted as the listener takes care of the removal
                        //self.tradeCards.remove(at: indexPath.item)
                        //collectionView.deleteItems(at: [indexPath])
                    }
                }
            }
        }
    }

    
    func fetchTradeCards() {
        tradesListener = firestoreDatabase.collection("trades").addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            self.tradeCards = []
            self.collectionView.reloadData()
            if let error = error {
                print("Error fetching trade cards: \(error)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No trade cards available")
                return
            }
            
            let dispatchGroup = DispatchGroup() // Create a dispatch group to wait for async operations
            
            for document in documents {
                let documentReference = document.reference
                let data = document.data()
                let cardReference = data["cardReference"] as? DocumentReference
                
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
                        
//                        let tradeCard = TradeCard(breed: breed, statistics: statistics, rarity: rarity, details: details, imageURL: imageURL)
//                        self.tradeCards.append(tradeCard)
                    }
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.tradeCards = self.tradeCards
                self.collectionView.reloadData()
            }
        }
    }
    
    
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
        //collectionView.backgroundColor = .gray
        
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
    
    @objc func addButtonTapped() {
        UIUtil.displayMessageContinueCancel("Add card to trade", "To trade, select a card from your collection and click the '+' in the top right corner?", self) { isContinue in
            if isContinue {
                // Using the tab bar controller to reduce use of segues
                if let tabBarController = self.tabBarController {
                    tabBarController.selectedIndex = 0
                }
            } else {}
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
