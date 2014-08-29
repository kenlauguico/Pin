//
//  PinFriend.swift
//  Pin
//
//  Created by Ken on 6/21/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation


class PinFriend: NSObject {

  var name: NSString? = nil
  var number: NSString? = nil
  var location: Location? = nil
  var map: UIImage? = nil
  var city: NSString? = nil


// MARK: - Public Methods -
  
  init(friendNumber: NSString?, friendLocation: Location?) {
    super.init()
    name = friendNumber
    number = friendNumber
    location = friendLocation

    if friendLocation?.location.coordinate.latitude == 0 ||
      friendLocation?.location.coordinate.latitude == nil { return }

    map = MapUtil().makeMapThumb(cellImageSize, location: friendLocation, zoom: 16)
    
    MapUtil().getCity(location, gotCity: { (cityname: NSString?) in
      self.city = cityname
      })
  }

  
  init(friendName: NSString?, friendNumber: NSString?, friendLocation: Location?) {
    super.init()
    name = friendName
    number = friendNumber
    location = friendLocation

    if friendLocation?.location.coordinate.latitude == 0 ||
      friendLocation?.location.coordinate.latitude == nil { return }

    map = MapUtil().makeMapThumb(cellImageSize, location: friendLocation, zoom: 16)
    
    MapUtil().getCity(location, gotCity: { (cityname: NSString?) in
      self.city = cityname
      })
  }


  func updateLocation(newLocation: Location!) {
    if !(self.isLocationValid(newLocation!)) { return }

    map = MapUtil().makeMapThumb(cellImageSize, location: newLocation, zoom: 16)
    MapUtil().getCity(newLocation, gotCity: { (cityname: NSString?) in
      self.city = cityname
      })
    
    location = newLocation
  }
  
  
// MARK: - Private Methods -
  
  private init(coder aDecoder: NSCoder!) {
    super.init()
    name = aDecoder.decodeObjectForKey("name") as? NSString
    number = aDecoder.decodeObjectForKey("number") as? NSString
    location = aDecoder.decodeObjectForKey("location") as? Location
    map = aDecoder.decodeObjectForKey("map") as? UIImage
    city = aDecoder.decodeObjectForKey("city") as? NSString
  }
  

  private func encodeWithCoder(aCoder: NSCoder!) {
    aCoder.encodeObject(name!, forKey: "name")
    aCoder.encodeObject(number!, forKey: "number")
    
    if (location != nil) {
      aCoder.encodeObject(location!, forKey: "location")
    }
    if (map != nil) {
      aCoder.encodeObject(map!, forKey: "map")
    }
    if (city != nil) {
      aCoder.encodeObject(city!, forKey: "city")
    }
  }
  
  private func isLocationValid(location: Location) -> Bool {
    return !(location.location.coordinate.latitude == 0.0)
  }
  
}