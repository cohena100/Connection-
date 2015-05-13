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
                    let description = NSLocalizedString("Can't add connection.", comment: "Can't add connection to the circle of connections.")
                    let reason = NSLocalizedString("Got an incorrect response from the server.", comment: "Got an incorrect response from the server.")
                    let recovery = NSLocalizedString("Please try again later.", comment: "Please try the last operation again later.")
                    let userInfo = [NSLocalizedDescriptionKey: description, NSLocalizedFailureReasonErrorKey: reason, NSLocalizedRecoverySuggestionErrorKey: recovery]
                    let error = NSError(domain: Cloud.Error.domain, code: Cloud.Error.code, userInfo: userInfo)
                    fail(error)
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
