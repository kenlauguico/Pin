//
//  MainViewController.swift
//  Pin
//
//  Created by Ken on 6/19/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import UIKit

class MainViewController: UITableViewController {
                            
    var cellTitles: String[] = ["Um","Dois","Tres","Quatro","Cinco","Seis","Sete","Oito","Nove","Dez","+"]
    var friendList: PinFriend[] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initiateConnection()
        addMyself()
        
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
        var socketManager: SocketManager = SocketManager()
        
        socketManager.connect(appDelegate.sendingFromHandle, phone: appDelegate.sendingFrom)
    }
    
    func addMyself() {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var tempLocation: Location =  Location(lat: -19.9464264, long: -43.9241665, acc: 0)
        var myPin: PinFriend = PinFriend(friendName: appDelegate.sendingFromHandle, friendNumber: appDelegate.sendingFrom, friendLocation: tempLocation)
        
        addFriend(myPin)
    }
    
    func addFriend(friend: PinFriend!) {
        friendList.append(friend)
    }
    
    func tappedOnMap(recognizer: UIGestureRecognizer!) {
        var cellImageViewTapped: UIImageView = recognizer.view as UIImageView
        
        MapUtil().launchMapApp(friendList[cellImageViewTapped.tag].location)
    }
    
    func gotNewPin(notification: NSNotification) {
        
    }
    
    func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotNewPin:", name: "gotNewPin", object: nil)
    }
    
    
    //#pragma mark - UITableViewCell Subclass
    
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


    //#pragma mark - UITableViewDataSource
    
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
            
            cell.text = currentFriend.name
            cell.image = currentFriend.map
            cell.imageView.contentMode = UIViewContentMode.ScaleToFill
            
            cell.imageView.tag = indexPath.row
            cell.imageView.userInteractionEnabled = true
            cell.imageView.addGestureRecognizer(tapped)
        } else {
            // the add button
            cell.text = "+"
        }
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width*2)
    
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        appDelegate.getLocation(friendList[indexPath.row].number)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
        return true
    }

    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        println("Attempting to delete")
    }

}

