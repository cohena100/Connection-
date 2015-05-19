//
//  ParseWrapper.swift
//  Connection!
//
//  Created by Avi Cohen on 5/7/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import Foundation
import Parse

public class ParseWrapper {
    
    public init() {
        
    }
    
    public func call(#function: String, withParameters parameters: [NSObject : AnyObject]?, success: (JSONValue) -> (), fail: (NSError) -> ()) {
        if let parameters = parameters {
            Log.call(functionName: __FUNCTION__, message: "\(function), \(parameters)")
        } else {
            Log.call(functionName: __FUNCTION__, message: "\(function), with no parameters")
        }
        if let currentUser = PFUser.currentUser() {
            currentUser.saveInBackgroundWithBlock({ (saved, error) -> Void in
                if (saved) {
                    PFCloud.callFunctionInBackground(function, withParameters: parameters) { (result, error) -> Void in
                        if let error = error {
                            Log.fail(functionName: __FUNCTION__, error: error)
                            fail(error)
                            return
                        }
                        else if let result: AnyObject = result {
                            Log.success(functionName: __FUNCTION__, message: "result: \(result)")
                            if let json = JSONValue.fromObject(result) {
                                Log.success(functionName: __FUNCTION__, message: "got a json")
                                success(json)
                            } else {
                                Log.fail(functionName: __FUNCTION__, message: "create a json from result")
                            }
                        } else {
                            Log.fail(functionName: __FUNCTION__, message: "get a known result type")
                        }
                    }
                } else {
                    Log.fail(functionName: __FUNCTION__, message: "save current user")
                }
            })
        } else {
            Log.fail(functionName: __FUNCTION__, message: "get current user")
        }
    }
    
}