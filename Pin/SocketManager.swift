//
//  SocketManager.swift
//  Pin
//
//  Created by Ken on 6/20/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation


class SocketManager: SocketIO {
    
    var socketHost = "192.168.254.100"
    var socketPort: Int = 8080
    var socketManager: SocketIO!
    var userPhone: NSString! = nil
    var reconnectTimer: NSTimer = NSTimer()
    
    
    init() {
        super.init()
        socketManager = SocketIO(delegate: self)
    }
    
    func connect(phone: NSString!) {
        userPhone = phone
        
        socketManager.connectToHost(socketHost, onPort: socketPort)
    }
    
    func reconnect() {
        socketManager.connectToHost(socketHost, onPort: socketPort)
    }
    
    func sendLocation(to: NSString!, let position: Location!) {
        var params = [
            "to_cellphone_number": to,
            "location": position.location
        ]
        
        socketManager.sendEvent("location", withData: params)
    }
    
    func requestContactList(numbersArray: NSArray) {
        var params = numbersArray
        socketManager.sendEvent("filter_contact_list", withData: params)
    }
}


//#pragma mark - SocketIODelegate -

extension SocketManager: SocketIODelegate {
    
    func socketIODidConnect(socket: SocketIO) {
        var params = [
            "cellphone_number": userPhone
        ]
        
        socketManager.sendEvent("login", withData: params)
        NSNotificationCenter.defaultCenter().postNotificationName("connected", object: nil)
        reconnectTimer.invalidate()
        NSUserDefaults.standardUserDefaults().setValue(userPhone, forKey: "sendingFrom")
    }
    
    func socketIODidDisconnect(socket: SocketIO, disconnectedWithError error: NSError) {
        NSNotificationCenter.defaultCenter().postNotificationName("disconnected", object: nil)
        
        reconnectTimer.invalidate()
        UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
        reconnectTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "reconnect", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(reconnectTimer, forMode: NSRunLoopCommonModes)
    }
    
    func socketIO(socket: SocketIO, didReceiveEvent packet: SocketIOPacket) {
        if packet.name == "connected" {
            NSNotificationCenter.defaultCenter().postNotificationName("connected", object: nil)
        }
        
        if packet.name == "pin" {
            NSNotificationCenter.defaultCenter().postNotificationName("gotNewPin", object: self, userInfo: packet.args[0] as NSDictionary)
        }
        
        if packet.name == "filtered_contact_list" {
            var numbers = ["numbers": packet.args[0]]
            NSNotificationCenter.defaultCenter().postNotificationName("gotContacts", object: self, userInfo: numbers)
        }
    }
}