//
//  PinFriendArray+Exists.swift
//  Pin
//
//  Created by Ken on 8/29/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation

extension Array {
  
  mutating func exists(friend: T) -> Bool {
    var currentFriend: PinFriend = friend as PinFriend

    if isEmpty { return false }
    for (index, myFriend: T) in enumerate(self) {
      let frnd: PinFriend = myFriend as PinFriend
      if frnd.number == currentFriend.number {
        return true
      }
    }
    
    return false
  }
}