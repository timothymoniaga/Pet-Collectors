//
//  CardView.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 1/6/2023.
//

import UIKit

class CardView: UIView {
    
    let image = UIImageView()
    let petCollectorsLabel = UILabel()
    var height = 500
    var width = 300
    var isFlipped = false
    
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
    func setup() {
        
        petCollectorsLabel.text = "Pet Collectors"
        petCollectorsLabel.font = .boldSystemFont(ofSize: 22)
        petCollectorsLabel.textAlignment = .center
        
        image.image = UIImage(named: "PlaceholderPaw")
        image.contentMode = .scaleAspectFit
        
        self.backgroundColor = .lightGray
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 15
        
        self.addSubview(image)
        self.addSubview(petCollectorsLabel)
        
        petCollectorsLabel.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            petCollectorsLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            petCollectorsLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            petCollectorsLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            
            image.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            image.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            image.widthAnchor.constraint(equalTo: self.widthAnchor),
            
            self.widthAnchor.constraint(equalToConstant: CGFloat(width)),
            self.heightAnchor.constraint(equalToConstant: CGFloat(height))
        ])
        
    }
    
    /**
     Changes the displayed card with the provided card data.

     This function updates the view to display the information from the given `Card` object. It sets the background color based on the rarity of the card and sets the `petCollectorsLabel` text to the breed of the card. The card image is loaded from the URL specified in the `imageURL` property of the card. If the image loading is successful, it is set as the image of the view. Otherwise, a placeholder image is used.

     - Parameters:
       - card: The `Card` object containing the card data to be displayed.

     - Important: The function performs UI updates on the main DispatchQueue.

     - Note: The `CardUtil.setColor(rarity:)` method is used to determine the background color based on the rarity of the card.
     */
    func changeCard(card: Card) {
        
        DispatchQueue.main.async {
            self.backgroundColor = CardUtil.setColor(rarity: card.cardRarity.rawValue )
            self.petCollectorsLabel.text = card.breed
        }
        
        ApiUtil.loadImageFromURL(urlString: card.imageURL ?? "") { picture in
            if let picture = picture {
                self.image.image = picture
            } else {
                self.image.image = UIImage(named: "PlaceholderPaw")
            }
        }
    }
    
    /**
     Configures the view to display the information from the provided `TradeCard` object.

     This function updates the view to display the information from the given `TradeCard` object. It sets the background color based on the rarity of the card and sets the `petCollectorsLabel` text to the breed of the card. The card image is loaded from the URL specified in the `imageURL` property of the card. If the image loading is successful, it is set as the image of the view. Otherwise, a placeholder image is used.

     - Parameters:
       - card: The `TradeCard` object containing the card data to be displayed.

     - Important: The function performs UI updates on the main DispatchQueue.

     - Note: The `CardUtil.setColor(rarity:)` method is used to determine the background color based on the rarity of the card.
     */
    func configure(card: TradeCard) {
        
        DispatchQueue.main.async {
            self.backgroundColor = CardUtil.setColor(rarity: card.rarity.rawValue )
            self.petCollectorsLabel.text = card.breed
        }
        
        ApiUtil.loadImageFromURL(urlString: card.imageURL) { picture in
            if let picture = picture {
                self.image.image = picture
            } else {
                self.image.image = UIImage(named: "PlaceholderPaw")
            }
        }
    }
    
}
