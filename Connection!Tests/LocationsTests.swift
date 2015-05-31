//
//  LocationsTests.swift
//  Connection!
//
//  Created by Avi Cohen on 5/23/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import UIKit
import XCTest
import Connection_

class LocationsTests: XCTestCase, LocationsDelegate {
    
    let locationName1 = "locationName1"
    let latitude1 = 1.0
    let longitude1 = 1.0
    let lid1 = "lid1"
    let name1 = "name1"
    let phone1 = "phone1"
    let vn1 = "vn1"
    let cid1 = "cid1"
    
    let locationName2 = "locationName2"
    let latitude2 = 2.0
    let longitude2 = 2.0
    let lid2 = "lid2"
    let name2 = "name2"
    let phone2 = "phone2"
    let vn2 = "vn2"
    let cid2 = "cid2"
    
    let accuracy: Float = 50.0
    let radius: Float = 70.0
    
    var cloud: Cloud!
    var parseWrapper: ParseWrapperMock!
    var locationManagerWrapper: LocationManagerWrapperMock!
    var locations: Locations!
    var connections: Connections!
    var didEnterLocationWasCalled = false
    
    override func setUp() {
        super.setUp()
        parseWrapper = ParseWrapperMock()
        cloud = Cloud(parse: parseWrapper)
        locationManagerWrapper = LocationManagerWrapperMock()
        connections = Connections(coreDataStack: CoreDataStackMock(), cloud: cloud)
        locations = Locations(coreDataStack: CoreDataStackMock(), cloud: cloud, locationManagerWrapper: locationManagerWrapper)
        locationManagerWrapper.delegate = locations
        locations.delegate = self
    }
    
    override func tearDown() {
        locations = nil
        connections = nil
        locationManagerWrapper = nil
        cloud = nil
        parseWrapper = nil
        didEnterLocationWasCalled = false
        super.tearDown()
    }
    
    func inviteConnections(amount: Int) {
        if amount <= 0 {
            return
        }
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.invite(name: name1, phone: phone1,
            success: { (connection) -> () in
            }) { (error) -> () in
                XCTFail("this method call should not end up with an error")
        }
        if amount <= 1 {
            return
        }
        parseWrapper.json = JSONValue.fromObject(["vn": vn2, "cid": cid2])
        connections.invite(name: name2, phone: phone2,
            success: { (connection) -> () in
            }) { (error) -> () in
                XCTFail("this method call should not end up with an error")
        }
    }
    
    func getConnections(success: ([Connection]) -> ()) {
        connections.getConnections(
            success: { [unowned self] connections in
                success(connections)
            },
            fail: { (error) -> () in
                XCTFail("this method call should not end up with an error")
            }
        )
    }
    
    func addLocation(amount: Int) {
        if amount <= 0 {
            return
        }
        if amount <= 1 {
            inviteConnections(1)
            parseWrapper.json = JSONValue.fromObject([cid1])
            getConnections { [unowned self] connections in
                self.parseWrapper.json = JSONValue.fromObject(["accuracy": self.accuracy, "lid": self.lid1, "radius": self.radius])
                self.locations.addEnterLocation(name: self.locationName1, latitude: self.latitude1, longitude: self.longitude1, connections: connections,
                    success: { (location) -> () in
                    }) { (error) -> () in
                        XCTFail("this method call should not end up with an error")
                }
            }
            return
        }
        if amount <= 2 {
            inviteConnections(2)
            parseWrapper.json = JSONValue.fromObject([cid1, cid2])
            getConnections { [unowned self] connections in
                self.parseWrapper.json = JSONValue.fromObject(["accuracy": self.accuracy, "lid": self.lid1, "radius": self.radius])
                self.locations.addEnterLocation(name: self.locationName1, latitude: self.latitude1, longitude: self.longitude1, connections: connections,
                    success: { (location) -> () in
                    }) { (error) -> () in
                        XCTFail("this method call should not end up with an error")
                }
                self.parseWrapper.json = JSONValue.fromObject(["accuracy": self.accuracy, "lid": self.lid2, "radius": self.radius])
                self.locations.addEnterLocation(name: self.locationName2, latitude: self.latitude2, longitude: self.longitude2, connections: connections,
                    success: { (location) -> () in
                    }) { (error) -> () in
                        XCTFail("this method call should not end up with an error")
                }
            }
            return
        }
    }
    
