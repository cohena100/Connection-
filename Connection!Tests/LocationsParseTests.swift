//
//  LocationsParseTests.swift
//  Connection!
//
//  Created by Avi Cohen on 5/26/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import UIKit
import XCTest
import Connection_

class LocationsParseTests: XCTestCase {

    let locationName1 = "locationName1"
    let latitude1 = 1.0
    let longitude1 = 1.0
    let name1 = "name1"
    let phone1 = "phone1"
    
    let locationName2 = "locationName2"
    let latitude2 = 2.0
    let longitude2 = 2.0
    let name2 = "name2"
    let phone2 = "phone2"

    let timeout = 10.0
    
    var cloud: Cloud!
    var parseWrapper: ParseWrapper!
    var locationManagerWrapper: LocationManagerWrapperMock!
    var locations: Locations!
    var connections: Connections!
    var didEnterLocationWasCalled = false
    var didEnterLocationButErrorWasCalled = false
    var expectation: XCTestExpectation!
   
    override func setUp() {
        super.setUp()
        parseWrapper = ParseWrapper()
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
        didEnterLocationButErrorWasCalled = false
        super.tearDown()
    }

    func cleanup() {
        let expectation = self.expectationWithDescription("cleanup")
        self.connections.deleteLastConnection(
            success: { (connection) -> () in
                expectation.fulfill()
            },
            fail: { (error) -> () in
                XCTFail("should not end up with an error")
            }
        )
        self.waitForExpectationsWithTimeout(self.timeout) { (error) in
            if let error = error {
                XCTFail("should not end up with an error")
                return
            }
        }
    }
    
    func testAddEnterLocation_anEnterLocation_enterLocationAdded() {
        let expectation = expectationWithDescription("invite user")
        connections.invite(name: name1, phone: phone1, success: { (connection) -> () in
                expectation.fulfill()
            }) { (error) -> () in
                XCTFail("should not end up with an error")
        }
        waitForExpectationsWithTimeout(timeout) { [unowned self] (error) in
            if let error = error {
                XCTFail("should not end up with an error")
                return
            }
            var allConnections: [Connection]?
            let expectation = self.expectationWithDescription("get connections")
            self.connections.getConnections(success: { (connections) -> () in
                allConnections = connections
                expectation.fulfill()
            }, fail: { (error) -> () in
                XCTFail("should not end up with an error")
            })
            self.waitForExpectationsWithTimeout(self.timeout) { [unowned self] (error) in
                if let error = error {
                    XCTFail("should not end up with an error")
                    return
                }
                let expectation = self.expectationWithDescription("add enter location")
                self.locations.addEnterLocation(name: self.name1, latitude: self.latitude1, longitude: self.longitude2, connections: allConnections!, success: { (location) -> () in
                    expectation.fulfill()
                }, fail: { (error) -> () in
                    XCTFail("should not end up with an error")
                })
                self.waitForExpectationsWithTimeout(self.timeout) { [unowned self] (error) in
                    if let error = error {
                        XCTFail("should not end up with an error")
                        return
                    }
                    let allLocations = self.locations.getLocations()
                    XCTAssertEqual(allLocations.count, 1, "there should be only one location")
                    self.cleanup()
                }
            }
        }
    }
    
    func testLocationEntered_addEnterLocationAndEnterIt_didEnterLocationDelegateCalled() {
        let expectation = expectationWithDescription("invite user")
        connections.invite(name: name1, phone: phone1, success: { (connection) -> () in
            expectation.fulfill()
            }) { (error) -> () in
                XCTFail("should not end up with an error")
        }
        waitForExpectationsWithTimeout(timeout) { [unowned self] (error) in
            if let error = error {
                XCTFail("should not end up with an error")
                return
            }
            var allConnections: [Connection]?
            let expectation = self.expectationWithDescription("get connections")
            self.connections.getConnections(success: { (connections) -> () in
                allConnections = connections
                expectation.fulfill()
                }, fail: { (error) -> () in
                    XCTFail("should not end up with an error")
            })
            self.waitForExpectationsWithTimeout(self.timeout) { [unowned self] (error) in
                if let error = error {
                    XCTFail("should not end up with an error")
                    return
                }
                let expectation = self.expectationWithDescription("add enter location")
                var lid: String = ""
                self.locations.addEnterLocation(name: self.name1, latitude: self.latitude1, longitude: self.longitude2, connections: allConnections!, success: { (location) -> () in
                    lid = location.lid
                    expectation.fulfill()
                    }, fail: { (error) -> () in
                        XCTFail("should not end up with an error")
                })
                self.waitForExpectationsWithTimeout(self.timeout) { [unowned self] (error) in
                    if let error = error {
                        XCTFail("should not end up with an error")
                        return
                    }
                    self.expectation = self.expectationWithDescription("did enter location")
                    self.locationManagerWrapper.didEnterLocation(lid: lid)
                    self.waitForExpectationsWithTimeout(self.timeout) { (error) in
                        if let error = error {
                            XCTFail("should not end up with an error")
                            return
                        }
                        self.cleanup()
                    }
                }
            }
        }
    }
    
}

extension LocationsParseTests: LocationsDelegate {
    
    func didEnterLocation(#location: Location) {
        didEnterLocationWasCalled = true
        expectation.fulfill()
    }
    
    func didEnterLocationButError(#location: Location, error: NSError) {
        didEnterLocationButErrorWasCalled = true
        expectation.fulfill()
    }
    
}
