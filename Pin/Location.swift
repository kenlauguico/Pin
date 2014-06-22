//
//  Location.swift
//  Pin
//
//  Created by Ken on 6/20/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation

class Location: NSObject {
    
    var latitude: Double
    var longitude: Double
    var accuracy: Int
    var location: NSDictionary
    
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
}