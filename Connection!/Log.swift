//
//  Logger.swift
//  Connection!
//
//  Created by Avi Cohen on 5/7/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import Foundation

class Log {
    
    static func call(message: String) {
        log("call: " + message)
    }
    
    static func success(message: String) {
        log("success: " + message)
    }
    
    static func fail(error: NSError) {
        log("fail with error: \(error)")
    }
    
    static func fail(message: String) {
        log("fail: " + message)
    }
    
    static func log(logMessage: String, fileName: String = __FILE__, functionName: String = __FUNCTION__) {
        println("[\(fileName)][\(functionName)][\(logMessage)]")
    }
}