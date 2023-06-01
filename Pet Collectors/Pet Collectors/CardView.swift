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
//        super.init(coder: coder)
//        setup()
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        petCollectorsLabel.text = "Pet Collectors"
        petCollectorsLabel.font = .boldSystemFont(ofSize: 18)
        
        image.image = UIImage(named: "PlaceholderPaw")
        image.contentMode = .scaleAspectFit
        
        self.addSubview(petCollectorsLabel)
        self.addSubview(image)
        
        petCollectorsLabel.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            image.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            image.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            image.widthAnchor.constraint(equalTo: self.widthAnchor),
            
            petCollectorsLabel.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10),
            petCollectorsLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            petCollectorsLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            
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
