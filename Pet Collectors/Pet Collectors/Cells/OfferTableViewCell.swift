//
//  UserTableViewCell.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 2/5/2023.
//
//  Custom Table view

import UIKit

/**
 Custom table view cell for displaying offer information.
 
 The `OfferTableViewCell` class is a custom UITableViewCell subclass that provides a custom layout for displaying offer details. It includes labels for the user's card, the trade offer label, and the other user's card. It also provides a method to configure the cell with an `Offer` object and convert the `DocumentReference` objects to `TradeCard` objects.
 */
class OfferTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "offerCell"
    
    // UI elements
    let forLabel = UILabel()
    let myCardLabel = UILabel()
    let theirCardLabel = UILabel()
    
    weak var databaseController: DatabaseProtocol?
    var currentOffer: Offer?
    
    /**
     Initializes the OfferTableViewCell with the given style and reuseIdentifier.
     
     - Parameters:
        - style: The style of the cell.
        - reuseIdentifier: The identifier to associate with the cell.
     */
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Sets up the UI elements and their constraints on the cell.
     */
    private func setup() {
        myCardLabel.text = "their card"
        myCardLabel.numberOfLines = 0
        myCardLabel.contentMode = .center
        
        forLabel.text = "for"
        forLabel.numberOfLines = 0
        forLabel.contentMode = .center
        
        theirCardLabel.text = "your card"
        theirCardLabel.numberOfLines = 0
        theirCardLabel.contentMode = .center
        
        contentView.addSubview(myCardLabel)
        contentView.addSubview(forLabel)
        contentView.addSubview(theirCardLabel)
        
        myCardLabel.translatesAutoresizingMaskIntoConstraints = false
        forLabel.translatesAutoresizingMaskIntoConstraints = false
        theirCardLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            myCardLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            myCardLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            forLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            forLabel.leadingAnchor.constraint(equalTo: myCardLabel.trailingAnchor, constant: 5),
            
            theirCardLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            theirCardLabel.leadingAnchor.constraint(equalTo: forLabel.trailingAnchor, constant: 5)
        ])
    }
    
    /**
     Configures the cell with the given offer object.
     
     - Parameters:
        - offer: The `Offer` object to configure the cell with.
     */
    func configure(with offer: Offer) {
        // Convert DocumentReference to TradeCard for the user's card
        databaseController?.convertToTradeCard(from: offer.card) { (tradeCard, error) in
            if let error = error {
                // Handle the error
                print("Error converting DocumentReference to TradeCard: \(error)")
                return
            }
            
            if let tradeCard = tradeCard {
                // Successfully converted to TradeCard
                print("Converted TradeCard: \(tradeCard)")
                self.myCardLabel.text = "Your \(tradeCard.breed)"
                if tradeCard.rarity.rawValue >= 1 {
                    let colour = CardUtil.setColor(rarity: tradeCard.rarity.rawValue)
                    self.myCardLabel.textColor = colour
                }
                
            } else {
                // Document doesn't exist or invalid data format
                print("Unable to convert DocumentReference to TradeCard")
            }
        }
        
        // Convert DocumentReference to TradeCard for the other user's card
        databaseController?.convertToTradeCard(from: offer.offeredCard) { (tradeCard, error) in
            if let error = error {
                // Handle the error
                print("Error converting DocumentReference to TradeCard: \(error)")
                return
            }
            
            if let tradeCard = tradeCard {
                // Successfully converted to TradeCard
                print("Converted TradeCard: \(tradeCard)")
                self.theirCardLabel.text = "Their \(tradeCard.breed)"
                if tradeCard.rarity.rawValue >= 1 {
                    let colour = CardUtil.setColor(rarity: tradeCard.rarity.rawValue)
                    self.theirCardLabel.textColor = colour
                }
                
            } else {
                // Document doesn't exist or invalid data format
                print("Unable to convert DocumentReference to TradeCard")
            }
        }
    }
}

