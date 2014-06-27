//
//  MainViewController.swift
//  Pin
//
//  Created by Ken on 6/19/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import UIKit
import AudioToolbox

class MainViewController: UITableViewController {
                            
    var friendList: PinFriend[] = getFriends()
    var addTextBox: SHSPhoneTextField!
    var newUserPhone: NSString?
    var addressBook: AddressBookManager = AddressBookManager()
    let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var silentRefreshTimer: NSTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initiateConnection()
        addObservers()
        addressBook.checkAddressBookAccess()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    //#pragma mark - Private Methods -
    
    func initiateConnection() {
        appDelegate.socketManager.connect(appDelegate.sendingFrom)
    }
    
    func connected() {
        if friendList.isEmpty {
            requestContacts()
        }
    }
    
    func tappedOnMap(recognizer: UIGestureRecognizer!) {
        var cellImageViewTapped: UIImageView = recognizer.view as UIImageView
        var friendTapped: PinFriend = friendList[cellImageViewTapped.tag] as PinFriend
        
        MapUtil().launchMapApp(friendTapped.location)
    }
    
    func pressedViewMapAction(notification: NSNotification) {
        var location: Location = Location(dictionary: notification.userInfo)
        MapUtil().launchMapApp(location)
    }
    
    func gotNewPin(notification: NSNotification) {
        var pinResponse: NSDictionary = notification.userInfo
        var fromNumber: NSString = pinResponse["from_cellphone_number"] as NSString
        var fromLocation: Location  = Location(dictionary: pinResponse["location"] as NSDictionary)
        var fromFriend: PinFriend = PinFriend(friendNumber: fromNumber, friendLocation: fromLocation)
        
        if friendList.exists(fromFriend) {
            updateFriend(fromFriend)
        } else {
            addFriend(fromFriend)
        }
        
        showPushAlert(fromFriend)
        AudioServicesPlaySystemSound(1007)
        syncFriends(friendList)
    }
    
    func requestContacts() {
        appDelegate.socketManager.requestContactList(addressBook.getMobileNumbersArray())
    }
    
    func gotContacts(notification: NSNotification) {
        var pinResponse: NSArray = notification.userInfo["numbers"] as NSArray
        if pinResponse.count == 0 { return }
        friendList = friendListFromNumbersArray(self.addressBook.contactList, pinResponse)
        tableView.reloadData()
        syncFriends(friendList)
    }
    
    func showPushAlert(from: PinFriend) {
        if UIApplication.sharedApplication().applicationState != UIApplicationState.Background { return }
        
        var pushAlert: UILocalNotification = UILocalNotification()
        var now: NSDate = NSDate()
        
        pushAlert.category = "DEFAULT_CATEGORY"
        pushAlert.alertBody = "from \(from.name!.uppercaseString)"
        pushAlert.fireDate = now.dateByAddingTimeInterval(0)
        pushAlert.userInfo = from.location?.location
        
        UIApplication.sharedApplication().scheduleLocalNotification(pushAlert)
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "initiateConnection", name: "disconnected", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "connected", name: "connected", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotNewPin:", name: "gotNewPin", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotContacts:", name: "gotContacts", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "pressedViewMapAction:", name: "pressedViewMapAction", object: nil)
    }
    
    func addFriend(friend: PinFriend) {
        var firstRow: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        friendList.insert(friend, atIndex: 0)
        tableView.insertRowsAtIndexPaths([firstRow], withRowAnimation: UITableViewRowAnimation.Top)
        
        silentRefresh()
    }
    
    func updateFriend(friend: PinFriend) {
        var currentFriend: PinFriend = getFriendWithNumber(addressBook.contactList, friend.number!)
        var firstRow: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        var rowToHandle: NSIndexPath = firstRow
        var rowsToRemove: NSIndexPath[] = []
        var foundAtIndex: Int = 0
        var foundYet: Bool = false
        
        currentFriend.updateLocation(friend.location)
        
        func indexPathRow(index: Int) -> NSIndexPath {
            return NSIndexPath(forRow: index, inSection: 0)
        }
        
        for (index, myFriend: PinFriend) in enumerate(friendList) {
            let frnd: PinFriend = myFriend as PinFriend
            
            if frnd.number == currentFriend.number && foundYet {
                friendList.removeAtIndex(index)
                rowsToRemove.append(indexPathRow(index))
                continue
            }
            
            if frnd.number == currentFriend.number {
                friendList[index] = currentFriend
                rowToHandle = indexPathRow(index)
                foundYet = true
                foundAtIndex = index
            }
        }
        
        tableView.reloadRowsAtIndexPaths([rowToHandle], withRowAnimation: UITableViewRowAnimation.Automatic)
        tableView.moveRowAtIndexPath(rowToHandle, toIndexPath: firstRow)
        tableView.deleteRowsAtIndexPaths(rowsToRemove, withRowAnimation: UITableViewRowAnimation.Top)
        
        friendList.removeAtIndex(foundAtIndex)
        friendList.insert(currentFriend, atIndex: 0)
        
        silentRefresh()
    }
    
    func refreshTable() {
        tableView.reloadData()
    }
    
    func silentRefresh() {
        silentRefreshTimer.invalidate()
        UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
        silentRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "refreshTable", userInfo: nil, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(silentRefreshTimer, forMode: NSRunLoopCommonModes)
    }
}


