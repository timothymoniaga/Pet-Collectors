//
//  CardViewCell.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 25/4/2023.
//  Collection view cell for cards

import UIKit

/**
 Collection view cell for displaying cards.
 
 The `CardViewCell` class is a custom UICollectionViewCell subclass that provides a custom layout for displaying card details. It includes labels for the card's breed, an image of the card, and additional details about the card. It also supports configuring the cell with a `Card` or `TradeCard` object for display.
 */
class CardViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CardCell"
    
    // UI elements
    let breed = UILabel()
    let image = UIImageView()
    let details = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
     Sets up the UI elements and their constraints on the cell.
     */
    private func setup() {
        self.layer.cornerRadius = 15
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowRadius = 3
        self.backgroundColor = .lightGray
        
        breed.translatesAutoresizingMaskIntoConstraints = false
        breed.textAlignment = .center
        breed.adjustsFontSizeToFitWidth = true
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 15
        
        details.translatesAutoresizingMaskIntoConstraints = false
        details.numberOfLines = 0
        details.adjustsFontSizeToFitWidth = true
        
        self.addSubview(image)
        self.addSubview(details)
        self.addSubview(breed)
        
        NSLayoutConstraint.activate([
            breed.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            breed.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            breed.topAnchor.constraint(equalTo: self.topAnchor),
            breed.heightAnchor.constraint(equalToConstant: 50),
            
            image.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            image.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            image.topAnchor.constraint(equalTo: breed.bottomAnchor, constant: 10),
            image.heightAnchor.constraint(equalToConstant: 150),
            
            details.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            details.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            details.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10),
            details.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50)
        ])
    }
    
    /**
     Configures the cell with the given `Card` object.
     
     - Parameters:
        - card: The `Card` object to configure the cell with.
     */
    func configure(with card: Card) {
        breed.text = card.breed
        image.image = UIImage(named: "PlaceholderPaw")
        let colour = CardUtil.setColor(rarity: card.cardRarity.rawValue)
        self.backgroundColor = colour
        details.text = card.details
        
        if card.image == nil {
            ApiUtil.loadImageFromURL(urlString: card.imageURL ?? "") { image in
                if let image = image {
                    self.image.image = image.roundedImage(cornerRadius: 15)
                    card.image = image.roundedImage(cornerRadius: 15)
                } else {
                    self.image.image = UIImage(named: "PlaceholderPaw")
                }
            }
        } else {
            image.image = card.image
        }
    }
    
    /**
     Configures the cell with the given `TradeCard` object.
     
     - Parameters:
        - card: The `TradeCard` object to configure the cell with.
     */
    func configureTrade(with card: TradeCard) {
        breed.text = card.breed
        image.image = UIImage(named: "PlaceholderPaw")
        image.contentMode = .scaleAspectFit
        let colour = CardUtil.setColor(rarity: card.rarity.rawValue)
        self.backgroundColor = colour
        details.text = card.details
        
        // Load image from URL
        ApiUtil.loadImageFromURL(urlString: card.imageURL) { image in
            if let image = image {
                self.image.image = image.roundedImage(cornerRadius: 15)
            } else {
                self.image.image = UIImage(named: "PlaceholderPaw")
            }
        }
    }
}

extension UIImage {
    /**
     Rounds the corners of the image with the given corner radius.
     
     - Parameters:
        - cornerRadius: The radius to use when rounding the corners.
     
     - Returns: The rounded image.
     */
    func roundedImage(cornerRadius: CGFloat) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        path.addClip()
        draw(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}


