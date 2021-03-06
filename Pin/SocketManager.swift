//
//  SocketManager.swift
//  Pin
//
//  Created by Ken on 6/20/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation


class SocketManager: SocketIO {

  var socketHost = "104.131.237.85"
  var socketPort: Int = 8080
  var socketManager: SocketIO!
  var userPhone: NSString! = nil
  var reconnectTimer: NSTimer = NSTimer()


// MARK: - Public Methods -

  override init() {
    super.init()
    socketManager = SocketIO(delegate: self)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "startTimer", name: "reconnect", object: nil)
  }


  func connect(phone: NSString!) {
    userPhone = phone

    socketManager.connectToHost(socketHost, onPort: socketPort)
  }
  

  func disconnectSocket() {
    socketManager.disconnect()
  }
  

  func reconnect() {
    socketManager.connectToHost(socketHost, onPort: socketPort)
  }


  func sendLocation(to: NSString!, let position: Location!) {
    var params = [
      "to_cellphone_number": to,
      "location": position.asDictionary()
    ]

    socketManager.sendEvent("location", withData: params)
  }
  

  func requestContactList(numbersArray: NSArray) {
    var params = numbersArray
    socketManager.sendEvent("filter_contact_list", withData: params)
  }


// MARK: - Private Methods -

  func startTimer() {
    reconnectTimer.invalidate()
    UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in }
    reconnectTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "reconnect", userInfo: nil, repeats: true)
    NSRunLoop.currentRunLoop().addTimer(reconnectTimer, forMode: NSRunLoopCommonModes)
  }
}


// MARK: - SocketIODelegate -

extension SocketManager: SocketIODelegate {

  func socketIODidConnect(socket: SocketIO) {
    var params = ["cellphone_number": userPhone]

    socketManager.sendEvent("login", withData: params)
    NSUserDefaults.standardUserDefaults().setValue(userPhone, forKey: "sendingFrom")
    reconnectTimer.invalidate()
  }

  
  func socketIODidDisconnect(socket: SocketIO, disconnectedWithError error: NSError) {
    NSNotificationCenter.defaultCenter().postNotificationName("disconnected", object: nil)
    startTimer()
  }

  
  func socketIO(socket: SocketIO, onError error: NSError) {
    startTimer()
  }

  
  func socketIO(socket: SocketIO, didReceiveEvent packet: SocketIOPacket) {

    switch packet.name {
    case "connected":
      NSNotificationCenter.defaultCenter().postNotificationName("connected", object: nil)
      break

    case "pin":
      NSNotificationCenter.defaultCenter().postNotificationName("gotNewPin", object: self, userInfo: packet.args[0] as NSDictionary)
      break

    case "filtered_contact_list":
      var userInfo = ["numbers": packet.args[0]]
      NSNotificationCenter.defaultCenter().postNotificationName("gotContacts", object: self, userInfo: userInfo as NSDictionary)
      break

    default:
      break
    }
  }
  
}