//
//  SocketManager.swift
//  Pin
//
//  Created by Ken on 6/20/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation


class SocketManager: SocketIO {
    
    var socketHost = "192.168.25.3"
    var socketPort: Int = 8080
    var socketManager: SocketIO!
    var userName: NSString! = nil
    var userPhone: NSString! = nil
    
    
    init() {
        super.init()
        socketManager = SocketIO(delegate: self)
    }
    
    func connect(name: NSString!, phone: NSString!) {
        userName = name
        userPhone = phone
        
        socketManager.connectToHost(socketHost, onPort: socketPort)
    }
    
    func sendLocation(to: NSString!, let position: Location!) {
        var params = [
            "to_cellphone_number": to,
            "location": position.location
        ]
        
        socketManager.sendEvent("location", withData: params)
        println(params)
    }
}


//#pragma mark - SocketIODelegate -

extension SocketManager: SocketIODelegate {
    
    func socketIODidConnect(socket: SocketIO) {
        var params = [
            "username": userName,
            "cellphone_number": userPhone
        ]
        
        socketManager.sendEvent("login", withData: params)
        NSNotificationCenter.defaultCenter().postNotificationName("connected", object: nil)
    }
    
    func socketIODidDisconnect(socket: SocketIO, disconnectedWithError error: NSError) {
        NSNotificationCenter.defaultCenter().postNotificationName("disconnected", object: nil)
    }
    
    func socketIO(socket: SocketIO, didReceiveEvent packet: SocketIOPacket) {
        if packet.name == "pin" {
            NSNotificationCenter.defaultCenter().postNotificationName("gotNewPin", object: self, userInfo: packet.args[0] as NSDictionary)
        } else if packet.name == "connected" {
            NSNotificationCenter.defaultCenter().postNotificationName("connected", object: nil)
        }
    }
}