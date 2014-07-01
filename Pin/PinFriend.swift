//
//  PinFriend.swift
//  Pin
//
//  Created by Ken on 6/21/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation


func getFriends() -> PinFriend[] {
  var data: NSData? = NSUserDefaults.standardUserDefaults().objectForKey("friendList") as? NSData
  if !data { return [] }

  var friends: PinFriend[]? = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? PinFriend[]
  return friends ? friends as PinFriend[] : []
}

func syncFriends(friendList: PinFriend[]) {
  var data: NSData = NSKeyedArchiver.archivedDataWithRootObject(friendList) as NSData
  NSUserDefaults.standardUserDefaults().setObject(data, forKey: "friendList")
}

func friendListFromNumbersArray(contactList: NSArray, numbersArray: NSArray) -> PinFriend[] {
  var newFriendList: PinFriend[] = []

  for number: AnyObject in numbersArray {
    for person: NSDictionary! in contactList {
      if !person.valueForKey("phone") { continue }
      var phone: NSString = SHSPhoneNumberFormatter.digitOnlyString(person["phone"] as NSString)
      phone = "+\(phone)"
      if phone == number as NSString {
        var newFriend: PinFriend = PinFriend(friendName: person["name"] as? NSString, friendNumber: number as? NSString, friendLocation: nil)
        newFriendList.insert(newFriend, atIndex: 0)
        break
      }
    }
  }

  return newFriendList
}

func getFriendWithNumber(contactList: NSArray, number: NSString) -> PinFriend {
  for person: NSDictionary! in contactList {
    if !person.objectForKey("phone") { break }
    var phone: NSString = SHSPhoneNumberFormatter.digitOnlyString(person["phone"] as NSString)
    phone = "+\(phone)"
    if phone == number {
      var newFriend: PinFriend = PinFriend(friendName: person["name"] as? NSString, friendNumber: number as? NSString, friendLocation: nil)
      return newFriend
    }
  }
  return PinFriend(friendNumber: number, friendLocation: nil)
}


class PinFriend: NSObject, NSCoding {

  var name: NSString? = nil
  var number: NSString? = nil
  var location: Location? = nil
  var map: UIImage? = nil


  init(friendNumber: NSString?, friendLocation: Location?) {
    name = friendNumber
    number = friendNumber
    location = friendLocation

    if friendLocation?.latitude == 0 || friendLocation?.latitude == nil { return }

    map = MapUtil().makeMapThumb(cellImageSize, location: friendLocation, zoom: 16)
  }

  init(friendName: NSString?, friendNumber: NSString?, friendLocation: Location?) {
    name = friendName?.uppercaseString
    number = friendNumber
    location = friendLocation

    if friendLocation?.latitude == 0 || friendLocation?.latitude == nil { return }

    map = MapUtil().makeMapThumb(cellImageSize, location: friendLocation, zoom: 16)
  }

  init(coder aDecoder: NSCoder!) {
    name = aDecoder.decodeObjectForKey("name") as? NSString
    number = aDecoder.decodeObjectForKey("number") as? NSString
    location = aDecoder.decodeObjectForKey("location") as? Location
    map = aDecoder.decodeObjectForKey("map") as? UIImage
  }

  func updateLocation(friendLocation: Location!) {
    location = friendLocation

    if friendLocation?.latitude == 0 || friendLocation?.latitude == nil { return }

    map = MapUtil().makeMapThumb(cellImageSize, location: friendLocation, zoom: 16)
  }

  func encodeWithCoder(aCoder: NSCoder!) {
    aCoder.encodeObject(name, forKey: "name")
    aCoder.encodeObject(number, forKey: "number")
    aCoder.encodeObject(location, forKey: "location")
    aCoder.encodeObject(map, forKey: "map")
  }
}