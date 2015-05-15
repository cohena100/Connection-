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

let name3 = "name3"
let phone3 = "phone3"
let vn3 = "vn3"
let cid3 = "cid3"

class ConnectionsTests: XCTestCase {

    
    var connections: Connections!
    var cloud: Cloud!
    var parseWrapper: ParseWrapperMock!

    override func setUp() {
        super.setUp()
        parseWrapper = ParseWrapperMock()
        cloud = Cloud(parse: parseWrapper)
        connections = Connections(coreDataStack: CoreDataStackMock(), cloud: cloud)
    }
    
    override func tearDown() {
        super.tearDown()
        connections = nil
        cloud = nil
        parseWrapper = nil
    }

    func testInvite_invite1Connection_invited() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
        }) { (error) -> () in
            XCTAssert(false, "this method should call should not end up with an error")
        }
        XCTAssertEqual(connections.connections().count, 1, "there should be only one connection")
        let connection = connections.connections()[0]
        XCTAssertEqual(connection.cid, cid1, "cid should be cid1")
        XCTAssertEqual(connection.name, name1, "name should be name1")
        XCTAssertEqual(connection.phone, phone1, "phone should be phone1")
        XCTAssertEqual(connection.vn, vn1, "vn should be vn1")
    }
    
    func testInvite_invite2Connections_2invitedCounted() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.addConnection(name: name1, phone: phone1,
            success: { [weak self] (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
        })
        parseWrapper.json = JSONValue.fromObject(["vn": vn2, "cid": cid2])
        connections.addConnection(name: name2, phone: phone2,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
        })
        let allConnections = connections.connections()
        XCTAssertEqual(allConnections.count, 2, "there should be only 2 connections")
        var connection = allConnections[1]
        if connection.cid == cid1 {
            connection = allConnections[0]
        }
        XCTAssertEqual(connection.cid, cid2, "cid should be cid2")
        XCTAssertEqual(connection.name, name2, "name should be name2")
        XCTAssertEqual(connection.phone, phone2, "phone should be phone2")
        XCTAssertEqual(connection.vn, vn2, "vn should be vn2")
    }
    
    func testInvite_inviteManyConnections_manyInvitedCounted() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
        })
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
        })
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
        })
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
        })
        XCTAssertEqual(connections.connections().count, 4, "there should be only 4 connections")
    }
    
    func testInvite_invite1ConnectionButDeleteIt_deleted() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
            }
        )
        connections.deleteLastConnection(
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
            }
        )
        XCTAssertEqual(connections.connections().count, 0, "there should be no connections")
    }
    
    func testInvite_invite2ConnectionButDeleteTheLast_onlyLastIsDeleted() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
            }
        )
        parseWrapper.json = JSONValue.fromObject(["vn": vn2, "cid": cid2])
        connections.addConnection(name: name2, phone: phone2,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
        })
        connections.deleteLastConnection(
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
            }
        )
        XCTAssertEqual(connections.connections().count, 1, "there should be no connections")
        let connection = connections.connections()[0]
        XCTAssertEqual(connection.cid, cid1, "cid should be cid1")
    }
    
    func testInvite_invite3ConnectionButDeleteTheLast_onlyLastIsDeleted() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
            }
        )
        parseWrapper.json = JSONValue.fromObject(["vn": vn2, "cid": cid2])
        connections.addConnection(name: name2, phone: phone2,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
        })
        parseWrapper.json = JSONValue.fromObject(["vn": vn3, "cid": cid3])
        connections.addConnection(name: name3, phone: phone3,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
        })
        parseWrapper.json = JSONValue.fromObject(["cid": cid3])
        connections.deleteLastConnection(
            success: { (connection) -> () in
                XCTAssertEqual(connection.cid, cid3, "cid should be cid3")
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
            }
        )
    }
    
    func testInvite_invite1ConnectionButDeleteItAndThenDeleteLastAgain_returnError() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
            }
        )
        connections.deleteLastConnection(
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTAssert(false, "this method should call should not end up with an error")
            }
        )
        connections.deleteLastConnection(
            success: { (connection) -> () in
                XCTAssert(false, "this method should call should not end up with success")
            },
            fail: { (error) -> () in
                XCTAssert(true, "this method should call should not end up with success")
            }
        )
    }
    
}
