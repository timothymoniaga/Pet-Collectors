//
//  CardDetails.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 26/4/2023.
//

import Foundation

class CardDetails: Decodable {
    var goodWithChildren: Int
    var goodWithOtherDogs: Int
    var shedding: Int
    var grooming: Int
    var drooling: Int
    var coatLength: Int
    var goodWithStrangers: Int
    var playfulness: Int
    var protectiveness: Int
    var trainability: Int
    var energy: Int
    var barking: Int
    
    enum CodingKeys: String, CodingKey {
        case goodWithChildren = "good_with_children"
        case goodWithOtherDogs = "good_with_other_dogs"
        case shedding = "shedding"
        case grooming = "grooming"
        case drooling = "drooling"
        case coatLength = "coat_length"
        case goodWithStrangers = "good_with_strangers"
        case playfulness = "playfulness"
        case protectiveness = "protectiveness"
        case trainability = "trainability"
        case energy = "energy"
        case barking = "barking"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        goodWithChildren = try container.decode(Int.self, forKey: .goodWithChildren)
        goodWithOtherDogs = try container.decode(Int.self, forKey: .goodWithOtherDogs)
        shedding = try container.decode(Int.self, forKey: .shedding)
        grooming = try container.decode(Int.self, forKey: .grooming)
        drooling = try container.decode(Int.self, forKey: .drooling)
        coatLength = try container.decode(Int.self, forKey: .coatLength)
        goodWithStrangers = try container.decode(Int.self, forKey: .goodWithStrangers)
        playfulness = try container.decode(Int.self, forKey: .playfulness)
        protectiveness = try container.decode(Int.self, forKey: .protectiveness)
        trainability = try container.decode(Int.self, forKey: .trainability)
        energy = try container.decode(Int.self, forKey: .energy)
        barking = try container.decode(Int.self, forKey: .barking)
    }
    
}

