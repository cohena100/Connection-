//
//  Cloud.swift
//  Connection!
//
//  Created by Avi Cohen on 5/6/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import Foundation
import Parse

class Cloud {
    
    static let sharedInstance = Cloud()
    let parse: ParseWrapper
    
    init (parse: ParseWrapper) {
        self.parse = parse
    }
    
    convenience init () {
        self.init(parse: ParseWrapper())
    }
    
    func invite(#name: String, phone: String, success: (JSONValue) -> (), fail: (NSError) -> ()) {
        parse.call(function: "invite", withParameters: ["name": name, "phone": phone], success: success, fail: fail)
    }
    
}