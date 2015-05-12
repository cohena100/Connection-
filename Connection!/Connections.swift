//
//  Connections.swift
//  Connection!
//
//  Created by Avi Cohen on 5/9/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import UIKit
import CoreData

public class Connections {
   
    static let sharedInstance = Connections()
    let coreDataStack: CoreDataStack
    
    public init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    convenience init() {
        self.init(coreDataStack: CoreDataStack.sharedInstance)
    }
    
    public func addConnection(#cid: String, name: String, phone: String, vn: String) -> Connection {
        let connection = Connection(cid: cid, name: name, phone: phone, vn: vn, insertIntoManagedObjectContext: coreDataStack.mainContext)
        coreDataStack.saveContext(coreDataStack.mainContext!)
        return connection
    }
    
    public func connections() -> [Connection] {
        let fetchRequest = NSFetchRequest(entityName:"Connection")
        var error: NSError?
        if let results = coreDataStack.mainContext!.executeFetchRequest(fetchRequest, error: &error) as? [Connection] {
            return results
        }
        if let error = error {
            Log.fail("Could not fetch \(error), \(error.userInfo)")
        }
        return []
    }
    
}
