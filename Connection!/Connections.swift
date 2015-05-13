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
    let cloud: Cloud
    
    public init(coreDataStack: CoreDataStack, cloud: Cloud) {
        self.coreDataStack = coreDataStack
        self.cloud = cloud
    }
    
    convenience init() {
        self.init(coreDataStack: CoreDataStack.sharedInstance, cloud: Cloud.sharedInstance)
    }
    
    public func addConnection(#name: String, phone: String, success: (Connection) -> (), fail: (NSError) -> ()) {
        cloud.invite(
            success: { [weak self] (json) in
                if let vn = json[Connection.Fields.Vn.rawValue]?.string, let cid = json[Connection.Fields.Cid.rawValue]?.string {
                    let connection = Connection(cid: cid, name: name, phone: phone, vn: vn, insertIntoManagedObjectContext: self!.coreDataStack.mainContext)
                    self!.coreDataStack.saveContext(self!.coreDataStack.mainContext!)
                    success(connection)
                } else {
                    Log.fail("not all objects are in the json response")
                }
            },
            fail: { [weak self] (error) in
                fail(error)
            }
        )
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
