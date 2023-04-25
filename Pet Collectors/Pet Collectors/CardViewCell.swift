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
    
    func getRandomColor() -> UIColor {
        let randomRed = CGFloat.random(in: 0...1)
        let randomGreen = CGFloat.random(in: 0...1)
        let randomBlue = CGFloat.random(in: 0...1)
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    func configure(with card: Card) {
        breed.text = card.breed
        loadImageFromURL(urlString: card.imageURL ?? "")
        details.text = card.details
        self.backgroundColor = card.colour
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
    
}
