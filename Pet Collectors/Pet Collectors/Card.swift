//
//  Card.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 25/4/2023.
//

import Foundation
import UIKit


class Card2: NSObject {
    
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

//extension Card {
//    var cardRarity: Rarity {
//        get {
//            return Rarity(rawValue: self.rarity ?? 1)!
//        }
//        
//        set {
//            self.rarity = newValue.rawValue
//        }
//    }
//}
