//
//  Location.swift
//  Pin
//
//  Created by Ken on 6/20/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation

class Location: NSObject {
    
    var latitude: Double = 0
    var longitude: Double = 0
    var accuracy: Int = 0
    var location: NSDictionary = [:]
    
    
    init() {}
    
    init(lat: Double, long: Double, acc: Int) {
        latitude = lat
        longitude = long
        accuracy = acc
        location = [
            "latitude": lat,
            "longitude": long,
            "accuracy": acc
        ]
    }
    
    init(dictionary: NSDictionary) {
        latitude = dictionary["latitude"] as Double
        longitude = dictionary["longitude"] as Double
        accuracy = dictionary["accuracy"] as Int
        location = [
            "latitude": latitude,
            "longitude": longitude,
            "accuracy": accuracy
        ]
    }
}