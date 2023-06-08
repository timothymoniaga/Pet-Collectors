//
//  OfferViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 3/5/2023.
//

import UIKit

class OfferViewController: UIViewController, UINavigationControllerDelegate {

    var selectedCard: TradeCard?
    let cardHeight = 250
    let cardWidth = 150
    let wantCard = CardView()
    var offerCard = CardView()
    let tradeImage = UIImageView()
    let infoLabel = UILabel()
    let offerButton = UIButton(type: .custom)
    var offeredCard: Card?
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        navigationController?.delegate = self
        tabBarController?.tabBar.isHidden = true
        title = "Offer"
        setup()
        // Do any additional setup after loading the view.
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
            // Tab bar comes back
        if viewController is SearchViewController {
                tabBarController?.tabBar.isHidden = false
            }
        }
    
    private func setup() {
        
        tradeImage.image = UIImage(named: "Swap")
        
        if let tradeCard = selectedCard {
            wantCard.configure(card: tradeCard)
            wantCard.height = cardHeight
            wantCard.width = cardWidth
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectCard))
            
            offerCard.addGestureRecognizer(tapGesture)
            offerCard.height = cardHeight
            offerCard.width = cardWidth
            
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
                wantCard.heightAnchor.constraint(equalToConstant: CGFloat(wantCard.height)),
                wantCard.widthAnchor.constraint(equalToConstant: CGFloat(wantCard.width)),
                
                tradeImage.topAnchor.constraint(equalTo: wantCard.bottomAnchor, constant: 20),
                tradeImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                tradeImage.heightAnchor.constraint(equalToConstant: 60),
                tradeImage.widthAnchor.constraint(equalToConstant: 60),
                
                offerCard.topAnchor.constraint(equalTo: tradeImage.bottomAnchor, constant: 20),
                offerCard.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                offerCard.heightAnchor.constraint(equalToConstant: CGFloat(offerCard.height)),
                offerCard.widthAnchor.constraint(equalToConstant: CGFloat(offerCard.width)),
                
                infoLabel.topAnchor.constraint(equalTo: offerCard.bottomAnchor),
                infoLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                infoLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                infoLabel.heightAnchor.constraint(equalToConstant: 20),
                
                offerButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20),
                offerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
                offerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
                offerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
                
            ])
        }
    }
    
    @objc func selectCard() {
        performSegue(withIdentifier: "collectionSegue", sender: nil)
    }
    
    @objc func offerButtonTapped() {
        if let cardRef = selectedCard?.cardReference, let offerCardRef = offeredCard?.cardID {
            databaseController?.createOfferDocument(with: cardRef, for: offerCardRef, viewController: self)
        } else {
            print("Error cannot add offer document")
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
}

extension OfferViewController: CollectionViewControllerDelegate {
    func didSelectCard(_ card: Card) {
        // convert card to TradeCard then set as the offer card and configure
        offerCard.changeCard(card: card)
        offerButton.backgroundColor = .systemBlue
        offerButton.isEnabled = true
        offeredCard = card
    }
}
