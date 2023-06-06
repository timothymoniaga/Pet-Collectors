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
    let HEIGHT = 500
    let WIDTH = 300
    var isFlipped = false
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            
            self.widthAnchor.constraint(equalToConstant: 300),
            self.heightAnchor.constraint(equalToConstant: 500)
        ])
        
    }
    
    
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
    
}
