// Playground - noun: a place where people can play

import Cocoa

var new_list: AnyObject[] = []
var friend_list = [
  ["name":"ken0", "phone":"+000"],
  ["name":"ken2", "phone":"+222"],
  ["name":"ken4", "phone":"+444"],
]
var address_book = [
  ["name":"ken1", "phone":"+111"],
  ["name":"ken2", "phone":"+222"],
  ["name":"ken3", "phone":"+333"],
  ["name":"ken4", "phone":"+444"],
  ["name":"ken5", "phone":"+555"],
]
var found: Bool

for friend in friend_list {
  found = false
  for (index, newfriend) in enumerate(address_book) {
    if newfriend["phone"] == friend["phone"] {
      found = true
      new_list.append(newfriend)
      address_book.removeAtIndex(index)
      break
    }
  }
  if !found {
    new_list.append(friend)
  }
}

for friend in address_book {
  new_list.append(friend)
}

println(new_list)