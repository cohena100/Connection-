//
//  ConnectionsParseTests.swift
//  Connection!
//
//  Created by Avi Cohen on 5/16/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import UIKit
import XCTest
import Connection_

class ConnectionsParseTests: XCTestCase {

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
    
    let timeout = 10.0
    
    var parseWrapper: ParseWrapper!
    var cloud: Cloud!
    var connections: Connections!
    
    override func setUp() {
        super.setUp()
        parseWrapper = ParseWrapper()
        cloud = Cloud(parse: parseWrapper)
        connections = Connections(coreDataStack: CoreDataStackMock(), cloud: cloud)
    }
    
    override func tearDown() {
        connections = nil
        cloud = nil
        parseWrapper = nil
        super.tearDown()
    }
    
    // MARK: Invite and Delete
    
    func testInvite_invite1Connection_invited() {
        let expectation = expectationWithDescription("invite user")
        connections.invite(name: name1, phone: phone1,
            success: { (connection) -> () in
                expectation.fulfill()
            }) { (error) -> () in
                XCTFail("this method hould not end up with an error")
        }
        waitForExpectationsWithTimeout(timeout) { [unowned self] (error) in
            if let error = error {
                XCTFail("this method should not end up with an error")
                return
            }
            let expectation = self.expectationWithDescription("get connections")
            self.connections.getConnections(success: { (connections) -> () in
                XCTAssertEqual(connections.count, 1, "there should be one connection")
                expectation.fulfill()
            }, fail: { (error) -> () in
                
            })
            self.waitForExpectationsWithTimeout(self.timeout) { (error) in
                if let error = error {
                    XCTFail("this method should not end up with an error")
                    return
                }
                let expectation = self.expectationWithDescription("cleanup")
                self.connections.deleteLastConnection(
                    success: { (connection) -> () in
                        expectation.fulfill()
                    },
                    fail: { (error) -> () in
                        XCTFail("this method should call should not end up with an error")
                    }
                )
                self.waitForExpectationsWithTimeout(self.timeout) { (error) in
                    if let error = error {
                        XCTFail("this method should not end up with an error")
                        return
                    }
                }
            }
        }
    }
    
