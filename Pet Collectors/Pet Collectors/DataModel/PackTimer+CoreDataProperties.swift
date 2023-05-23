//
//  PackTImer+CoreDataProperties.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 10/5/2023.
//
//

import Foundation
import CoreData


extension PackTimer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PackTimer> {
        return NSFetchRequest<PackTimer>(entityName: "PackTimer")
    }

    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date


}

extension PackTimer : Identifiable {

}
