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

  
  func makeMapThumb(size: CGSize!, location: Location!, zoom: Int) -> UIImage! {
    var lc: NSString = "\(location.latitude),\(location.longitude)"
    var sz: NSString = "\(Int(size.width*1.6))x\(Int(size.height*1.6))"
    var mapThumbURL: NSString = "http://maps.googleapis.com/maps/api/staticmap?center=\(lc)&zoom=\(zoom)&size=\(sz)&maptype=roadmap&markers=color:red%7C\(lc)&sensor=false"

    var url: NSURL = NSURL(string: mapThumbURL)
    var imageData: NSData = NSData(contentsOfURL: url)
    var mapImage: UIImage = UIImage(data: imageData)

    return mapImage
  }

  
  func launchMapApp(location: Location!) {
    var mapURL: NSURL = NSURL(string: "http://maps.apple.com/?q=\(location.latitude),\(location.longitude)&z=17")
    UIApplication.sharedApplication().openURL(mapURL)
  }
  
  
  func getCity(location: Location!, gotCity: ((NSString?) -> Void)) {
    var geo = CLGeocoder()
    var loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
    
    geo.reverseGeocodeLocation(loc, completionHandler: { (placemarks: [AnyObject]!, error: NSError!) in
      if (error == nil) {
        var placemark: CLPlacemark = placemarks[0] as CLPlacemark
        gotCity(placemark.locality)
        NSNotificationCenter.defaultCenter().postNotificationName("silentRefresh", object: nil)
      }
      })
  }
}