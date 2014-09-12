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

  var friendList: [PinFriend] = PinFriendUtil().getFriends()
  var friends = Dictionary<String, PinFriend>()
  var addTextBox: SHSPhoneTextField!
  var newUserPhone: NSString?
  var addressBook: AddressBookManager = AddressBookManager()
  let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
  var silentRefreshTimer: NSTimer = NSTimer()


// MARK: - UITableViewController Methods -
  
  override func viewDidLoad() {
    super.viewDidLoad()

    initiateConnection()
    addObservers()
    addressBook.checkAddressBookAccess()
    PinFriendUtil().syncFriends(friendList)
    friendListToDict()
    addRefreshControl()
    makeFooter()

    tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.backgroundColor = UIColor.clearColor()
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
  }

  
  override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  
  override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
   makeFooter()
  }
}


// MARK: - UITableViewCell Subclass and UITableViewDataSource -

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
    addTextBox.placeholder = "Enter a phone number".lowercaseString
    addTextBox.adjustsFontSizeToFitWidth = true
    addTextBox.delegate = self
    addTextBox.tag = tag
  }

  
  class UITableViewCellFix: UITableViewCell {

    override func layoutSubviews() {
      super.layoutSubviews()

      var imageFrame = imageView?.frame
      imageFrame?.origin = CGPointZero
      imageFrame?.size = cellImageSize
      imageFrame?.size.width += 12

      imageView?.frame = imageFrame!
    }
  }

  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var cell = UITableViewCellFix(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
    var currentFriend = friendList[indexPath.row] as PinFriend
    var uniqueColor = ((currentFriend.number as NSString!).substringWithRange(NSMakeRange(1, 9)) as NSString).integerValue
    var tapped: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tappedOnMap:")
    
    if (currentFriend.number != nil) {
      var who: NSString! = (currentFriend.name != nil) ? currentFriend.name as NSString! : currentFriend.number as NSString!
      if (currentFriend.city != nil) {
        cell = UITableViewCellFix(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        DefaultCellStyle.subtitle().stylize(cell)
        cell.textLabel?.text = currentFriend.city
        cell.detailTextLabel?.text = "from \(who.lowercaseString)"
      } else {
        cell.textLabel?.text = who.lowercaseString
      }
      cell.imageView?.image = currentFriend.map
      cell.imageView?.contentMode = UIViewContentMode.ScaleToFill

      cell.imageView?.tag = indexPath.row
      cell.imageView?.userInteractionEnabled = true
      cell.imageView?.addGestureRecognizer(tapped)
    } else {
      setupAddTextBox(indexPath.row)
      cell.addSubview(addTextBox)
    }
    
    cell.backgroundColor = cellColors[uniqueColor % cellColors.count]
    tapped.numberOfTapsRequired = 1

    DefaultCellStyle().stylize(cell)
    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width*2)

    return cell
  }

  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    var friendTapped: PinFriend = friendList[indexPath.row] as PinFriend
    appDelegate.getLocation(friendTapped.number)
    updateFriend(friendTapped, mentionSent: true)
  }

  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return cellImageSize.height
  }

  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return friendList.count
  }

  
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }

  
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    friendList.removeAtIndex(indexPath.row)
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    PinFriendUtil().syncFriends(friendList)
    friendListToDict()
  }
}


// MARK: - Private View Methods -

extension MainViewController {
  
