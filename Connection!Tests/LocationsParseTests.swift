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

    let timeout = 10.0
    
    var cloud: Cloud!
    var parseWrapper: ParseWrapper!
    var locationManagerWrapper: LocationManagerWrapperMock!
    var locations: Locations!
    var connections: Connections!
    
    override func setUp() {
        super.setUp()
        parseWrapper = ParseWrapper()
        cloud = Cloud(parse: parseWrapper)
        locationManagerWrapper = LocationManagerWrapperMock()
        connections = Connections(coreDataStack: CoreDataStackMock(), cloud: cloud)
        locations = Locations(coreDataStack: CoreDataStackMock(), cloud: cloud, locationManagerWrapper: locationManagerWrapper)
    }
    
    override func tearDown() {
        locations = nil
        connections = nil
        locationManagerWrapper = nil
        cloud = nil
        parseWrapper = nil
        super.tearDown()
    }

}