//#pragma mark - UITableViewCell Subclass and UITableViewDataSource

extension MainViewController {
    
    func setupAddTextBox(tag: Int) {
        var textBoxFrame = CGRectMake(0, 0, view.frame.size.width, cellImageSize.height)
        addTextBox = SHSPhoneTextField(frame: textBoxFrame)
        
        if NSLocale.currentLocale().localeIdentifier == "en_US" {
            addTextBox.formatter.setDefaultOutputPattern("+# (###) ###-####")
        } else {
            addTextBox.formatter.setDefaultOutputPattern("+## (##) ####-####")
        }
        
        addTextBox.font = defaultFont
        addTextBox.textColor = UIColor.whiteColor()
        addTextBox.textAlignment = NSTextAlignment.Center
        addTextBox.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        addTextBox.backgroundColor = UIColor.clearColor()
        addTextBox.keyboardType = UIKeyboardType.PhonePad
        addTextBox.placeholder = "Enter a phone number".uppercaseString
        addTextBox.adjustsFontSizeToFitWidth = true
        addTextBox.delegate = self
        addTextBox.tag = tag
    }
    
    class UITableViewCellFix: UITableViewCell {
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            var imageFrame: CGRect = imageView.frame
            imageFrame.origin = CGPointZero
            imageFrame.size = cellImageSize
            imageFrame.size.width += 12
            
            imageView.frame = imageFrame
        }
    }
    
    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = UITableViewCellFix(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        
        cell.textColor = UIColor.whiteColor()
        cell.font = defaultFont
        cell.textAlignment = NSTextAlignment.Center
        cell.backgroundColor = cellColors[indexPath.row % cellColors.count]
        cell.textLabel.adjustsFontSizeToFitWidth = true
        
        if indexPath.row != friendList.count {
            var currentFriend = friendList[indexPath.row] as PinFriend
            var uniqueColor = ((currentFriend.number as NSString).substringWithRange(NSMakeRange(1, 9)) as NSString).integerValue
            var tapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tappedOnMap:")
            
            cell.backgroundColor = cellColors[uniqueColor % cellColors.count]
            tapped.numberOfTapsRequired = 1
            
            if currentFriend.number {
                cell.text = currentFriend.name ? currentFriend.name : currentFriend.number
                cell.image = currentFriend.map
                cell.imageView.contentMode = UIViewContentMode.ScaleToFill
                
                cell.imageView.tag = indexPath.row
                cell.imageView.userInteractionEnabled = true
                cell.imageView.addGestureRecognizer(tapped)
            } else {
                setupAddTextBox(indexPath.row)
                cell.addSubview(addTextBox)
            }
        } else {
            cell.text = "Refresh".uppercaseString
        }
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width*2)
        
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row != friendList.count {
            var friendTapped: PinFriend = friendList[indexPath.row] as PinFriend
            appDelegate.getLocation(friendTapped.number)
            updateFriend(friendTapped)
        } else {
            appDelegate.socketManager.disconnectSocket()
            addressBook.checkAddressBookAccess()
            friendList = []
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return cellImageSize.height
    }
    
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return friendList.count + 1
    }
    
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row != friendList.count
    }
    
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        friendList.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        syncFriends(friendList)
    }
}


//#pragma mark - UITextFieldDelegate

extension MainViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField!) {
        if textField == addTextBox {
            newUserPhone = addTextBox?.phoneNumber()
            friendList[0].number = newUserPhone
            updateFriend(friendList[0])
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}


extension Array {
    
    mutating func add(friend: T, table: UITableView) {
        var firstRow: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        insert(friend, atIndex: 0)
        table.insertRowsAtIndexPaths([firstRow], withRowAnimation: UITableViewRowAnimation.Top)
    }
    
    mutating func update(friend: T, table: UITableView) {
        var currentFriend: PinFriend = friend as PinFriend
        var firstRow: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        var rowToHandle: NSIndexPath = firstRow
        var rowsToRemove: NSIndexPath[] = []
        var foundAtIndex: Int = 0
        var foundYet: Bool = false
        
        func indexPathRow(index: Int) -> NSIndexPath {
            return NSIndexPath(forRow: index, inSection: 0)
        }
        
        for (index, myFriend: T) in enumerate(self) {
            let frnd: PinFriend = myFriend as PinFriend
            
            if frnd.number == currentFriend.number && foundYet {
                removeAtIndex(index)
                rowsToRemove.append(indexPathRow(index))
                continue
            }
            
            if frnd.number == currentFriend.number {
                self[index] = friend
                rowToHandle = indexPathRow(index)
                foundYet = true
                foundAtIndex = index
            }
        }
        
        table.reloadRowsAtIndexPaths([rowToHandle], withRowAnimation: UITableViewRowAnimation.Fade)
        table.moveRowAtIndexPath(rowToHandle, toIndexPath: firstRow)
        table.deleteRowsAtIndexPaths(rowsToRemove, withRowAnimation: UITableViewRowAnimation.Top)
        
        removeAtIndex(foundAtIndex)
        insert(friend, atIndex: 0)
    }
    
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