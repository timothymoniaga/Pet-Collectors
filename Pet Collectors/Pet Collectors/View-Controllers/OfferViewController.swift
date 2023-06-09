//
//  OfferViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 3/5/2023.
//

import UIKit
import Firebase

class OfferViewController: UIViewController, UINavigationControllerDelegate {

    var selectedCard: TradeCard?
    var offeredTradeCard: TradeCard?
    let cardHeight = 250
    let cardWidth = 150
    let wantCard = CardView()
    let offerCard = CardView()
    let tradeImage = UIImageView()
    let infoLabel = UILabel()
    let offerButton = UIButton(type: .custom)
    let rejectButton = UIButton(type: .custom)
    let acceptButton = UIButton(type: .custom)
    var offeredCard: Card?
    weak var databaseController: DatabaseProtocol?
    var activeOffer = false
    var selectedOffer: Offer?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        navigationController?.delegate = self
        tabBarController?.tabBar.isHidden = true
        setup()
        
        if activeOffer {
            configureIfActiveOffer()
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
            // Tab bar comes back
        if viewController is SearchViewController {
                tabBarController?.tabBar.isHidden = false
            }
        }
    
    /**
     Sets up the UI elements and their constraints on the cell.
     */
    private func setup() {
        
        tradeImage.image = UIImage(named: "Swap")
        
        if let tradeCard = selectedCard {
            wantCard.configure(card: tradeCard)
            wantCard.height = cardHeight
            wantCard.width = cardWidth
            
            if(!activeOffer) {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCard))
                
                offerCard.addGestureRecognizer(tapGesture)
                offerCard.height = cardHeight
                offerCard.width = cardWidth
            }

            
            infoLabel.text = "Tap on the card above to select your card to trade"
            infoLabel.font = .italicSystemFont(ofSize: 12)
            infoLabel.textAlignment = .center
            
