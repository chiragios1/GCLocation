//
//  LocationUpdateFailur+CoreDataProperties.swift
//  GCLocation
//
//  Created by admin on 08/05/23.
//
//

import Foundation
import CoreData


extension LocationUpdateFailur {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationUpdateFailur> {
        return NSFetchRequest<LocationUpdateFailur>(entityName: "LocationUpdateFailur")
    }

    @NSManaged public var customer_id: String?
    @NSManaged public var geo_hash: String?
    @NSManaged public var tstmp: Int16

}