  func addFriend(friend: PinFriend) {
    var firstRow: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    
    friendList.insert(friend, atIndex: 0)
    tableView.insertRowsAtIndexPaths([firstRow], withRowAnimation: UITableViewRowAnimation.Top)
    
    silentRefresh()
  }
  
  
  func updateFriend(friend: PinFriend, mentionSent: Bool) {
    var currentFriend: PinFriend = PinFriendUtil().getFriendWithNumber(addressBook.contactList, number: friend.number!)
    var firstRow: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    var rowToHandle: NSIndexPath = firstRow
    var rowsToRemove: [NSIndexPath] = []
    var foundAtIndex: Int = 0
    var foundYet: Bool = false

    func indexPathRow(index: Int) -> NSIndexPath {
      return NSIndexPath(forRow: index, inSection: 0)
    }


    currentFriend.updateLocation(friend.location)
    
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
    
    if mentionSent {
      var currentCell = tableView.cellForRowAtIndexPath(rowToHandle)
      currentCell?.textLabel?.text = "Sent".lowercaseString
      if (currentCell?.detailTextLabel != nil) {
        var who: NSString! = (currentFriend.name != nil) ? currentFriend.name as NSString! : currentFriend.number as NSString!
        currentCell?.detailTextLabel?.text = "to \(who.lowercaseString)"
      }
    } else {
      tableView.reloadRowsAtIndexPaths([rowToHandle], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    tableView.moveRowAtIndexPath(rowToHandle, toIndexPath: firstRow)
    tableView.deleteRowsAtIndexPaths(rowsToRemove, withRowAnimation: UITableViewRowAnimation.Top)
    
    friendList.removeAtIndex(foundAtIndex)
    friendList.insert(currentFriend, atIndex: 0)
    
    silentRefresh()
  }
  
  
  func refreshTable() {
    UIView.transitionWithView(tableView, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
      self.tableView.reloadData()
      }, completion: nil)
  }
  
  
  func addRefreshControl() {
    var refresher = UIRefreshControl()
    refresher.addTarget(self, action: "refreshContacts", forControlEvents: UIControlEvents.ValueChanged)
    refreshControl = refresher
  }


  func showPushAlert(from: PinFriend) {
    if UIApplication.sharedApplication().applicationState != UIApplicationState.Background { return }
    
    var pushAlert: UILocalNotification = UILocalNotification()
    var now: NSDate = NSDate()
    
    if appDelegate.ios8() {
      pushAlert.category = "DEFAULT_CATEGORY"
    }
    
    pushAlert.alertBody = "from \(from.name!.uppercaseString)"
    pushAlert.fireDate = now.dateByAddingTimeInterval(0)
    pushAlert.userInfo = from.location?.asDictionary() as NSDictionary!
    
    UIApplication.sharedApplication().scheduleLocalNotification(pushAlert)
    UIApplication.sharedApplication().applicationIconBadgeNumber += 1
  }

// MARK: Tour

  func silentRefresh() {
    silentRefreshTimer.invalidate()
    UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in }
    silentRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(0.6, target: self, selector: "refreshTable", userInfo: nil, repeats: false)
    NSRunLoop.currentRunLoop().addTimer(silentRefreshTimer, forMode: NSRunLoopCommonModes)
  }
  
  
  func showTourRefresh() {
    var tooltip = CMPopTipView(message: TourGuide.tip.refresh)

    DefaultTooltipStyle().stylize(tooltip)
    tooltip.presentPointingAtView(refreshControl, inView: self.view, animated: true)
    TourGuide().setSeen(TGTip.refresh)
  }
  
  
  func showTourSend() {
    var tooltip = CMPopTipView(message: TourGuide.tip.send)

    DefaultTooltipStyle().stylize(tooltip)
    displayTooltipOnFirstCell(tooltip)
    TourGuide().setSeen(TGTip.send)
  }
  
  
  func showTourPin() {
    var tooltip = CMPopTipView(message: TourGuide.tip.pin)

    DefaultTooltipStyle().stylize(tooltip)
    displayTooltipOnFirstCell(tooltip)
    TourGuide().setSeen(TGTip.pin)
  }
  
  
  func showTourContacts() {
    var tooltip = CMPopTipView(message: TourGuide.tip.contacts)

    DefaultTooltipStyle().stylize(tooltip)
    tooltip.presentPointingAtView(refreshControl, inView: self.view, animated: true)
    TourGuide().setSeen(TGTip.contacts)
  }


  func displayTooltipOnFirstCell(tooltip: CMPopTipView) {
    var firstIndex = NSIndexPath(forRow: 0, inSection: 0)
    var firstCell = self.tableView.cellForRowAtIndexPath(firstIndex)
    
    tooltip.presentPointingAtView(firstCell, inView: self.view, animated: true)
  }
  
// MARK: Footer
  
  func makeFooter() {
    var logoAndVersionView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 130))
    logoAndVersionView.backgroundColor = DefaultFooterStyle().backgroundColor
    
    self.createAndAddLogo(logoAndVersionView)
    self.createAndAddTagline(logoAndVersionView)
    self.createAndAddVersion(logoAndVersionView)

    self.tableView.tableFooterView = logoAndVersionView
  }

  func createAndAddLogo(view: UIView) {
    var imageLogo = UIImage(named: "logo-pin-100.png")
    var imageLogoView = UIImageView(image: imageLogo)
    imageLogoView.frame = CGRectMake(0, 0, 50, 50)
    imageLogoView.center = CGPointMake(self.view.frame.width/2, 40)

    view.addSubview(imageLogoView)
  }

  func createAndAddTagline(view: UIView) {
    var labelTagline = UILabel(frame: CGRectMake(0, 60, self.view.frame.width, 30))
    labelTagline.text = "Made in Brazil"
    DefaultFooterStyle.tagline().stylize(labelTagline)

    view.addSubview(labelTagline)
  }

  func createAndAddVersion(view: UIView) {
    var labelVersion = UILabel(frame: CGRectMake(0, 77, self.view.frame.width, 30))
    var versionNumber = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as NSString
    labelVersion.text = "Version \(versionNumber)"
    DefaultFooterStyle.version().stylize(labelVersion)

    view.addSubview(labelVersion)
  }
}


// MARK: - Private Methods -

extension MainViewController {
  
