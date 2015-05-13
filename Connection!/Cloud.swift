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
    
}