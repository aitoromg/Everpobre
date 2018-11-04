//
//  Location+CoreDataProperties.swift
//  Everpobre
//
//  Created by Aitor Garcia on 03/11/2018.
//  Copyright © 2018 Charles Moncada. All rights reserved.
//

import Foundation
import CoreData


extension Location {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }
    
    @NSManaged public var note: Note?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    
}
