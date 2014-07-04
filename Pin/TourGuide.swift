//
//  TourGuide.swift
//  Pin
//
//  Created by Ken on 7/4/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation

struct TGTip {
  static var phone = "PhoneTip"
  static var refresh = "RefreshTip"
  static var send = "SendTip"
  static var pin = "PinTip"
  static var contacts = "ContactsTip"
}


class TourGuide: NSObject {
  
  struct tip {
    static var phone    = "Remember to add your country code!"
    static var refresh  = "Refresh to see if your friends have joined Pin!"
    static var send     = "Tap on a friend to send them your location!"
    static var pin      = "You have a new Pin from a friend! Tap the map for a closer look."
    static var contacts = "It looks like you have no contacts! Make sure your friends on your address book have Pin!"
  }
  
  
  var tipDelay: Double = 1.5
  
  var seenPhoneTip: Bool = NSUserDefaults.standardUserDefaults().boolForKey(TGTip.phone)
  var seenRefreshTip: Bool = NSUserDefaults.standardUserDefaults().boolForKey(TGTip.refresh)
  var seenSendTip: Bool = NSUserDefaults.standardUserDefaults().boolForKey(TGTip.send)
  var seenPinTip: Bool = NSUserDefaults.standardUserDefaults().boolForKey(TGTip.pin)
  var seenContactsTip: Bool = NSUserDefaults.standardUserDefaults().boolForKey(TGTip.contacts)
  
  
  func reset() {
    seenPhoneTip = false
    seenRefreshTip = false
    seenSendTip = false
    seenPinTip = false
    seenContactsTip = false
    
    NSUserDefaults.standardUserDefaults().setBool(false, forKey: TGTip.phone)
    NSUserDefaults.standardUserDefaults().setBool(false, forKey: TGTip.refresh)
    NSUserDefaults.standardUserDefaults().setBool(false, forKey: TGTip.send)
    NSUserDefaults.standardUserDefaults().setBool(false, forKey: TGTip.pin)
    NSUserDefaults.standardUserDefaults().setBool(false, forKey: TGTip.contacts)
    
  }
  
  
  func setSeen(tip: NSString) {
    switch tip {
    case TGTip.phone:
      seenPhoneTip = true
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: TGTip.phone)
    case TGTip.refresh:
      seenRefreshTip = true
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: TGTip.refresh)
    case TGTip.send:
      seenSendTip = true
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: TGTip.send)
    case TGTip.pin:
      seenPinTip = true
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: TGTip.pin)
    case TGTip.contacts:
      seenContactsTip = true
      NSUserDefaults.standardUserDefaults().setBool(true, forKey: TGTip.contacts)
      
    default:
      return
    }
  }
}