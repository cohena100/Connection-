//
//  LocationManagerWrapperMock.swift
//  Connection!
//
//  Created by Avi Cohen on 5/23/15.
//  Copyright (c) 2015 Avi Cohen. All rights reserved.
//

import Connection_

class LocationManagerWrapperMock: LocationManagerWrapper {

    struct Location {
        var lid: String
        var latitude: Double
        var longitude: Double
        var radius: Float
        var accuracy: Float
    }
    
    var locations: [Location] = []
    
    override func addEnterLocation(#lid: String, latitude: Double, longitude: Double, radius: Float, accuracy: Float) {
        locations += [Location(lid: lid, latitude: latitude, longitude: longitude, radius: radius, accuracy: accuracy)]
    }
    
    func didEnterLocation(#lid: String) {
        locations = locations.filter {
            $0.lid != lid
        }
        delegate?.didEnterLocation(lid: lid)
    }
}




