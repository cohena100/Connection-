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
        Log.call("with name: \(name) and phone: \(phone)")
        cloud.invite(
            success: { [weak self] (json) in
                if let vn = json[Connection.Fields.Vn.rawValue]?.string, let cid = json[Connection.Fields.Cid.rawValue]?.string {
                    let connection = Connection(cid: cid, name: name, phone: phone, vn: vn, insertIntoManagedObjectContext: self!.coreDataStack.mainContext!)
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
        Log.call("")
        let fetchRequest = NSFetchRequest(entityName:"Connection")
        var error: NSError?
        if let results = coreDataStack.mainContext!.executeFetchRequest(fetchRequest, error: &error) as? [Connection] {
            return results
        }
        if let error = error {
            Log.fail("Could not fetch connections with error: \(error)")
        }
        return []
    }
    
    public func deleteLastConnection(#success: (Connection) -> (), fail: (NSError) -> ()) {
        Log.call("")
        let request = NSFetchRequest(entityName: "Connection")
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 1
        var error: NSError?
        let connections = coreDataStack.mainContext!.executeFetchRequest(request, error: &error) as? [Connection]
        if let connections = connections {
        } else {
            Log.fail("fetching last added contact ended with error: \(error)")
            fail(error!)
            return
        }
        let description = NSLocalizedString("Can't delete connection.", comment: "Can't delete connection from the circle of connections.")
        let reason = NSLocalizedString("Got an internal error.", comment: "Got an internal error.")
        let recovery = NSLocalizedString("Please try again later.", comment: "Please try the last operation again later.")
        let userInfo = [NSLocalizedDescriptionKey: description, NSLocalizedFailureReasonErrorKey: reason, NSLocalizedRecoverySuggestionErrorKey: recovery]
        error = NSError(domain: Cloud.Error.domain, code: Cloud.Error.code, userInfo: userInfo)
        if connections!.count > 0 {
        } else {
            Log.warn("it appears that there are no connections at all")
            fail(error!)
            return
        }
        let connection = connections![0]
        deleteConnection(connection, success: { (connection) -> () in
            success(connection)
        }) { (error) -> () in
            fail(error)
        }
    }
    
    private func deleteConnection(connection: Connection, success: (Connection) -> (), fail: (NSError) -> ()) {
        Log.call("")
        cloud.deleteConnection(connection,
            success: { [weak self] (json) in
                self!.coreDataStack.mainContext!.deleteObject(connection)
                self!.coreDataStack.saveContext(self!.coreDataStack.mainContext!)
                success(connection)
            },
            fail: { [weak self] (error) in
                fail(error)
            }
        )
    }
    
}
