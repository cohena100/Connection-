//
//  Locations.swift
//  Connection!
//
//  Created by Avi Cohen on 5/23/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import Foundation

// MARK: - LocationManagerWrapperDelegate

public protocol LocationsDelegate: class {
    
    func didEnterLocation(#location: Location)
    func didEnterLocationButError(#location: Location, error: NSError)
    
}

public class Locations {

    static let sharedInstance = Connections()
    
    public weak var delegate: LocationsDelegate?
    let coreDataStack: CoreDataStack
    let cloud: Cloud
    let locationManagerWrapper: LocationManagerWrapper
    
    public init(coreDataStack: CoreDataStack, cloud: Cloud, locationManagerWrapper: LocationManagerWrapper) {
        self.coreDataStack = coreDataStack
        self.cloud = cloud
        self.locationManagerWrapper = locationManagerWrapper
    }     
    
    convenience init() {
        self.init(coreDataStack: CoreDataStack.sharedInstance, cloud: Cloud.sharedInstance, locationManagerWrapper: LocationManagerWrapper.sharedInstance)
        locationManagerWrapper.delegate = self
    }
    
    // MARK: Exit Location
    
    public func addEnterLocation(#name: String, latitude: Double, longitude: Double, connections: [Connection], success: (Location) -> (), fail: (NSError) -> ()) {
        Log.call(functionName: __FUNCTION__, message: "with name: \(name) and latitude: \(latitude) and longitude: \(longitude) and connections: \(connections)")
        cloud.addEnterLocation(success: { [weak self] (json) -> () in
            if let accuracy = json[Location.Fields.Accuracy.rawValue]?.float, lid = json[Location.Fields.Lid.rawValue]?.string, radius = json[Location.Fields.Radius.rawValue]?.float {
                let newLocation = Location(accuracy: accuracy, latitude: latitude, lid: lid, longitude: longitude, name: name, radius: radius, type: Location.LocationType.Enter, connections: Set(connections), insertIntoManagedObjectContext: self!.coreDataStack.mainContext!)
                self!.coreDataStack.save()
                self!.locationManagerWrapper.addEnterLocation(lid: lid, latitude: latitude, longitude: longitude, radius: radius, accuracy: accuracy)
                success(newLocation)
            } else {
                Log.fail(functionName: __FUNCTION__, message: "not all objects are in the json response")
                let description = NSLocalizedString("Can't add an enter location connection.", comment: "Can't add an enter connection.")
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
    
    // MARK: Get Locations
    
    public func getLocations() -> [Location] {
        Log.call(functionName: __FUNCTION__, message: "")
        var error: NSError?
        let locations = coreDataStack.fetch("Location", error: &error) as? [Location]
        if let locations = locations {
        } else {
            Log.fail(functionName: __FUNCTION__, message: "Could not fetch locations with error: \(error)")
            return []
        }
        return locations!
    }
    
    public func deleteLocation(#lid: String) -> Location? {
        let predicate =  NSPredicate(format: "%K LIKE %@", "lid", lid)
        var error: NSError?
        let location = coreDataStack.fetchOne("Location", predicate: predicate, error: &error) as? Location
        if let location = location {
        } else {
            Log.warn(functionName: __FUNCTION__, message: "Could not fetch location with error: \(error)")
            return nil
        }
        coreDataStack.deleteObject(location!)
        return location!
    }

}

// MARK: - LocationManagerWrapperDelegate

extension Locations: LocationManagerWrapperDelegate {
    
    public func didEnterLocation(#lid: String) {
        let location = deleteLocation(lid: lid)
        if let location = location {
        } else {
            Log.warn(functionName: __FUNCTION__, message: "There should have been a location to delete")
            return
        }
        let cids = Array(lazy(location!.connections as! Set<Connection>).map { (connection: Connection) -> String in
            return connection.cid
        })
        cloud.didEnterLocation(cids: cids, success: { [unowned self] (json) -> () in
            self.delegate?.didEnterLocation(location: location!)
        }) { [unowned self] (error) -> () in
            self.delegate?.didEnterLocationButError(location: location!, error: error)
        }
    }
    
}
