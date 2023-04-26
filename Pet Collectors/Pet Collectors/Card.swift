//
//  Card.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 25/4/2023.
//

import Foundation
import UIKit

enum Rarity: Int {
    case common = 0
    case rare = 1
    case epic = 2
    case legendary = 3
    case mythic = 4
}

enum CodingKeys: String, CodingKey {
    case good_with_children
    case good_with_other_dogs
    case grooming
    case drooling
    case coat_length
    case good_with_strangers
    case playfulness
    case protectiveness
    case trainability
    case energy
    case barking
}


class Card: NSObject {
    
    var breed: String?
    var details: String?
    var rarity: Int?
    var imageURL: String?
    var statistics: Data?
    
    init(breed: String?, details: String?, rarity: Int?, imageURL: String?, statistics: Data?) {
        self.breed = breed
        self.details = details
        self.rarity = rarity
        self.imageURL = imageURL
        self.statistics = statistics
    }
}

extension Card {
    var cardRarity: Rarity {
        get {
            return Rarity(rawValue: self.rarity ?? 1)!
        }
        
        set {
            self.rarity = newValue.rawValue
        }
    }
}
