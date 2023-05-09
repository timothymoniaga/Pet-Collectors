//
//  PackTImer+CoreDataProperties.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 10/5/2023.
//
//

import Foundation
import CoreData


extension PackTImer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PackTImer> {
        return NSFetchRequest<PackTImer>(entityName: "PackTImer")
    }

    @NSManaged public var startDate: Date?

}

extension PackTImer : Identifiable {

}
