//
//  Cloud.swift
//  Connection!
//
//  Created by Avi Cohen on 5/6/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import Foundation
import Parse


public class Cloud {
    
    struct Error {
        static let domain = "Connection!CloudDomain"
        static let code = -52000
    }
    
    static let sharedInstance = Cloud()
    let parse: ParseWrapper
    
    public init (parse: ParseWrapper) {
        self.parse = parse
    }
    
    convenience init () {
        self.init(parse: ParseWrapper())
    }
    
    public func invite(#success: (JSONValue) -> (), fail: (NSError) -> ()) {
        parse.call(function: "invite", withParameters: nil, success: success, fail: fail)
    }
    
    public func inviteAgain(#cid: String, success: (JSONValue) -> (), fail: (NSError) -> ()) {
        parse.call(function: "inviteAgain", withParameters: ["cid": cid], success: success, fail: fail)
    }
    
    public func deleteConnection(connection: Connection, success: (JSONValue) -> (), fail: (NSError) -> ()) {
        parse.call(function: "deleteConnection", withParameters: ["cid": connection.cid], success: success, fail: fail)
    }
    
    public func connections(#success: (JSONValue) -> (), fail: (NSError) -> ()) {
        parse.call(function: "connections", withParameters: nil, success: success, fail: fail)
    }
    
    public func acceptInvitation(#vn: String, cid: String?, success: (JSONValue) -> (), fail: (NSError) -> ()) {
        let params: [NSObject : AnyObject]
        if let cid = cid {
            params = ["vn": vn, "cid": cid]
        } else {
            params = ["vn": vn]
        }
        parse.call(function: "acceptInvitation", withParameters: params, success: success, fail: fail)
    }
    
    public func addEnterLocation(#success: (JSONValue) -> (), fail: (NSError) -> ()) {
        parse.call(function: "addEnterLocation", withParameters: nil, success: success, fail: fail)
    }
    
    public func didEnterLocation(#cids:[String], success: (JSONValue) -> (), fail: (NSError) -> ()) {
        parse.call(function: "didEnterLocation", withParameters: ["cids": cids], success: success, fail: fail)
    }
    
}