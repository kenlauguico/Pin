//
//  PinFriendUtil.swift
//  Pin
//
//  Created by Ken on 8/28/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation


class PinFriendUtil : NSObject {
  
// MARK: - Public Methods -
  
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
  
  
  func numberArrayToFriendList(contactList: NSArray, numbersArray: NSArray) -> [PinFriend] {
    var friendList: [PinFriend] = []
    
    for number: AnyObject in numbersArray {
      for person in contactList {
        if !(isPhoneNumberValid(person)) { continue }
        if (listContactHasMatchingNumber(person, number: number as NSString)) {
          var newFriend: PinFriend = PinFriend(friendName: person["name"] as? NSString, friendNumber: number as? NSString, friendLocation: nil)
          friendList.insert(newFriend, atIndex: 0)
          break
        }
      }
    }
    return friendList
  }
  
  
  func mergeFriendList(leftList: [PinFriend], rightList: [PinFriend]) -> [PinFriend] {
    var mergedList: [PinFriend] = []
    var remainingList = rightList
    var friendFound: Bool = false
    
    // iterate through left list
    for leftFriend: PinFriend in leftList {
      friendFound = false
      
      for (index, rightFriend: PinFriend) in enumerate(remainingList) {
        // check if left list item matches right list item
        if rightFriend.number == leftFriend.number {
          friendFound = true
          
          // use new friend location, add to new list, and remove from remaining
          rightFriend.updateLocation(leftFriend.location)
          mergedList.append(rightFriend)
          remainingList.removeAtIndex(index)
          break
        }
      }
      
      // if no matches in left list, add to new list
      if !friendFound {
        mergedList.append(leftFriend)
      }
    }
    
    // add remaining list to new list
    for friend: PinFriend in remainingList {
      mergedList.append(friend)
    }
    
    return mergedList
  }
  
  
  func getFriendWithNumber(contactList: NSArray, number: NSString) -> PinFriend {
    for person in contactList {
      if !(isPhoneNumberValid(person)) { continue }
      if (listContactHasMatchingNumber(person, number: number)) {
        return PinFriend(friendName: person["name"] as? NSString, friendNumber: number as NSString, friendLocation: nil)
      }
    }
    return PinFriend(friendNumber: number, friendLocation: nil)
  }
  
  
// MARK: - Private Methods -
  
  private func isPhoneNumberValid(contactListFriend: AnyObject) -> Bool {
    return (contactListFriend.objectForKey("phone") != nil)
  }
  
  private func listContactHasMatchingNumber(contact: AnyObject, number: NSString) -> Bool {
    var phone: NSString = SHSPhoneNumberFormatter.digitOnlyString(contact["phone"] as NSString)
    phone = "+\(phone)"
    return phone == number
  }
  
}