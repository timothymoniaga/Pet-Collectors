//
//  CardTableViewCell.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 8/6/2023.
//

import UIKit
/**
 Table view cell for displaying trade card breed information.

 The `CardTableViewCell` class is a custom `UITableViewCell` subclass that provides a cell layout for displaying trade card breed information. It includes a label to display the breed name of the trade card. The cell can be configured with a `TradeCard` object to update the breed information.

 This cell is typically used in a table view to show a list of trade cards and their corresponding breed names.
 */
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
    
    /**
     Sets up the UI elements and their constraints on the cell.
     */
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
    
    /**
     Configures the cell with the given `TradeCard` object.
     
     - Parameters:
        - card: The `TradeCard` object to configure the cell with.
     */
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

