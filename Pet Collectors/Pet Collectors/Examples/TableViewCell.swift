//
//  TableViewCell.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 24/4/2023.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var contentViewCell: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentViewCell.clipsToBounds = false
        contentViewCell.layer.cornerRadius = 15
        contentViewCell.backgroundColor = UIColor.white
        
        self.backgroundColor = UIColor(red: 247.0/255, green: 247.0/255, blue: 247.0/255, alpha: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
