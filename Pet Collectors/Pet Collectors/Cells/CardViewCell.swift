//
//  CardViewCell.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 25/4/2023.
// TODO: ✅create better colours, maybe art? for the card sides

import UIKit

class CardViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "CardCell"
    let breed = UILabel()
    let image = UIImageView()
    let statistics = UILabel()
    let details = UILabel()
    let scrollView = UIScrollView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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

    func configure(with card: Card) {
        breed.text = card.breed
        image.image = UIImage(named: "PlaceholderPaw")
        let colour = CardUtil.setColor(rarity: card.cardRarity.rawValue)
        self.backgroundColor = colour
        details.text = card.details
        if(card.image == nil) {
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
}

extension UIImage {
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

