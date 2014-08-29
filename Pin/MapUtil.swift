//
//  MapUtil.swift
//  Pin
//
//  Created by Ken on 6/21/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation
import CoreLocation


class MapUtil: NSObject {

// MARK: - Public Methods -
  
  func makeMapThumb(size: CGSize!, location: Location!, zoom: Int) -> UIImage! {
    var coordinates = location.location.coordinate
    
    var locationFormat: NSString = "\(coordinates.latitude),\(coordinates.longitude)"
    var sizeFormat: NSString = "\(Int(size.width*1.6))x\(Int(size.height*1.6))"
    
    var mapThumbURLString: NSString = "http://maps.googleapis.com/maps/api/staticmap?center=\(locationFormat)&zoom=\(zoom)&size=\(sizeFormat)&maptype=roadmap&markers=color:red%7C\(locationFormat)&sensor=false"

    var mapThumbURL: NSURL = NSURL(string: mapThumbURLString)
    var mapThumbData: NSData = NSData(contentsOfURL: mapThumbURL)
    var mapThumbImage: UIImage = UIImage(data: mapThumbData)

    return mapThumbImage
  }
  
  
  func launchMapApp(location: Location!) {
    var coordinates = location.location.coordinate
    var mapURL: NSURL = NSURL(string: "http://maps.apple.com/?q=\(coordinates.latitude),\(coordinates.longitude)&z=17")
    UIApplication.sharedApplication().openURL(mapURL)
  }
  
  
  func getCity(location: Location!, gotCity: ((NSString?) -> Void)) {
    var geocoder = CLGeocoder()
    
    geocoder.reverseGeocodeLocation(location.location, completionHandler: { (placemarks: [AnyObject]!, error: NSError!) in
      if (error == nil) {
        var placemark: CLPlacemark = placemarks[0] as CLPlacemark
        gotCity(placemark.locality)
        
        NSNotificationCenter.defaultCenter().postNotificationName("silentRefresh", object: nil)
      }
      })
  }
  
}