//
//  AppDelegate.swift
//  Pin
//
//  Created by Ken on 6/19/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

  var window: UIWindow?
  var registerviewController: RegisterViewController!
  var mainViewController: MainViewController!
  var locationManager = CLLocationManager()
  var socketManager: SocketManager = SocketManager()

  var didGetLocation: Bool = false
  var sendingTo: NSString? = nil
  var sendingFrom: NSString? = NSUserDefaults.standardUserDefaults().stringForKey("sendingFrom")


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
    locationManager.delegate = self;
    application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

    if ios8() {
      locationManager.requestAlwaysAuthorization()

      // Register notifications - Actions
      var viewMapAction: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
      viewMapAction.identifier = "ACTION_VIEWMAP"
      viewMapAction.title = "View Map"
      viewMapAction.activationMode = UIUserNotificationActivationMode.Foreground
      viewMapAction.destructive = false

      // Register notifications - Category
      var viewMapCategory: UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
      viewMapCategory.identifier = "DEFAULT_CATEGORY"

      let defaultActions: NSArray = [viewMapAction]
      viewMapCategory.setActions(defaultActions, forContext: UIUserNotificationActionContext.Default)
      viewMapCategory.setActions(defaultActions, forContext: UIUserNotificationActionContext.Minimal)

      let categories: NSSet = NSSet(objects: viewMapCategory)

      // Register notifications
      let alertTypes: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Badge
      let alertSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: alertTypes, categories: categories)

      UIApplication.sharedApplication().registerUserNotificationSettings(alertSettings)
    } else {
      let alertTypes: UIRemoteNotificationType = UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge
      UIApplication.sharedApplication().registerForRemoteNotificationTypes(alertTypes)
    }



    // Set root view controller
    let nav = application.windows[0].rootViewController as UINavigationController
    registerviewController = nav.viewControllers[0] as RegisterViewController
    nav.view.backgroundColor = cellColors[0]

    return true
  }

  func application(application: UIApplication!, handleActionWithIdentifier identifier: String!, forLocalNotification notification: UILocalNotification!, completionHandler: (() -> Void)!) {

    if (identifier != nil) {
      if identifier == "ACTION_VIEWMAP" {
        NSNotificationCenter.defaultCenter().postNotificationName("pressedViewMapAction", object: nil, userInfo: notification.userInfo)
      }
    }

    completionHandler()
  }
  
  func application(application: UIApplication!, performFetchWithCompletionHandler completionHandler: ((UIBackgroundFetchResult) -> Void)!) {
    NSNotificationCenter.defaultCenter().postNotificationName("reconnect", object: nil)
    completionHandler(UIBackgroundFetchResult.NewData)
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSNotificationCenter.defaultCenter().postNotificationName("backupFriends", object: nil)
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    application.applicationIconBadgeNumber = 0
    application.cancelAllLocalNotifications()
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


  //#pragma mark - Public Methods -

  func getLocation(sendTo: NSString!) {
    sendingTo = sendTo

    if ios8() {
      locationManager.requestWhenInUseAuthorization()
    }
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.startUpdatingLocation()
    didGetLocation = false
  }

  func launchMainViewController() {

    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let mainVC = storyboard.instantiateViewControllerWithIdentifier("main") as MainViewController
    let nav = UIApplication.sharedApplication().windows[0].rootViewController as UINavigationController

    nav.pushViewController(mainVC, animated: true)
  }


  //#pragma mark - Private Methods -

  func gotLocation() {
    locationManager.stopUpdatingLocation()
    didGetLocation = true
  }


  // iOS 8 Utility

  func ios8() -> Bool {

    println("iOS " + UIDevice.currentDevice().systemVersion)

    if ( UIDevice.currentDevice().systemVersion == "8.0" ) {
      return true
    } else {
      return false
    }

  }


  //#pragma mark - CLLocationManagerDelegate -

  func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
    var coordinates: CLLocationCoordinate2D! = newLocation.coordinate
    var accuracy: Int = Int(locationManager.location.verticalAccuracy);

    if (coordinates.latitude != 0 && !didGetLocation && sendingTo != nil) {

      var currentPosition = Location(loc: newLocation)

      socketManager.sendLocation(sendingTo, position: currentPosition)
      gotLocation()
    }
  }

}

