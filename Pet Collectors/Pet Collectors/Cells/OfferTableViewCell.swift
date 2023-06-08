//
//  UserTableViewCell.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 2/5/2023.
//

import UIKit

class OfferTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "offerCell"
    
    let forLabel = UILabel()
    let myCardLabel = UILabel()
    let theirCardLabel = UILabel()
    weak var databaseController: DatabaseProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        //let image = UIImage(named: "Blank_Profile")
        
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
    
    func configure(with offer: Offer) {
        //theirCardLabel.text = user.userName
        //yourCardLabel.text = user.details
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
                if ((tradeCard.rarity.rawValue ) >= 1) {
                    let colour = CardUtil.setColor(rarity: tradeCard.rarity.rawValue )
                    self.myCardLabel.textColor = colour
                }
                
            } else {
                // Document doesn't exist or invalid data format
                print("Unable to convert DocumentReference to TradeCard")
            }
        }
        
        
        databaseController?.convertToTradeCard(from: offer.offeredCard) { (tradeCard, error) in
            if let error = error {
                // Handle the error
                print("Error converting DocumentReference to TradeCard: \(error)")
                return
            }
            
            if let tradeCard = tradeCard {
                // Successfully converted to TradeCard
                print("Converted TradeCard: \(tradeCard)")
                self.theirCardLabel.text = "their \(tradeCard.breed)"
                if ((tradeCard.rarity.rawValue ) >= 1) {
                    let colour = CardUtil.setColor(rarity: tradeCard.rarity.rawValue )
                    self.theirCardLabel.textColor = colour
                }
                
            } else {
                // Document doesn't exist or invalid data format
                print("Unable to convert DocumentReference to TradeCard")
            }
        }
        
    }
    
}

