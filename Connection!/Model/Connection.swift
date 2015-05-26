//
//  Connection.swift
//  Connection!
//
//  Created by Avi Cohen on 5/12/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import Foundation
import CoreData

public class Connection: NSManagedObject {

    enum Fields: String {
        case Cid = "cid"
        case Name = "name"
        case Phone = "phone"
        case Vn = "vn"
    }
    
    @NSManaged public var cid: String
    @NSManaged public var name: String
    @NSManaged public var phone: String
    @NSManaged public var vn: String
    @NSManaged public var created: NSDate
    @NSManaged public var locations: NSSet

    convenience init(cid: String, name: String, phone: String, vn: String, coreDataStack: CoreDataStack) {
        let entity = NSEntityDescription.entityForName("Connection", inManagedObjectContext: coreDataStack.mainContext!)!
        self.init(entity: entity, insertIntoManagedObjectContext: coreDataStack.mainContext!)
        self.cid = cid
        self.name = name
        self.phone = phone
        self.vn = vn
        self.created = NSDate()
        coreDataStack.save()
    }
    
}
