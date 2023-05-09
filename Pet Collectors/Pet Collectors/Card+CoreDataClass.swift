//
//  Card+CoreDataClass.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 9/5/2023.
//
//

import Foundation
import CoreData

enum Rarity: Int32 {
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

@objc(Card)
public class Card: NSManagedObject {

}

extension Card {
    var cardRarity: Rarity {
        get {
            return Rarity(rawValue: self.rarity)!
        }
        set {
            self.rarity = newValue.rawValue
        }
    }
}

