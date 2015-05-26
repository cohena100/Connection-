//
//  Location.swift
//  Connection!
//
//  Created by Avi Cohen on 5/23/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import Foundation
import CoreData

public class Location: NSManagedObject {

    public enum Fields: String {
        case Accuracy = "accuracy"
        case Latitude = "latitude"
        case Lid = "lid"
        case Longitude = "longitude"
        case Name = "name"
        case Radius = "radius"
    }
    
    public enum LocationType: Int {
        case None = 0
        case Enter
        case Exit
    }
    
    @NSManaged public var accuracy: NSNumber
    @NSManaged public var created: NSDate
    @NSManaged public var latitude: NSNumber
    @NSManaged public var lid: String
    @NSManaged public var longitude: NSNumber
    @NSManaged public var name: String
    @NSManaged public var radius: NSNumber
    @NSManaged public var started: NSNumber
    @NSManaged public var type: NSNumber
    @NSManaged public var connections: NSSet

    convenience init(accuracy: Float, latitude: Double, lid: String, longitude: Double, name: String, radius: Float, type: LocationType, connections: Set<Connection>, insertIntoManagedObjectContext context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Location", inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        self.accuracy = accuracy
        self.created = NSDate()
        self.latitude = latitude
        self.lid = lid
        self.longitude = longitude
        self.name = name
        self.radius = radius
        switch type {
        case .Enter:
            self.started = true
        default:
            self.started = false
        }
        self.type = type.rawValue
        self.mutableSetValueForKey("connections").unionSet(connections)
    }
    
}
