//
//  Card.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 8/6/2023.
//

import Foundation
import Firebase

class TradeCard {
    var breed: String
    var statistics: String
    var rarity: Rarity
    var details: String
    var imageURL: String
    var cardReference: DocumentReference
    var originalRarity: Rarity?
    
    init(breed: String, statistics: String, rarity: Rarity, details: String, imageURL: String, cardReference: DocumentReference) {
        self.breed = breed
        self.statistics = statistics
        self.rarity = rarity
        self.details = details
        self.imageURL = imageURL
        self.cardReference = cardReference
    }
}
