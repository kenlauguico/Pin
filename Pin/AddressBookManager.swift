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
  
  
// MARK: - Public Methods -
  
  override init() {
    addressBook = APAddressBook()
  }
  
  func checkAddressBookAccess() {
    switch APAddressBook.access().value {
    case APAddressBookAccessGranted.value:
      accessGrantedForAddressBook()
      break
      
    case APAddressBookAccessUnknown.value:
      accessGrantedForAddressBook()
      break
      
    case APAddressBookAccessDenied.value:
      var alert: UIAlertView = UIAlertView(title: "Privacy Warning", message: "Permission was not granted for Contacts.", delegate: self, cancelButtonTitle: "OK")
      alert.show()
      break
      
    default:
      break
    }
  }
  
  func getMobileNumbersArray() -> NSMutableArray {
    var newContactsList: NSMutableArray = []
    
    for person in self.contactList {
      if (person.valueForKey("phone") != nil) {
        var digitOnlyNumber: NSString = SHSPhoneNumberFormatter.digitOnlyString(person.valueForKey("phone") as NSString)
        newContactsList.addObject("+\(digitOnlyNumber)")
      }
    }
    
    return newContactsList
  }
  
  
// MARK: - Private Methods -
  
  private func accessGrantedForAddressBook() {
    contactList = []
    addressBook.loadContacts( { (contacts: [AnyObject]!, error: NSError!) in
      if (error == nil) {
        self.populatedContactList(contacts, contactList: self.contactList)
      }
    })
  }
  
  private func populatedContactList(contacts: [AnyObject], contactList: [AnyObject]) {
    for contact: AnyObject in contacts {
      var currentContact = contact as APContact
      
      if !(isContactValid(currentContact)) { continue }
      
      for phone: AnyObject in currentContact.phones {
        self.contactList.addObject([
          "name": currentContact.firstName,
          "phone": phone as NSString
          ])
      }
    }
  }
  
  private func isContactValid(contact: APContact) -> Bool {
    return !(contact.firstName == nil || contact.phones.count == 0)
  }
  
}