  func initiateConnection() {
    appDelegate.socketManager.connect(appDelegate.sendingFrom)
  }
  
  
  func connected() {
    requestContacts()
  }
  
  
  func refreshContacts() {
    appDelegate.socketManager.disconnectSocket()
    addressBook.checkAddressBookAccess()
  }
  
  
  func tappedOnMap(recognizer: UIGestureRecognizer!) {
    var cellImageViewTapped: UIImageView = recognizer.view as UIImageView
    var friendTapped: PinFriend = friendList[cellImageViewTapped.tag] as PinFriend
    
    MapUtil().launchMapApp(friendTapped.location)
  }
  
  
  func pressedViewMapAction(notification: NSNotification) {
    var location: Location = Location(dictionary: notification.userInfo!)
    MapUtil().launchMapApp(location)
  }
  
  
  func gotNewPin(notification: NSNotification) {
    var pinResponse: NSDictionary = notification.userInfo!
    var fromNumber: NSString = pinResponse["from_cellphone_number"] as NSString
    var fromLocation: Location  = Location(dictionary: pinResponse["location"] as NSDictionary)
    var fromFriend: PinFriend = PinFriend(friendNumber: fromNumber, friendLocation: fromLocation)
    
    if !TourGuide().seenPinTip {
      var delayedTip = NSTimer.scheduledTimerWithTimeInterval(TourGuide().tipDelay, target: self, selector: "showTourPin", userInfo: nil, repeats: false)
      NSRunLoop.currentRunLoop().addTimer(delayedTip, forMode: NSRunLoopCommonModes)
    }
    
    if friendList.exists(fromFriend) {
      updateFriend(fromFriend, mentionSent: false)
    } else {
      addFriend(fromFriend)
    }
    
    AudioServicesPlaySystemSound(1007)
    PinFriendUtil().syncFriends(friendList)
    friendListToDict()
    
    if (friends[fromFriend.number!] != nil) {
      fromFriend = friends[fromFriend.number!] as PinFriend!
    }
    
    showPushAlert(fromFriend)
  }
  
  
  func requestContacts() {
    appDelegate.socketManager.requestContactList(addressBook.getMobileNumbersArray())
  }
  
  
  func friendListToDict() {
    for friend: PinFriend in friendList {
      friends[friend.number!] = friend
    }
  }
  
  
  func gotContacts(notification: NSNotification) {
    var pinResponse: NSArray = notification.userInfo!["numbers"] as NSArray

    refreshControl?.endRefreshing()
    
    if pinResponse.count == 0 {
      refreshTable()
      if !TourGuide().seenContactsTip {
        var delayedTipContacts = NSTimer.scheduledTimerWithTimeInterval(TourGuide().tipDelay, target: self, selector: "showTourContacts", userInfo: nil, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(delayedTipContacts, forMode: NSRunLoopCommonModes)
        
        var delayedTipRefresh = NSTimer.scheduledTimerWithTimeInterval(TourGuide().tipDelay, target: self, selector: "showTourRefresh", userInfo: nil, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(delayedTipRefresh, forMode: NSRunLoopCommonModes)
      }
      return
    }
    
    var newFriendList = PinFriendUtil().numberArrayToFriendList(self.addressBook.contactList, numbersArray: pinResponse)
    var updatedFriendList = PinFriendUtil().mergeFriendList(friendList, rightList: newFriendList)
    friendList = updatedFriendList
    PinFriendUtil().syncFriends(friendList)
    friendListToDict()
    silentRefresh()
    
    if !TourGuide().seenSendTip {
      var delayedTip = NSTimer.scheduledTimerWithTimeInterval(TourGuide().tipDelay, target: self, selector: "showTourSend", userInfo: nil, repeats: false)
      NSRunLoop.currentRunLoop().addTimer(delayedTip, forMode: NSRunLoopCommonModes)
    }
    
    if !TourGuide().seenRefreshTip {
      var delayedTip = NSTimer.scheduledTimerWithTimeInterval(TourGuide().tipDelay, target: self, selector: "showTourRefresh", userInfo: nil, repeats: false)
      NSRunLoop.currentRunLoop().addTimer(delayedTip, forMode: NSRunLoopCommonModes)
    }
  }
  
  
  func addObservers() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "initiateConnection", name: "disconnected", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "connected", name: "connected", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotNewPin:", name: "gotNewPin", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotContacts:", name: "gotContacts", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "pressedViewMapAction:", name: "pressedViewMapAction", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "backupFriends", name: "backupFriends", object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "silentRefresh", name: "silentRefresh", object: nil)
  }
  
  
  func backupFriends() {
    PinFriendUtil().syncFriends(friendList)
  }
}


// MARK: - UITextFieldDelegate -

extension MainViewController: UITextFieldDelegate {

  func textFieldDidEndEditing(textField: UITextField!) {
    if textField == addTextBox {
      newUserPhone = addTextBox?.phoneNumber()
      friendList[0].number = newUserPhone
      updateFriend(friendList[0], mentionSent: false)
    }
  }
  

  func textFieldShouldReturn(textField: UITextField!) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}
