//
//  NetworkManager.swift
//  Pin
//
//  Created by Ken on 6/19/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import Foundation

class NetworkManager: NSObject {
    
    var hostURL: NSString? = "http://postcatcher.in/catchers/"
    var networkManager: AFHTTPRequestOperationManager! = AFHTTPRequestOperationManager()
    var responseTextPlain: AFHTTPResponseSerializer! = AFHTTPResponseSerializer()
    
    
    func createUser(handle: String, phoneNumber: String, handler: ((NSString?) -> Void)) {
        var method = "53a5dbfc363da8020000005f"
        var params = ["handle": handle, "phone_number": phoneNumber]
        
        responseTextPlain.acceptableContentTypes = NSSet(object: "text/plain")
        networkManager.responseSerializer = responseTextPlain
        
        networkManager.POST(
            "\(hostURL!+method)",
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) in
                if response.responseString {
                    handler(response.responseString)
                } else {
                    handler(nil)
                }
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                println("Error: " + error.localizedDescription)
            })
    }
    
    func verifyUser(phoneNumbers: NSString[], handler: ((NSString) -> Void)) {
        var method = "53a36edc720a610200000990"
        var params = ["phone_numbers": phoneNumbers]
        
        responseTextPlain.acceptableContentTypes = NSSet(object: "text/plain")
        networkManager.responseSerializer = responseTextPlain
        
        networkManager.POST(
            "\(hostURL!+method)",
            parameters: params,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) in
                if response.responseString {
                    handler(response.responseString)
                }
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                println("Error: " + error.localizedDescription)
            })
    }
    
}