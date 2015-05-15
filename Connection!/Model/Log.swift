//
//  Logger.swift
//  Connection!
//
//  Created by Avi Cohen on 5/7/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import Foundation

public class Log {
    
    public static func call(message: String) {
        log("call: " + message)
    }
    
    public static func success(message: String) {
        log("success: " + message)
    }
    
    public static func fail(error: NSError) {
        log("fail with error: \(error)")
    }
    
    public static func fail(message: String) {
        log("fail: " + message)
    }
    
    public static func warn(message: String) {
        log("warn: " + message)
    }
    
    private static func log(logMessage: String, fileName: String = __FILE__, functionName: String = __FUNCTION__) {
        println("[\(fileName)][\(functionName)][\(logMessage)]")
    }
}