//
//  Card.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 25/4/2023.
//

import Foundation
import UIKit

class Card: NSObject {
    
    var breed: String?
    var details: String?
    var colour: UIColor?
    var imageURL: String?
    var statistics: [String: String]?
    
    init(breed: String, details: String, colour: UIColor, imageURL: String) {
        self.breed = breed
        self.details = details
        self.colour = colour
        self.imageURL = imageURL
    }
}
