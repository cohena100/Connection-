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
    
    func invite(name: String, phone: String, block: PFIdResultBlock?) {
        if let currentUser = PFUser.currentUser() {
            currentUser.saveInBackgroundWithBlock({ (saved, error) -> Void in
                if (saved) {
                    PFCloud.callFunctionInBackground("hello", withParameters: [:]) { (result, error) -> Void in
                        if let error = error {
                            println("fail with error: \(error)")
                        } else if let result: AnyObject = result {
                            println("success with result: \(result)")
                        }
                    }
                }
            })
        }
        
    }
    
}