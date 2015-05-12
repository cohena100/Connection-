//
//  ParseWrapperMock.swift
//  Connection!
//
//  Created by Avi Cohen on 5/12/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import UIKit
import Connection_

class ParseWrapperMock: ParseWrapper {

    var json: JSONValue?
    var error: NSError?
    
    override func call(#function: String, withParameters parameters: [NSObject : AnyObject], success: (JSONValue) -> (), fail: (NSError) -> ()) {
        if let json = self.json {
            success(json)
        } else if let error = self.error {
            fail(error)
        } else {
            fail(NSError())
        }
    }
    
}
