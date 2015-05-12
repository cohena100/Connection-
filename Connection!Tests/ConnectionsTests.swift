//
//  ConnectionsTests.swift
//  Connection!
//
//  Created by Avi Cohen on 5/12/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import UIKit
import XCTest
import Connection_

let name1 = "name1"
let phone1 = "phone1"
let vn1 = "vn1"
let cid1 = "cid1"

let name2 = "name2"
let phone2 = "phone2"
let vn2 = "vn2"
let cid2 = "cid2"

class ConnectionsTests: XCTestCase {

    
    var connections: Connections!
    var cloud: Cloud!
    var parseWrapper: ParseWrapperMock!

    override func setUp() {
        super.setUp()
        connections = Connections(coreDataStack: CoreDataStackMock())
        parseWrapper = ParseWrapperMock()
        cloud = Cloud(parse: parseWrapper)
    }
    
    override func tearDown() {
        super.tearDown()
        connections = nil
        cloud = nil
        parseWrapper = nil
    }

    func testExample() {
        XCTAssert(true, "Pass")
    }

    func testInvite_invite1Connection_invited() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        cloud.invite(
            success: { [weak self] (json) -> () in
                let vn = json["vn"]?.string
                let cid = json["cid"]?.string
                XCTAssertNotNil(vn, "there should be a vn")
                XCTAssertNotNil(cid, "there should be a cid")
                self!.connections.addConnection(cid: cid!, name: name1, phone: phone1, vn: vn!)
                let connections = self!.connections.connections()
                XCTAssertEqual(connections.count, 1, "there should be only one connection")
                let connection = connections[0]
                XCTAssertEqual(connection.cid, cid1, "cid should be cid1")
                XCTAssertEqual(connection.name, name1, "name should be name1")
                XCTAssertEqual(connection.phone, phone1, "phone should be phone1")
                XCTAssertEqual(connection.vn, vn1, "vn should be vn1")
            }) { (error) -> () in
                XCTAssertFalse(true, "this method should call should not end up with an error")
        }
    }
    
}
