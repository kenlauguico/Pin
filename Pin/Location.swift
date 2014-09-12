//
//  Location.swift
//  Pin
//
//  Created by Ken on 6/20/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation
import CoreLocation

class Location: NSObject {

  var location: CLLocation


// MARK: - Public Methods -
  
  override init() {
    location = CLLocation()
  }

  
  init(lat: Double, long: Double, acc: Double) {
    var coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
    location = CLLocation(coordinate: coordinates, altitude: 0, horizontalAccuracy: acc, verticalAccuracy: acc, timestamp: nil)
  }

  
  init(loc: CLLocation) {
    location = loc
  }
  
  
  init(dictionary: NSDictionary) {
    var latitude = dictionary["latitude"] as Double
    var longitude = dictionary["longitude"] as Double
    var accuracy = dictionary["accuracy"] as Double
    var coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    
    location = CLLocation(coordinate: coordinates, altitude: 0, horizontalAccuracy: accuracy, verticalAccuracy: accuracy, timestamp: nil)
  }
  
  
  func asDictionary() -> NSDictionary {
    return [
      "latitude": location.coordinate.latitude,
      "longitude": location.coordinate.longitude,
      "accuracy": location.verticalAccuracy
    ]
  }

  
// MARK: - Private Methods -
  
  init(coder aDecoder: NSCoder!) {
    location = aDecoder.decodeObjectForKey("location") as CLLocation
  }

  
  func encodeWithCoder(aCoder: NSCoder!) {
    aCoder.encodeObject(location, forKey: "location")
  }
  
}