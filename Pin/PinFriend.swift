//
//  PinFriend.swift
//  Pin
//
//  Created by Ken on 6/21/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation

class PinFriend: NSObject {
    
    var name: NSString!
    var number: NSString!
    var location: Location!
    var map: UIImage!
    
    
    init(friendName: NSString!, friendNumber: NSString!, friendLocation: Location!) {
        name = friendName
        number = friendNumber
        
        if friendLocation.latitude == 0 || friendLocation.latitude == nil { return }
        
        location = friendLocation
        map = MapUtil().makeMapThumb(cellImageSize, location: friendLocation, zoom: 16)
    }
}