    func testInvite_invite2Connections_2connections() {
        let expectation = expectationWithDescription("invite user")
        connections.invite(name: name1, phone: phone1,
            success: { (connection) -> () in
                expectation.fulfill()
            }) { (error) -> () in
                XCTFail("this method hould not end up with an error")
        }
        waitForExpectationsWithTimeout(timeout) { [unowned self] (error) in
            if let error = error {
                XCTFail("this method should not end up with an error")
                return
            }
            let expectation = self.expectationWithDescription("invite another user")
            self.connections.invite(name: self.name2, phone: self.phone2,
                success: { (connection) -> () in
                    expectation.fulfill()
                }) { (error) -> () in
                    XCTFail("this method hould not end up with an error")
            }
            self.waitForExpectationsWithTimeout(self.timeout) { (error) in
                if let error = error {
                    XCTFail("this method should not end up with an error")
                    return
                }
                let expectation = self.expectationWithDescription("get connections")
                self.connections.getConnections(success: { (connections) -> () in
                    XCTAssertEqual(connections.count, 2, "there should be 2 connections")
                    expectation.fulfill()
                    }, fail: { (error) -> () in
                        
                })
                self.waitForExpectationsWithTimeout(self.timeout) { (error) in
                    if let error = error {
                        XCTFail("this method should not end up with an error")
                        return
                    }
                    let expectation = self.expectationWithDescription("cleanup")
                    self.connections.deleteLastConnection(
                        success: { (connection) -> () in
                            expectation.fulfill()
                        },
                        fail: { (error) -> () in
                            XCTFail("this method should call should not end up with an error")
                        }
                    )
                    self.waitForExpectationsWithTimeout(self.timeout) { (error) in
                        if let error = error {
                            XCTFail("this method should not end up with an error")
                            return
                        }
                        let expectation = self.expectationWithDescription("cleanup")
                        self.connections.deleteLastConnection(
                            success: { (connection) -> () in
                                expectation.fulfill()
                            },
                            fail: { (error) -> () in
                                XCTFail("this method should call should not end up with an error")
                            }
                        )
                        self.waitForExpectationsWithTimeout(self.timeout) { (error) in
                            if let error = error {
                                XCTFail("this method should not end up with an error")
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    func testInviteAgain_invite1ConnectionAndThenInviteTheSameoneAgain_only1Connection() {
        var vn1 = ""
        let expectation = expectationWithDescription("invite Connection")
        connections.invite(name: name1, phone: phone1,
            success: { (connection) -> () in
                vn1 = connection.vn
                expectation.fulfill()
            }) { (error) -> () in
                XCTFail("this method hould not end up with an error")
        }
        waitForExpectationsWithTimeout(timeout) { [unowned self] (error) in
            if let error = error {
                XCTFail("this method should not end up with an error")
                return
            }
            let expectation = self.expectationWithDescription("invite Again Same Connection")
            self.connections.invite(name: self.name1, phone: self.phone1,
                success: { (connection) -> () in
                    expectation.fulfill()
                }) { (error) -> () in
                    XCTFail("this method hould not end up with an error")
            }
            self.waitForExpectationsWithTimeout(self.timeout) { [unowned self] (error) in
                if let error = error {
                    XCTFail("this method should not end up with an error")
                    return
                }
                let expectation = self.expectationWithDescription("get connections")
                self.connections.getConnections(success: { (connections) -> () in
                    XCTAssertEqual(connections.count, 1, "there should be 1 connection")
                    XCTAssertNotEqual(vn1, connections[0].vn, "the new vn should be different than the old one")
                    expectation.fulfill()
                    }) { (error) -> () in
                }
                self.waitForExpectationsWithTimeout(self.timeout) { [unowned self] (error) in
                    if let error = error {
                        XCTFail("this method should not end up with an error")
                        return
                    }
                    let expectation = self.expectationWithDescription("cleanup")
                    self.connections.deleteLastConnection(
                        success: { (connection) -> () in
                            expectation.fulfill()
                        },
                        fail: { (error) -> () in
                            XCTFail("this method should call should not end up with an error")
                        }
                    )
                    self.waitForExpectationsWithTimeout(self.timeout) { (error) in
                        if let error = error {
                            XCTFail("this method should not end up with an error")
                            return
                        }
                    }
                }
            }
        }
    }
    
    func testAcceeptInvitation_invite1ConnectionAndAccept_1Connection() {
        var vn = ""
        let expectation = expectationWithDescription("invite user")
        connections.invite(name: name1, phone: phone1,
            success: { (connection) -> () in
                vn = connection.vn
                expectation.fulfill()
            }) { (error) -> () in
                XCTFail("this method hould not end up with an error")
        }
        waitForExpectationsWithTimeout(timeout) { [unowned self] (error) in
            if let error = error {
                XCTFail("this method should not end up with an error")
                return
            }
            let expectation = self.expectationWithDescription("accept invitation")
            self.connections.acceptInvitation(name: self.name2, phone: self.phone2, vn: vn,
                success: { (connection) -> () in
                    expectation.fulfill()
                },
                fail: { (error) -> () in
                    XCTFail("this method should call should not end up with an error")
                }
            )
            self.waitForExpectationsWithTimeout(self.timeout) { (error) in
                if let error = error {
                    XCTFail("this method should not end up with an error")
                    return
                }
                let expectation = self.expectationWithDescription("cleanup")
                self.connections.deleteLastConnection(
                    success: { (connection) -> () in
                        expectation.fulfill()
                    },
                    fail: { (error) -> () in
                        XCTFail("this method should call should not end up with an error")
                    }
                )
                self.waitForExpectationsWithTimeout(self.timeout) { (error) in
                    if let error = error {
                        XCTFail("this method should not end up with an error")
                        return
                    }
                }
            }
            
        }
    }
    
    func testAcceeptInvitation_acceptInvitationAndRemovePreviousConnection_1Connection() {
        var vn = ""
        let expectation = expectationWithDescription("invite user")
        connections.invite(name: name1, phone: phone1,
            success: { (connection) -> () in
                expectation.fulfill()
            }) { (error) -> () in
                XCTFail("this method hould not end up with an error")
        }
        waitForExpectationsWithTimeout(timeout) { [unowned self] (error) in
            if let error = error {
                XCTFail("this method should not end up with an error")
                return
            }
            let expectation = self.expectationWithDescription("invite another user")
            self.connections.invite(name: self.name2, phone: self.phone2,
                success: { (connection) -> () in
                    vn = connection.vn
                    expectation.fulfill()
                }) { (error) -> () in
                    XCTFail("this method hould not end up with an error")
            }
            self.waitForExpectationsWithTimeout(self.timeout) { [unowned self] (error) in
                if let error = error {
                    XCTFail("this method should not end up with an error")
                    return
                }
                let expectation = self.expectationWithDescription("accept invitation")
                self.connections.acceptInvitation(name: self.name1, phone: self.phone1, vn: vn,
                    success: { (connection) -> () in
                        expectation.fulfill()
                    },
                    fail: { (error) -> () in
                        XCTFail("this method should call should not end up with an error")
                    }
                )
                self.waitForExpectationsWithTimeout(self.timeout) { (error) in
                    if let error = error {
                        XCTFail("this method should not end up with an error")
                        return
                    }
                    let expectation = self.expectationWithDescription("cleanup")
                    self.connections.deleteLastConnection(
                        success: { (connection) -> () in
                            expectation.fulfill()
                        },
                        fail: { (error) -> () in
                            XCTFail("this method should call should not end up with an error")
                        }
                    )
                    self.waitForExpectationsWithTimeout(self.timeout) { (error) in
                        if let error = error {
                            XCTFail("this method should not end up with an error")
                            return
                        }
                    }
                }
            }
        }
    }
    
}
