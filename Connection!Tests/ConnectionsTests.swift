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

class ConnectionsTests: XCTestCase {

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

    // MARK: Invite
    
    func testInvite_invite1Connection_invited() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
        }) { (error) -> () in
            XCTFail("this method should call should not end up with an error")
        }
        parseWrapper.json = JSONValue.fromObject([cid1])
        connections.connections(
            success: { [weak self] connections in
                let connection = connections[0]
                XCTAssertEqual(connection.cid, self!.cid1, "cid should be cid1")
                XCTAssertEqual(connection.name, self!.name1, "name should be name1")
                XCTAssertEqual(connection.phone, self!.phone1, "phone should be phone1")
                XCTAssertEqual(connection.vn, self!.vn1, "vn should be vn1")
            },
            fail: { (error) -> () in
                XCTFail("this method should not end up with an error")
            }
        )

    }
    
    func testInvite_invite2Connections_2invitedCounted() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.addConnection(name: name1, phone: phone1,
            success: { [weak self] (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
        })
        parseWrapper.json = JSONValue.fromObject(["vn": vn2, "cid": cid2])
        connections.addConnection(name: name2, phone: phone2,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
        })
        parseWrapper.json = JSONValue.fromObject([cid1, cid2])
        connections.connections(success: { [weak self] (connections) -> () in
            XCTAssertEqual(connections.count, 2, "there should be only 2 connections")
            var connection = connections[1]
            if connection.cid == self!.cid1 {
                connection = connections[0]
            }
            XCTAssertEqual(connection.cid, self!.cid2, "cid should be cid2")
            XCTAssertEqual(connection.name, self!.name2, "name should be name2")
            XCTAssertEqual(connection.phone, self!.phone2, "phone should be phone2")
            XCTAssertEqual(connection.vn, self!.vn2, "vn should be vn2")
        }) { (error) -> () in
            
        }
    }
    
    func testInvite_inviteManyConnections_manyInvitedCounted() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
        })
        parseWrapper.json = JSONValue.fromObject(["vn": vn2, "cid": cid2])
        connections.addConnection(name: name2, phone: phone2,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
        })
        parseWrapper.json = JSONValue.fromObject(["vn": vn3, "cid": cid3])
        connections.addConnection(name: name3, phone: phone3,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
        })
        parseWrapper.json = JSONValue.fromObject([cid1, cid2, cid3])
        connections.connections(success: { [weak self] (connections) -> () in
            XCTAssertEqual(connections.count, 3, "there should be only 4 connections")
            }) { (error) -> () in
                XCTFail("this method should call should not end up with an error")
        }
    }
    
    // MARK: Delete
    
    func testInvite_invite1ConnectionButDeleteIt_deleted() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
            }
        )
        connections.deleteLastConnection(
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
            }
        )
        parseWrapper.json = JSONValue.fromObject([])
        connections.connections(success: { [weak self] (connections) -> () in
            XCTAssertEqual(connections.count, 0, "there should be no connections")
            }) { (error) -> () in
                XCTFail("this method should call should not end up with an error")
        }
    }
    
    func testInvite_invite2ConnectionButDeleteTheLast_onlyLastIsDeleted() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
            }
        )
        parseWrapper.json = JSONValue.fromObject(["vn": vn2, "cid": cid2])
        connections.addConnection(name: name2, phone: phone2,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
        })
        connections.deleteLastConnection(
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
            }
        )
        parseWrapper.json = JSONValue.fromObject([cid1])
        connections.connections(success: { [weak self] (connections) -> () in
            XCTAssertEqual(connections.count, 1, "there should be one connection")
            let connection = connections[0]
            XCTAssertEqual(connection.cid, self!.cid1, "cid should be cid1")
            }) { (error) -> () in
                XCTFail("this method should call should not end up with an error")
        }
    }
    
    func testInvite_invite3ConnectionButDeleteTheLast_onlyLastIsDeleted() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
            }
        )
        parseWrapper.json = JSONValue.fromObject(["vn": vn2, "cid": cid2])
        connections.addConnection(name: name2, phone: phone2,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
        })
        parseWrapper.json = JSONValue.fromObject(["vn": vn3, "cid": cid3])
        connections.addConnection(name: name3, phone: phone3,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
        })
        parseWrapper.json = JSONValue.fromObject(["cid": cid3])
        connections.deleteLastConnection(
            success: { [weak self] (connection) -> () in
                XCTAssertEqual(connection.cid, self!.cid3, "cid should be cid3")
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
            }
        )
    }
    
    func testInvite_invite1ConnectionButDeleteItAndThenDeleteLastAgain_returnError() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
            }
        )
        connections.deleteLastConnection(
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
            }
        )
        connections.deleteLastConnection(
            success: { (connection) -> () in
                XCTFail("this method should call should not end up with success")
            },
            fail: { (error) -> () in
                XCTAssert(true, "this method should call should not end up with success")
            }
        )
    }
    
    func testInvite_invite3ConnectionButDeleteTheLastAndThe2ndWasDeleted_onlyTheFirstConnectionExists() {
        parseWrapper.json = JSONValue.fromObject(["vn": vn1, "cid": cid1])
        connections.addConnection(name: name1, phone: phone1,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
            }
        )
        parseWrapper.json = JSONValue.fromObject(["vn": vn2, "cid": cid2])
        connections.addConnection(name: name2, phone: phone2,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
        })
        parseWrapper.json = JSONValue.fromObject(["vn": vn3, "cid": cid3])
        connections.addConnection(name: name3, phone: phone3,
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
        })
        connections.deleteLastConnection(
            success: { (connection) -> () in
            },
            fail: { (error) -> () in
                XCTFail("this method should call should not end up with an error")
            }
        )
        parseWrapper.json = JSONValue.fromObject([cid1])
        connections.connections(success: { [weak self] (connections) -> () in
            XCTAssertEqual(connections.count, 1, "there should be one connection")
            let connection = connections[0]
            XCTAssertEqual(connection.cid, self!.cid1, "cid should be cid1")
            }) { (error) -> () in
                XCTFail("this method should call should not end up with an error")
        }
    }
    
}
