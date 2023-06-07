//
//  CardTableViewCell.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 8/6/2023.
//

import UIKit

class CardTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "tradeCardCell"
    let breedLabel = UILabel()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setup() {
        
        breedLabel.text = "Breed"
        breedLabel.numberOfLines = 0
        breedLabel.contentMode = .center
        
        contentView.addSubview(breedLabel)

        breedLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            breedLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            breedLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }
    
    func configure(with card: TradeCard) {
        breedLabel.text = card.breed
        
        if let originalRarity = card.originalRarity, originalRarity != .common {
            breedLabel.textColor = CardUtil.setColor(rarity: originalRarity.rawValue)
        } else {
            breedLabel.textColor = .black
        }
        
        if let originalRarity = card.originalRarity, originalRarity.rawValue >= 2 {
            breedLabel.font = .boldSystemFont(ofSize: 16)
        } else {
            breedLabel.font = .systemFont(ofSize: 16)
        }
    }


}


