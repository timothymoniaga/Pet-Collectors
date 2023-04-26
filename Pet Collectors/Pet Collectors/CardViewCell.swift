//
//  CardViewCell.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 25/4/2023.
//

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
        self.addSubview(image)
        
        
        details.translatesAutoresizingMaskIntoConstraints = false
        details.numberOfLines = 0
        self.addSubview(details)
        
        NSLayoutConstraint.activate([
            details.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            details.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
            details.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10),
            details.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -150)
        ])
    }
    
    func configure(with card: Card) {
        breed.text = card.breed
        //details.text = card.details
        // print(String(data: card.statistics!, encoding: .utf8))
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
                    self.image.image = UIImage(data: imageData)
                }
            }
        }
    }
    
    func setColor(rarity: Int) {
        switch rarity {
        case 0:
            self.backgroundColor = .lightGray
        case 1:
            self.backgroundColor = .systemBlue
        case 2:
            self.backgroundColor = .purple
        case 3:
            self.backgroundColor = .yellow
        case 4:
            self.backgroundColor = .systemRed
        default:
            self.backgroundColor = .lightGray
        }
    }
    
    func decodeJSON(jsonData: Data) {
        // Assume jsonData is the JSON data received from API
        do {
            let cardDetails = try JSONDecoder().decode([CardDetails].self, from: jsonData)
            
            print(cardDetails)
            // Accessing properties
            let name = cardDetails[0].grooming
            
            // Displaying data in UI
            details.text = String(name)
            print(name)
            // ...
        } catch {
            print("Error decoding JSON: \(error)")
        }

    }
    
}
