//
//  AddressBookManager.swift
//  Pin
//
//  Created by Ken on 6/24/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation


class AddressBookManager: NSObject {
  
  var addressBook: APAddressBook
  var contactList: NSMutableArray = []
  
  
  init() {
    addressBook = APAddressBook()
  }
  
  
  func checkAddressBookAccess() {
    switch(APAddressBook.access().value) {
    case APAddressBookAccessGranted.value:
      self.accessGrantedForAddressBook()
      break
      
    case APAddressBookAccessUnknown.value:
      self.accessGrantedForAddressBook()
      break
      
    case APAddressBookAccessDenied.value:
      var alert: UIAlertView = UIAlertView(title: "Privacy Warning", message: "Permission was not granted for Contacts.", delegate: self, cancelButtonTitle: "OK")
      alert.show()
      break
      
    default:
      break
    }
  }
  
  
  func accessGrantedForAddressBook() {
    addressBook.loadContacts( { (contacts: AnyObject[]!, error: NSError!) in
      if !error {
        for contact: AnyObject in contacts {
          var currentContact = contact as APContact
          if !currentContact.firstName { continue }
          if currentContact.phones.count == 0 { continue }
          for phone: AnyObject in currentContact.phones {
            self.contactList.addObject([
              "name": currentContact.firstName,
              "phone": phone as NSString
              ])
          }
        }
      }
      })
  }
  
  
  func getMobileNumbersArray() -> NSMutableArray {
    var newContactsList: NSMutableArray = []
    
    for person: NSDictionary! in self.contactList {
      if person.valueForKey("phone") {
        var digitOnlyNumber: NSString = SHSPhoneNumberFormatter.digitOnlyString(person.valueForKey("phone") as NSString)
        newContactsList.addObject("+\(digitOnlyNumber)")
      }
    }
    
    return newContactsList
  }
}