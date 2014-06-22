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
    
    
    init(friendName: NSString?, friendNumber: NSString?, friendLocation: Location?) {
        name = friendName
        number = friendNumber
        location = friendLocation
        
        if friendLocation?.latitude == 0 || friendLocation?.latitude == nil { return }
        
        map = MapUtil().makeMapThumb(cellImageSize, location: friendLocation, zoom: 16)
    }
}