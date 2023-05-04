//
//  Locationwithtimestamp+CoreDataProperties.swift
//  
//
//  Created by admin on 06/04/23.
//
//

import Foundation
import CoreData


extension Locationwithtimestamp {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Locationwithtimestamp> {
        return NSFetchRequest<Locationwithtimestamp>(entityName: "Locationwithtimestamp")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var applicationState : String

}
