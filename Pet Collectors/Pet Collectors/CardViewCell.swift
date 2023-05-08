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
    let details = UILabel()
    let statistice = UILabel()
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
        setColor(rarity: card.cardRarity.rawValue)
        
        decodeJSON(jsonData: card.statistics!)
        loadImageFromURL(urlString: card.imageURL ?? "")
    }
    
    func loadImageFromURL(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    let dogImage = UIImage(data: imageData)
                    let roundedImage = dogImage?.roundedImage(cornerRadius: 10)
                    self.image.image = roundedImage
                }
            }
        }
    }
    
    func setColor(rarity: Int) {
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
    
    func decodeJSON(jsonData: Data) {
        // Assume jsonData is the JSON data received from API
        do {
            let cardDetails = try JSONDecoder().decode([CardDetails].self, from: jsonData)
            
            if let firstCard = cardDetails.first {
                var keys = [  ["Good with children", String(firstCard.goodWithChildren)],
                  ["Good with other dogs", String(firstCard.goodWithOtherDogs)],
                  ["Shedding level", String(firstCard.shedding)],
                  ["Grooming level", String(firstCard.grooming)],
                  ["Drooling level", String(firstCard.drooling)],
                  ["Coat length", String(firstCard.coatLength)],
                  ["Good with strangers", String(firstCard.goodWithStrangers)],
                  ["Playfulness level", String(firstCard.playfulness)],
                  ["Protectiveness level", String(firstCard.protectiveness)],
                  ["Trainability level", String(firstCard.trainability)],
                  ["Energy level", String(firstCard.energy)],
                  ["Barking level", String(firstCard.barking)]
                ]
                
                var text = ""
                for key in keys {
                    text += "\(key[0]): \(key[1])/5\n"
                }

                //can get json object to string but it is more efficient to use decodable rather than looping through all characters of the json data
                //let text = String(data: jsonData, encoding: .utf8)
                print(text)
                details.text = text
            } else {
                details.text = ""

            }

        } catch {
            print("Error decoding JSON: \(error)")
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

