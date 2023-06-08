//
//  OfferViewController.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 3/5/2023.
//

import UIKit

class OfferViewController: UIViewController {

    var selectedCard: TradeCard?
    let cardHeight = 250
    let cardWidth = 150
    let wantCard = CardView()
    let offerCard = CardView()
    let tradeImage = UIImageView()
    let infoLabel = UILabel()
    let offerButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tabBarController?.tabBar.isHidden = true
        title = "Offer"
        setup()
        // Do any additional setup after loading the view.
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
            //infoLabel.backgroundColor = .lightGray
            
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
                //infoLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
                
                offerButton.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 20),
                offerButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50),
                offerButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
                offerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
                
            ])
        }
    }
    
    @objc func selectCard() {
        
    }
    
    @objc func offerButtonTapped() {
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
