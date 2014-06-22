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
                            
    var friendList: PinFriend[] = [] //NSUserDefaults.standardUserDefaults().objectForKey("friendList") as PinFriend[]
    var addTextBox: SHSPhoneTextField!
    var newUserPhone: NSString?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initiateConnection()
        addObservers()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    //#pragma mark - Private Methods -
    
    func initiateConnection() {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        appDelegate.socketManager.connect(appDelegate.sendingFromHandle, phone: appDelegate.sendingFrom)
    }
    
    func addOrUpdateFriend(friend: PinFriend!) {
        var indexOfFriend: Int? = checkIfFriendExists(friend)
        var firstRow: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        var lastFriend: NSIndexPath = NSIndexPath(forRow: friendList.count-1, inSection: 0)
        
        
        if indexOfFriend {
            var rowToHandle: NSIndexPath = NSIndexPath(forRow: indexOfFriend!, inSection: 0)
            
            self.tableView.reloadRowsAtIndexPaths([rowToHandle], withRowAnimation: UITableViewRowAnimation.Fade)
            friendList.removeAtIndex(indexOfFriend!)
            friendList.insert(friend, atIndex: 0)
            self.tableView.moveRowAtIndexPath(rowToHandle, toIndexPath: firstRow)
        } else {
            friendList.insert(friend, atIndex: 0)
            self.tableView.insertRowsAtIndexPaths([firstRow], withRowAnimation: UITableViewRowAnimation.Top)
        }
        
        self.tableView.reloadRowsAtIndexPaths([lastFriend], withRowAnimation: UITableViewRowAnimation.Fade)
        syncFriends()
    }
    
    func checkIfFriendExists(friend: PinFriend!) -> Int? {
        for (index: Int, myFriend: PinFriend) in enumerate(friendList) {
            if myFriend.number == friend.number {
                friendList[index] = friend
                return index
            }
        }
        
        return nil
    }
    
    func syncFriends() {
        //NSUserDefaults.standardUserDefaults().setObject(friendList, forKey: "friendList")
    }
    
    func tappedOnMap(recognizer: UIGestureRecognizer!) {
        var cellImageViewTapped: UIImageView = recognizer.view as UIImageView
        var friendTapped: PinFriend = friendList[cellImageViewTapped.tag] as PinFriend
        
        MapUtil().launchMapApp(friendTapped.location)
    }
    
    func gotNewPin(notification: NSNotification) {
        var pinResponse: NSDictionary = notification.userInfo
        var fromName: NSString = pinResponse["from_username"] as NSString
        var fromNumber: NSString = pinResponse["from_cellphone_number"] as NSString
        var fromLocation: Location  = Location(dictionary: pinResponse["location"] as NSDictionary)
        var friendToAdd: PinFriend = PinFriend(friendName: fromName.uppercaseString, friendNumber: fromNumber, friendLocation: fromLocation)
        
        addOrUpdateFriend(friendToAdd)
        showPushAlert(fromName)
        AudioServicesPlaySystemSound(1007)
    }
    
    func showPushAlert(from: NSString) {
        if UIApplication.sharedApplication().applicationState != UIApplicationState.Background { return }
        
        var pushAlert: UILocalNotification = UILocalNotification()
        var now: NSDate = NSDate()
        
        pushAlert.alertBody = "from \(from.uppercaseString)"
        pushAlert.fireDate = now.dateByAddingTimeInterval(0)
        
        UIApplication.sharedApplication().scheduleLocalNotification(pushAlert)
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotNewPin:", name: "gotNewPin", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "initiateConnection", name: "disconnected", object: nil)
    }
}


//#pragma mark - UITableViewCell Subclass and UITableViewDataSource

extension MainViewController {
    
    func setupAddTextBox(tag: Int) {
        var textBoxFrame = CGRectMake(0, 0, self.view.frame.size.width, cellImageSize.height)
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
            
            var imageFrame: CGRect = self.imageView.frame
            imageFrame.origin = CGPointZero
            imageFrame.size = cellImageSize
            imageFrame.size.width += 12
            
            self.imageView.frame = imageFrame
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
            let currentFriend = friendList[indexPath.row] as PinFriend
            var tapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tappedOnMap:")
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
            cell.text = "+"
        }
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width*2)
        
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row != friendList.count {
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            var friendTapped: PinFriend = friendList[indexPath.row] as PinFriend
            
            appDelegate.getLocation(friendTapped.number)
            addOrUpdateFriend(friendTapped)
        } else {
            var emptyFriend: PinFriend = PinFriend(friendName: nil, friendNumber: nil, friendLocation: Location())
            addOrUpdateFriend(emptyFriend)
            
            var lastIndexPath: NSIndexPath = NSIndexPath(forRow: friendList.count, inSection: 0)
            var currentCell = self.tableView.cellForRowAtIndexPath(lastIndexPath) as UITableViewCell
            currentCell.text = "Done".uppercaseString
            
            if addTextBox.text != "" {
                addTextBox.resignFirstResponder()
                currentCell.text = "+"
                return
            }
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
        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}


//#pragma mark - UITextFieldDelegate

extension MainViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(textField: UITextField!) {
        if textField == addTextBox {
            newUserPhone = addTextBox?.phoneNumber()
            friendList[0].number = newUserPhone
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        if textField == addTextBox {
            var firstRow: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            
            newUserPhone = textField.text
            self.tableView.reloadRowsAtIndexPaths([firstRow], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        return false
    }
}