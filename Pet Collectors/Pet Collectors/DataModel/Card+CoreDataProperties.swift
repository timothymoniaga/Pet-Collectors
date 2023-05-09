//
//  Card+CoreDataProperties.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 9/5/2023.
//
//

import Foundation
import CoreData


extension Card {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }

    @NSManaged public var breed: String?
    @NSManaged public var details: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var rarity: Int32
    @NSManaged public var statistics: String?

}

extension Card : Identifiable {

}
