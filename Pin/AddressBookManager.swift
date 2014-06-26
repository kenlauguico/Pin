//
//  AddressBookManager.swift
//  Pin
//
//  Created by Ken on 6/24/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation
import AddressBook
import AddressBookUI


class AddressBookManager: NSObject {
    
    var addressBook: ABAddressBookRef
    var contactList: NSMutableArray = []
    
    init() {
        addressBook = ABAddressBookCreateWithOptions(nil, nil)
    }
    
    func checkAddressBookAccess() {
        switch(ABAddressBookGetAuthorizationStatus()) {
        case ABAuthorizationStatus.Authorized:
            self.accessGrantedForAddressBook()
            break
            
        case ABAuthorizationStatus.NotDetermined:
            self.requestAddressBookAccess()
            break
            
        case ABAuthorizationStatus.Denied, ABAuthorizationStatus.Restricted:
            var alert: UIAlertView = UIAlertView(title: "Privacy Warning", message: "Permission was not granted for Contacts.", delegate: self, cancelButtonTitle: "OK")
            
            alert.show()
            
            break
        default:
            break
        }
    }
    
    func requestAddressBookAccess() {
        
        ABAddressBookRequestAccessWithCompletion(addressBook, {
            (granted: CBool, error: CFError!) in
            if granted {
                self.accessGrantedForAddressBook()
            }
            })
    }
    
    func accessGrantedForAddressBook() {
        
        var allPeople: CFArray = ABAddressBookCopyArrayOfAllPeople(addressBook).takeUnretainedValue()
        var nPeople: CFIndex = ABAddressBookGetPersonCount(addressBook)
        
        for ref: ABRecordRef in allPeople.__conversion() {
            var dOfPerson: NSMutableDictionary = NSMutableDictionary()
            var phones: ABMultiValueRef = ABRecordCopyValue(ref, kABPersonPhoneProperty)
            var firstName: ABMultiValueRef = ABRecordCopyValue(ref, kABPersonFirstNameProperty)
            
            dOfPerson.setValue(firstName as NSString, forKey: "name")
            
            var mobileLabel: ABMultiValueRef
            
            for i: CFIndex in 0...ABMultiValueGetCount(phones) {
                let mobileLabel: CFString = ABMultiValueCopyLabelAtIndex(phones, i).takeUnretainedValue()
                if mobileLabel == kABPersonPhoneMobileLabel! {
                    dOfPerson.setValue(ABMultiValueCopyValueAtIndex(phones, i) as ABMultiValueRef as NSString, forKey: "phone")
                } else if mobileLabel == kABPersonPhoneIPhoneLabel! {
                    dOfPerson.setValue(ABMultiValueCopyValueAtIndex(phones, i) as ABMultiValueRef as NSString, forKey: "phone")
                    break
                }
            }
            self.contactList.addObject(dOfPerson)
        }
    }
    
    func getContactsWithMobileNumbers() -> NSMutableArray {
        var newContactsList: NSMutableArray = []
        
        for person: NSDictionary! in self.contactList {
            if person.valueForKey("phone") {
                var digitOnlyNumber: NSString = SHSPhoneNumberFormatter.digitOnlyString(person.valueForKey("phone") as NSString)
                newContactsList.addObject(digitOnlyNumber)
            }
        }
        
        return newContactsList
    }
}