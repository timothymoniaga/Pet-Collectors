//
//  Timer+CoreDataProperties.swift
//  Pet Collectors
//
//  Created by Timothy Moniaga on 9/5/2023.
//
//

import Foundation
import CoreData


extension Timer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Timer> {
        return NSFetchRequest<Timer>(entityName: "Timer")
    }

    @NSManaged public var startDate: Date?

}

extension Timer : Identifiable {

}
