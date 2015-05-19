//
//  Logger.swift
//  Connection!
//
//  Created by Avi Cohen on 5/7/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import Foundation

public class Log {
    
    public static func call(#functionName: String, message: String) {
        log(functionName: functionName, logMessage: "call: " + message)
    }
    
    public static func success(#functionName: String, message: String) {
        log(functionName: functionName, logMessage: "success: " + message)
    }
    
    public static func fail(#functionName: String, error: NSError) {
        log(functionName: functionName, logMessage: "fail with error: \(error)")
    }
    
    public static func fail(#functionName: String, message: String) {
        log(functionName: functionName, logMessage: "fail: " + message)
    }
    
    public static func warn(#functionName: String, message: String) {
        log(functionName: functionName, logMessage: "warn: " + message)
    }
    
    private static func log(#functionName: String, logMessage: String) {
        println("[\(functionName)][\(logMessage)]")
    }
}