            offerButton.backgroundColor = UIColor.lightGray
            offerButton.setTitle("Make Offer", for: .normal)
            offerButton.setTitleColor(.white, for: .normal)
            offerButton.layer.cornerRadius = 5
            offerButton.addTarget(self, action: #selector(offerButtonTapped), for: .touchUpInside)
            offerButton.isEnabled = false
            
            view.addSubview(wantCard)
            view.addSubview(tradeImage)
            view.addSubview(offerCard)
            view.addSubview(infoLabel)
            view.addSubview(offerButton)
            
            wantCard.translatesAutoresizingMaskIntoConstraints = false
            tradeImage.translatesAutoresizingMaskIntoConstraints = false
            offerCard.translatesAutoresizingMaskIntoConstraints = false
            infoLabel.translatesAutoresizingMaskIntoConstraints = false
            offerButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                wantCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                wantCard.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                wantCard.heightAnchor.constraint(equalToConstant: CGFloat(cardHeight)),
                wantCard.widthAnchor.constraint(equalToConstant: CGFloat(cardWidth)),
                
                tradeImage.topAnchor.constraint(equalTo: wantCard.bottomAnchor, constant: 20),
                tradeImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                tradeImage.heightAnchor.constraint(equalToConstant: 60),
                tradeImage.widthAnchor.constraint(equalToConstant: 60),
                
                offerCard.topAnchor.constraint(equalTo: tradeImage.bottomAnchor, constant: 20),
                offerCard.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                offerCard.heightAnchor.constraint(equalToConstant: CGFloat(cardHeight)),
                offerCard.widthAnchor.constraint(equalToConstant: CGFloat(cardWidth)),
                
                infoLabel.topAnchor.constraint(equalTo: offerCard.bottomAnchor),
                infoLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                infoLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                infoLabel.heightAnchor.constraint(equalToConstant: 20),
                
                offerButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20),
                offerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
                offerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
                offerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
                
            ])
            
            if activeOffer {
                offerButton.removeFromSuperview()
                infoLabel.removeFromSuperview()
                
                if let card = offeredTradeCard {
                    offerCard.configure(card: card)
                    offerCard.height = cardHeight
                    offerCard.width = cardWidth
                }
                
                acceptButton.backgroundColor = UIColor.systemGreen
                acceptButton.setTitle("Accept Offer", for: .normal)
                acceptButton.setTitleColor(.white, for: .normal)
                acceptButton.layer.cornerRadius = 5
                acceptButton.addTarget(self, action: #selector(acceptOffer), for: .touchUpInside)
                
                rejectButton.backgroundColor = UIColor.systemRed
                rejectButton.setTitle("Decline Offer", for: .normal)
                rejectButton.setTitleColor(.white, for: .normal)
                rejectButton.layer.cornerRadius = 5
                rejectButton.addTarget(self, action: #selector(declineOffer), for: .touchUpInside)
                
                view.addSubview(acceptButton)
                view.addSubview(rejectButton)
                
                acceptButton.translatesAutoresizingMaskIntoConstraints = false
                rejectButton.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    acceptButton.topAnchor.constraint(equalTo: offerCard.bottomAnchor, constant: 20),
                    acceptButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                    acceptButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
                    acceptButton.widthAnchor.constraint(equalToConstant: 100),

                    rejectButton.topAnchor.constraint(equalTo: offerCard.bottomAnchor, constant: 20),
                    rejectButton.leadingAnchor.constraint(equalTo: acceptButton.trailingAnchor, constant: 20),
                    rejectButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                    rejectButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
                    rejectButton.widthAnchor.constraint(equalTo: acceptButton.widthAnchor)
                ])
            }
        }
    }
    
    /**
     Handles the selection of a card.

     This method is invoked when a card is selected. It triggers a segue with the identifier "collectionSegue" to transition to the collection screen.

     - Important: Ensure that the segue with the identifier "collectionSegue" is properly set up in the storyboard.

     - SeeAlso: `performSegue(withIdentifier:sender:)`
     */
    @objc func selectCard() {
        performSegue(withIdentifier: "collectionSegue", sender: nil)
    }
    
    /**
     Handles the tap gesture on the offer button.

     This method is invoked when the user taps the offer button. It creates an offer document in the database based on the selected card and the offered card. It displays a success message and pops the view controller from the navigation stack upon successful completion.

     - Note: The `createOfferDocument(with:for:viewController:)` method is called to create an offer document in the database.

     - Important: Ensure that the `selectedCard` and `offeredCard` properties are properly set before invoking this method.
     */
    @objc func offerButtonTapped() {
        if let cardRef = selectedCard?.cardReference, let offerCardRef = offeredCard?.cardID {
            databaseController?.createOfferDocument(with: cardRef, for: offerCardRef, viewController: self)
        } else {
            print("Error cannot add offer document")
        }
        
        UIUtil.displayMessageDimiss("Offer sent!", "Offer has been sent!", self)
        
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    /**
     Handles the acceptance of an offer.

     This method is invoked when the user accepts an offer. It completes the offer, performs the trade, displays a success message, and updates the user's card collection. It then pops the view controller from the navigation stack.

     - Note: The `completeOfferAndPerformTrade(_:completion:)` method is called to complete the offer and perform the trade. The `copyUserCardsToPersistentStorage(userUID:completion:)` method is called to update the user's card collection.

     - Important: Ensure that the `selectedOffer` property is properly set before invoking this method.
     */
    @objc func acceptOffer() {
        if let offer = selectedOffer {
            databaseController?.completeOfferAndPerformTrade(offer) { (error) in
                if let error = error {
                    print("Error completing offer and performing trade: \(error)")
                } else {
                    print("Offer completed and trade performed successfully.")
                    UIUtil.displayMessageDimiss("Congratulations!", "Trade Successful", self)
                    guard let userUID = Auth.auth().currentUser?.uid else {
                        // Handle the case when the user is not logged in
                        return
                    }
                    // to update the collection view controller
                    self.databaseController?.copyUserCardsToPersistentStorage(userUID: userUID) { success in
                        if success {
                            if let navigationController = self.navigationController {
                                navigationController.popViewController(animated: true)
                            }
                        } else {
                            print("Error copying cards")
                        }
                    }
                }
            }
        }
    }
    
    
    /**
     Handles the decline of an offer.

     This method is invoked when the user declines an offer. It deletes the offer document from the database, displays a decline message, and pops the view controller from the navigation stack.

     - Note: The `deleteOfferDocument(offer:)` method is called to delete the offer document from the database.

     - Important: Ensure that the `selectedOffer` property is properly set before invoking this method.
     */
    @objc func declineOffer() {
        if let offer = selectedOffer {
            databaseController?.deleteOfferDocument(offer: offer)
        }
        UIUtil.displayMessageDimiss("Declined!", "Trade Offer has been declined", self)
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "collectionSegue" {
            if let destinationVC = segue.destination as? CollectionViewController {
                destinationVC.tradeActive = true
                destinationVC.delegate = self
            }
        }
    }
    /**
     Configures the view controller if there is an active offer.

     This method is invoked to configure the view controller when there is an active offer (`selectedOffer`). It converts the offer's card and offered card from `DocumentReference` to `TradeCard` objects and sets them as `selectedCard` and `offeredTradeCard` respectively. It then calls the `setup()` method to update the UI.

     - Note: The `convertToTradeCard(from:completion:)` method is used to convert `DocumentReference` to `TradeCard`.

     - Important: Ensure that the `selectedOffer` property is properly set before invoking this method.
     */
    func configureIfActiveOffer() {
        if let currentOffer = selectedOffer {
            print(currentOffer.card.path)
            print(currentOffer.offeredCard.path)
            databaseController?.convertToTradeCard(from: currentOffer.card) { (tradeCard, error) in
                if let error = error {
                    // Handle the error
                    print("Error converting DocumentReference to TradeCard: \(error)")
                    return
                }
                
                if let tradeCard = tradeCard {
                    // Successfully converted to TradeCard
                    print("Converted TradeCard: \(tradeCard)")
                    self.selectedCard = tradeCard
                    self.setup()
                } else {
                    // Document doesn't exist or invalid data format
                    print("Unable to convert DocumentReference to TradeCard")
                }
            }
            
            databaseController?.convertToTradeCard(from: currentOffer.offeredCard) { (tradeCard, error) in
                if let error = error {
                    // Handle the error
                    print("Error converting DocumentReference to TradeCard: \(error)")
                    return
                }
                
                if let tradeCard = tradeCard {
                    // Successfully converted to TradeCard
                    print("Converted TradeCard: \(tradeCard)")
                    self.offeredTradeCard = tradeCard
                    self.setup()
                } else {
                    // Document doesn't exist or invalid data format
                    print("Unable to convert DocumentReference to TradeCard")
                }
            }
            
        }
    }
}

extension OfferViewController: CollectionViewControllerDelegate {
    /**
     Handles the selection of a card in the CollectionViewController.

     This method is invoked when a card is selected in the collection view. It converts the selected `Card` object to a `TradeCard` object and sets it as the offered card (`offeredCard`). It updates the UI by changing the background color of the offer button and enabling it.

     - Parameters:
        - card: The selected `Card` object.

     - Note: The `changeCard(card:)` method is called to update the `offerCard` with the selected card details.
     */
    func didSelectCard(_ card: Card) {
        // convert card to TradeCard then set as the offer card and configure
        offerCard.changeCard(card: card)
        offerButton.backgroundColor = .systemBlue
        offerButton.isEnabled = true
        offeredCard = card
    }
}
