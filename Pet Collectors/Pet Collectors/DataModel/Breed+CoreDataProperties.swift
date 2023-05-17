//
//  Breed+CoreDataProperties.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 17/5/2023.
//
//

import Foundation
import CoreData

extension Breed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Breed> {
        return NSFetchRequest<Breed>(entityName: "Breed")
    }

    @NSManaged public var name: String?

}

extension Breed : Identifiable {

}
