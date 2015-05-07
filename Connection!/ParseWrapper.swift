//
//  ParseWrapper.swift
//  Connection!
//
//  Created by Avi Cohen on 5/7/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import Foundation
import Parse

class ParseWrapper {
    
    func call(#function: String, withParameters parameters: [NSObject : AnyObject], success: (JSONValue) -> (), fail: (NSError) -> ()) {
        Log.call("\(function), \(parameters)")
        if let currentUser = PFUser.currentUser() {
            currentUser.saveInBackgroundWithBlock({ (saved, error) -> Void in
                if (saved) {
                    PFCloud.callFunctionInBackground(function, withParameters: parameters) { (result, error) -> Void in
                        if let error = error {
                            Log.fail(error)
                            fail(error)
                            return
                        }
                        else if let result: AnyObject = result {
                            Log.success("\(result)")
                            if let json = JSONValue.fromObject(result) {
                                Log.success("got a json")
                                success(json)
                            } else {
                                Log.fail("create a json from result")
                            }
                        } else {
                            Log.fail("get a known result type")
                        }
                    }
                } else {
                    Log.fail("save current user")
                }
            })
        } else {
            Log.fail("get current user")
        }
    }
    
}