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
    
    // MARK: Invite
    
    public func invite(#name: String, phone: String, success: (Connection) -> (), fail: (NSError) -> ()) {
        Log.call(functionName: __FUNCTION__, message: "with name: \(name) and phone: \(phone)")
        if let connection = getConnection(phone: phone) {
            inviteAgain(connection: connection, success: success, fail: fail)
        } else {
            inviteNew(name: name, phone: phone, success: success, fail: fail)
        }
    }
    
    private func inviteNew(#name: String, phone: String, success: (Connection) -> (), fail: (NSError) -> ()) {
        Log.call(functionName: __FUNCTION__, message: "with name: \(name) and phone: \(phone)")
        cloud.invite(
            success: { [weak self] (json) in
                if let vn = json[Connection.Fields.Vn.rawValue]?.string, cid = json[Connection.Fields.Cid.rawValue]?.string {
                    let connection = Connection(cid: cid, name: name, phone: phone, vn: vn, insertIntoManagedObjectContext: self!.coreDataStack.mainContext!)
                    self!.coreDataStack.saveContext(self!.coreDataStack.mainContext!)
                    success(connection)
                } else {
                    Log.fail(functionName: __FUNCTION__, message: "not all objects are in the json response")
                    let description = NSLocalizedString("Can't add connection.", comment: "Can't add connection to the circle of connections.")
                    let reason = NSLocalizedString("Got an incorrect response from the server.", comment: "Got an incorrect response from the server.")
                    let recovery = NSLocalizedString("Please try again later.", comment: "Please try the last operation again later.")
                    let userInfo = [NSLocalizedDescriptionKey: description, NSLocalizedFailureReasonErrorKey: reason, NSLocalizedRecoverySuggestionErrorKey: recovery]
                    let error = NSError(domain: Cloud.Error.domain, code: Cloud.Error.code, userInfo: userInfo)
                    fail(error)
                }
            }) { [weak self] (error) in
                fail(error)
        }
    }
    
    private func inviteAgain(#connection: Connection, success: (Connection) -> (), fail: (NSError) -> ()) {
        Log.call(functionName: __FUNCTION__, message: "with connection: \(connection)")
        cloud.inviteAgain(cid: connection.cid,
            success: { [weak self] (json) in
                if let vn = json[Connection.Fields.Vn.rawValue]?.string, cid = json[Connection.Fields.Cid.rawValue]?.string {
                    connection.vn = vn
                    self!.coreDataStack.saveContext(self!.coreDataStack.mainContext!)
                    success(connection)
                } else {
                    Log.fail(functionName: __FUNCTION__, message: "not all objects are in the json response")
                    let description = NSLocalizedString("Can't add connection.", comment: "Can't add connection to the circle of connections.")
                    let reason = NSLocalizedString("Got an incorrect response from the server.", comment: "Got an incorrect response from the server.")
                    let recovery = NSLocalizedString("Please try again later.", comment: "Please try the last operation again later.")
                    let userInfo = [NSLocalizedDescriptionKey: description, NSLocalizedFailureReasonErrorKey: reason, NSLocalizedRecoverySuggestionErrorKey: recovery]
                    let error = NSError(domain: Cloud.Error.domain, code: Cloud.Error.code, userInfo: userInfo)
                    fail(error)
                }
            }) { [weak self] (error) in
                fail(error)
        }
    }
    
    // MARK: Get Connections
    
    public func getConnections(#success: ([Connection]) -> (), fail: (NSError) -> ()) {
        Log.call(functionName: __FUNCTION__, message: "")
        let fetchRequest = NSFetchRequest(entityName:"Connection")
        var error: NSError?
        let connections = coreDataStack.mainContext!.executeFetchRequest(fetchRequest, error: &error) as? [Connection]
        if let connections = connections {
        } else {
            Log.fail(functionName: __FUNCTION__, message: "Could not fetch connections with error: \(error)")
            fail(error!)
            return
        }
        cloud.connections(success: { [weak self] (json) -> () in
            let syncedConnections = self!.syncConnections(connections: connections!, cloudConnectionsJSON: json)
            success(syncedConnections)
            }) { (error) -> () in
                fail(error)
        }
    }
    
    private func syncConnections(#connections: [Connection], cloudConnectionsJSON json: JSONValue) -> [Connection]{
        let syncedConnections = connections.filter() {
            for cid in json {
                if $0.cid == cid.string {
                    return true
                }
            }
            return false
        }
        return syncedConnections
    }
    
    private func getConnection(#phone: String) -> Connection? {
        Log.call(functionName: __FUNCTION__, message: "with phone: \(phone)")
        let request = NSFetchRequest(entityName:"Connection")
        request.predicate =  NSPredicate(format: "%K LIKE %@", "phone", phone)
        var error: NSError?
        let connections = coreDataStack.mainContext!.executeFetchRequest(request, error: &error) as? [Connection]
        if let connections = connections {
        } else {
            Log.fail(functionName: __FUNCTION__, message: "Could not fetch connections with error: \(error)")
            return nil
        }
        if connections!.count == 0 {
            return nil
        }
        return connections![0]
    }
    
    // MARK: Delete Connections
    
    public func deleteLastConnection(#success: (Connection) -> (), fail: (NSError) -> ()) {
        Log.call(functionName: __FUNCTION__, message: "")
        let request = NSFetchRequest(entityName: "Connection")
        let sortDescriptor = NSSortDescriptor(key: "created", ascending: false)
        request.sortDescriptors = [sortDescriptor]
        request.fetchLimit = 1
        var error: NSError?
        let connections = coreDataStack.mainContext!.executeFetchRequest(request, error: &error) as? [Connection]
        if let connections = connections {
        } else {
            Log.fail(functionName: __FUNCTION__, message: "fetching last added contact ended with error: \(error)")
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
            Log.warn(functionName: __FUNCTION__, message: "it appears that there are no connections at all")
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
        Log.call(functionName: __FUNCTION__, message: "")
        cloud.deleteConnection(connection,
            success: { [weak self] (json) in
                self!.coreDataStack.mainContext!.deleteObject(connection)
                self!.coreDataStack.saveContext(self!.coreDataStack.mainContext!)
                success(connection)
            }) { [weak self] (error) in
                fail(error)
        }
    }
    
    // MARK: Accept Invitation
    
    public func acceptInvitation(#name: String, phone: String, vn: String, success: (Connection) -> (), fail: (NSError) -> ()) {
        let cid: String?
        let connection = getConnection(phone: phone)
        if let connection = connection {
            cid = connection.cid
        } else {
            cid = nil
        }
        cloud.acceptInvitation(vn: vn, cid: cid, success: { [weak self] (json) -> () in
            if let vn = json[Connection.Fields.Vn.rawValue]?.string, cid = json[Connection.Fields.Cid.rawValue]?.string {
                if let connection = connection {
                    self!.coreDataStack.mainContext!.deleteObject(connection)
                    self!.coreDataStack.saveContext(self!.coreDataStack.mainContext!)
                }
                let connection = Connection(cid: cid, name: name, phone: phone, vn: vn, insertIntoManagedObjectContext: self!.coreDataStack.mainContext!)
                self!.coreDataStack.saveContext(self!.coreDataStack.mainContext!)
                success(connection)
            } else {
                Log.fail(functionName: __FUNCTION__, message: "not all objects are in the json response")
                let description = NSLocalizedString("Can't accept invitation.", comment: "Can't accept an invitation.")
                let reason = NSLocalizedString("Got an incorrect response from the server.", comment: "Got an incorrect response from the server.")
                let recovery = NSLocalizedString("Please try again later.", comment: "Please try the last operation again later.")
                let userInfo = [NSLocalizedDescriptionKey: description, NSLocalizedFailureReasonErrorKey: reason, NSLocalizedRecoverySuggestionErrorKey: recovery]
                let error = NSError(domain: Cloud.Error.domain, code: Cloud.Error.code, userInfo: userInfo)
                fail(error)
            }
            }) { (error) -> () in
                fail(error)
        }
    }
}
