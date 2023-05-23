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
        
        breed.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 50)
        breed.textAlignment = .center
        self.addSubview(breed)
        
        image.frame = CGRect(x: 0, y: 50, width: self.frame.width,height: 150)
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 15
        self.addSubview(image)
        
        
        details.translatesAutoresizingMaskIntoConstraints = false
        details.numberOfLines = 0
        details.adjustsFontSizeToFitWidth = true
        self.addSubview(details)
        
        NSLayoutConstraint.activate([
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
        // decodeJSON(jsonData: card.statistics!)
        ApiUtil.loadImageFromURL(urlString: card.imageURL ?? "") { image in
            if let image = image {
                self.image.image = image
            } else {
                self.image.image = UIImage(named: "PlaceholderPaw")
            }
        }
    }
    
//    func loadImageFromURL(urlString: String) -> UIImage {
//        guard let url = URL(string: urlString) else { return }
//        DispatchQueue.global().async {
//            if let imageData = try? Data(contentsOf: url) {
//                DispatchQueue.main.async {
//                    let dogImage = UIImage(data: imageData)
//                    return dogImage
////                    let roundedImage = dogImage?.roundedImage(cornerRadius: 10)
////                    self.image.image = roundedImage
//                }
//            }
//        }
//    }
    
    func setColor(rarity: Int32) {
        switch rarity {
        case 0:
            self.backgroundColor = #colorLiteral(red: 0.6443734765, green: 0.6593127847, blue: 0.6590517163, alpha: 1)
        case 1:
            self.backgroundColor = #colorLiteral(red: 0.3268340826, green: 0.6946660876, blue: 0.905626595, alpha: 1)
        case 2:
            self.backgroundColor = #colorLiteral(red: 0.6719612479, green: 0.3691940308, blue: 0.9197270274, alpha: 1)
        case 3:
            self.backgroundColor = #colorLiteral(red: 0.9144165516, green: 0.7269795537, blue: 0, alpha: 1)
        case 4:
            self.backgroundColor = #colorLiteral(red: 0.9476212859, green: 0.264480412, blue: 0.2327539623, alpha: 1)
        default:
            self.backgroundColor = #colorLiteral(red: 0.6443734765, green: 0.6593127847, blue: 0.6590517163, alpha: 1)
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

