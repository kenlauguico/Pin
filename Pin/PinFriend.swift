//
//  PinFriend.swift
//  Pin
//
//  Created by Ken on 6/21/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation


func getFriends() -> [PinFriend] {
  var data: NSData? = NSUserDefaults.standardUserDefaults().objectForKey("friendList") as? NSData
  if (data == nil) { return [] }

  var friends: [PinFriend]? = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? [PinFriend]
  return (friends != nil) ? friends as [PinFriend]! : []
}


func syncFriends(friendList: [PinFriend]) {
  var data: NSData = NSKeyedArchiver.archivedDataWithRootObject(friendList) as NSData
  NSUserDefaults.standardUserDefaults().setObject(data, forKey: "friendList")
}


func friendListFromNumbersArray(contactList: NSArray, numbersArray: NSArray) -> [PinFriend] {
  var newFriendList: [PinFriend] = []

  for number: AnyObject in numbersArray {
    for person in contactList {
      if (person.valueForKey("phone") == nil) { continue }
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


func mergeFriendList(oldList: [PinFriend], newList: [PinFriend]) -> [PinFriend] {
  var updatedList: [PinFriend] = []
  var newFriendList = newList
  var found: Bool = false
  
  for friend: PinFriend in oldList {
    found = false
    for (index, newFriend: PinFriend) in enumerate(newFriendList) {
      if newFriend.number == friend.number {
        found = true
        newFriend.updateLocation(friend.location)
        updatedList.append(newFriend)
        newFriendList.removeAtIndex(index)
        break
      }
    }
    if !found {
      updatedList.append(friend)
    }
  }
  
  for friend: PinFriend in newFriendList {
    updatedList.append(friend)
  }
  
  return updatedList
}


func getFriendWithNumber(contactList: NSArray, number: NSString) -> PinFriend {
  for person in contactList {
    if (person.objectForKey("phone") == nil) { continue }
    var phone: NSString = SHSPhoneNumberFormatter.digitOnlyString(person["phone"] as NSString)
    phone = "+\(phone)"
    if phone == number {
      var newFriend: PinFriend = PinFriend(friendName: person["name"] as? NSString, friendNumber: number as NSString, friendLocation: nil)
      return newFriend
    }
  }
  return PinFriend(friendNumber: number, friendLocation: nil)
}


class PinFriend: NSObject {

  var name: NSString? = nil
  var number: NSString? = nil
  var location: Location? = nil
  var map: UIImage? = nil
  var city: NSString? = nil

  
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


  func updateLocation(friendLocation: Location!) {
    location = friendLocation

    if friendLocation?.location.coordinate.latitude == 0 ||
      friendLocation?.location.coordinate.latitude == nil { return }

    map = MapUtil().makeMapThumb(cellImageSize, location: friendLocation, zoom: 16)
    
    MapUtil().getCity(location, gotCity: { (cityname: NSString?) in
      self.city = cityname
      })
  }
  
  
  init(coder aDecoder: NSCoder!) {
    super.init()
    name = aDecoder.decodeObjectForKey("name") as? NSString
    number = aDecoder.decodeObjectForKey("number") as? NSString
    location = aDecoder.decodeObjectForKey("location") as? Location
    map = aDecoder.decodeObjectForKey("map") as? UIImage
    city = aDecoder.decodeObjectForKey("city") as? NSString
  }
  

  func encodeWithCoder(aCoder: NSCoder!) {
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
}