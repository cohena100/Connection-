//
//  LocationManagerWrapper.swift
//  Connection!
//
//  Created by Avi Cohen on 5/23/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import Foundation

public protocol LocationManagerWrapperDelegate: class {
    func didEnterLocation(#lid: String)
}

public class LocationManagerWrapper {
    
    static let sharedInstance = LocationManagerWrapper()
    
    public weak var delegate: LocationManagerWrapperDelegate?

    public init() {
    }
    
    public func addEnterLocation(#lid: String, latitude: Double, longitude: Double, radius: Float, accuracy: Float) {
    }
    
}

