//
//  ParseWrapperMock.swift
//  Connection!
//
//  Created by Avi Cohen on 5/12/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import Foundation
import Connection_

class ParseWrapperMock: ParseWrapper {

    enum Result {
        case Success(JSONValue)
        case Fail(NSError)
    }
    
    var result: Result!
    
    override func call(#function: String, withParameters parameters: [NSObject : AnyObject]?, success: (JSONValue) -> (), fail: (NSError) -> ()) {
        switch result! {
        case .Success(let json):
            success(json)
        case .Fail(let error):
            fail(error)
        default:
            fail(NSError())
        }
    }
    
}