    func testAddEnterLocation_anEnterLocation_enterLocationAdded() {
        inviteConnections(1)
        parseWrapper.json = JSONValue.fromObject([cid1])
        getConnections { [unowned self] connections in
            self.parseWrapper.json = JSONValue.fromObject(["accuracy": self.accuracy, "lid": self.lid1, "radius": self.radius])
            self.locations.addEnterLocation(name: self.locationName1, latitude: self.latitude1, longitude: self.longitude1, connections: connections,
                success: { (location) -> () in
                }) { (error) -> () in
                    XCTFail("this method call should not end up with an error")
            }
            let loctions = self.locations.getLocations()
            XCTAssertEqual(loctions.count, 1, "there should be only one location")
            let location = loctions[0]
            XCTAssertEqual(location.accuracy.floatValue, self.accuracy, "accuracy is not correct")
            XCTAssertEqual(location.latitude.doubleValue, self.latitude1, "latitude is not correct")
            XCTAssertEqual(location.lid, self.lid1, "lid is not correct")
            XCTAssertEqual(location.longitude.doubleValue, self.longitude1, "longitude is not correct")
            XCTAssertEqual(location.name, self.locationName1, "name is not correct")
            XCTAssertEqual(location.radius.floatValue, self.radius, "radius is not correct")
            XCTAssertTrue(location.started.boolValue, "started is not correct")
            XCTAssertEqual(location.type.integerValue, Location.LocationType.Enter.rawValue, "type is not correct")
            XCTAssertEqual(location.connections.count, 1, "started is not correct")
        }
    }
    
    func testAddEnterLocation_anEnterLocationWithManyConnections_enterLocationAdded() {
        inviteConnections(2)
        parseWrapper.json = JSONValue.fromObject([cid1, cid2])
        getConnections() { [unowned self] connections in
            self.parseWrapper.json = JSONValue.fromObject(["accuracy": self.accuracy, "lid": self.lid1, "radius": self.radius])
            self.locations.addEnterLocation(name: self.locationName1, latitude: self.latitude1, longitude: self.longitude1, connections: connections,
                success: { (location) -> () in
                }) { (error) -> () in
                    XCTFail("this method call should not end up with an error")
            }
            self.parseWrapper.json = JSONValue.fromObject(["accuracy": self.accuracy, "lid": self.lid2, "radius": self.radius])
            self.locations.addEnterLocation(name: self.locationName2, latitude: self.latitude2, longitude: self.longitude2, connections: connections,
                success: { (location) -> () in
                }) { (error) -> () in
                    XCTFail("this method call should not end up with an error")
            }
            let locations = self.locations.getLocations()
        }
        parseWrapper.json = JSONValue.fromObject([cid1, cid2])
        getConnections() { [unowned self] connections in
            let connection = connections[0]
            XCTAssertEqual(connection.locations.count, 2, "there should be exactly two locations")
        }
    }
    
    func testDeleteLocation_DeleteAddedLocation_deleted() {
        addLocation(1)
        locations.deleteLocation(lid: lid1)
        let allLocations = locations.getLocations()
        XCTAssertEqual(allLocations.count, 0, "there should be no locations")
    }
    
    func testDeleteLocation_DeleteOneOfTwoLocations_onlyOneLocation() {
        addLocation(2)
        locations.deleteLocation(lid: lid2)
        let allLocations = locations.getLocations()
        XCTAssertEqual(allLocations.count, 1, "there should be exactly one location")
    }
    
    func testLocationEntered_addEnterLocationAndEnterIt_noLocationsRemaining () {
        addLocation(1)
        locationManagerWrapper.didEnterLocation(lid: lid1)
        XCTAssertTrue(didEnterLocationWasCalled, "delgate method should have been called")
    }

}

extension LocationsTests: LocationsDelegate {
    
    func didEnterLocation(#location: Location) {
        didEnterLocationWasCalled = true
    }
    
}
