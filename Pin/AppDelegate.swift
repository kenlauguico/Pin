//
//  AppDelegate.swift
//  Pin
//
//  Created by Ken on 6/19/14.
//  Copyright (c) 2014 Bacana. All rights reserved.
//

import UIKit
import CoreData
import corelocation

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

    if ( ios8() ) {
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

    if identifier == "ACTION_VIEWMAP" {
      NSNotificationCenter.defaultCenter().postNotificationName("pressedViewMapAction", object: nil, userInfo: notification.userInfo)
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
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }

  func saveContext () {
    var error: NSError? = nil
    let managedObjectContext = self.managedObjectContext
    if managedObjectContext != nil {
      if managedObjectContext.hasChanges && !managedObjectContext.save(&error) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        //println("Unresolved error \(error), \(error.userInfo)")
        abort()
      }
    }
  }

  // #pragma mark - Core Data stack

  // Returns the managed object context for the application.
  // If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
  var managedObjectContext: NSManagedObjectContext {
    if !_managedObjectContext {
      let coordinator = self.persistentStoreCoordinator
      if coordinator != nil {
        _managedObjectContext = NSManagedObjectContext()
        _managedObjectContext!.persistentStoreCoordinator = coordinator
      }
    }
    return _managedObjectContext!
  }
  var _managedObjectContext: NSManagedObjectContext? = nil

  // Returns the managed object model for the application.
  // If the model doesn't already exist, it is created from the application's model.
  var managedObjectModel: NSManagedObjectModel {
    if !_managedObjectModel {
      let modelURL = NSBundle.mainBundle().URLForResource("Pin", withExtension: "momd")
      _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)
    }
    return _managedObjectModel!
  }
  var _managedObjectModel: NSManagedObjectModel? = nil

  // Returns the persistent store coordinator for the application.
  // If the coordinator doesn't already exist, it is created and the application's store added to it.
  var persistentStoreCoordinator: NSPersistentStoreCoordinator {
    if !_persistentStoreCoordinator {
      let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Pin.sqlite")
      var error: NSError? = nil
      _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
      if _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) == nil {
        /*
        Replace this implementation with code to handle the error appropriately.

        abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

        Typical reasons for an error here include:
        * The persistent store is not accessible;
        * The schema for the persistent store is incompatible with current managed object model.
        Check the error message to determine what the actual problem was.


        If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

        If you encounter schema incompatibility errors during development, you can reduce their frequency by:
        * Simply deleting the existing store:
        NSFileManager.defaultManager().removeItemAtURL(storeURL, error: nil)

        * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
        [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true}

        Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

        */
        //println("Unresolved error \(error), \(error.userInfo)")
        abort()
      }
    }
    return _persistentStoreCoordinator!
  }
  var _persistentStoreCoordinator: NSPersistentStoreCoordinator? = nil

  // #pragma mark - Application's Documents directory

  // Returns the URL to the application's Documents directory.
  var applicationDocumentsDirectory: NSURL {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.endIndex-1] as NSURL
  }


  //#pragma mark - Public Methods -

  func getLocation(sendTo: NSString!) {
    sendingTo = sendTo

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
    var coordinates: CLLocationCoordinate2D! = locationManager.location.coordinate
    var accuracy: Int = Int(locationManager.location.verticalAccuracy)

    if coordinates.latitude != 0 && !didGetLocation && sendingTo {

      var currentPosition = Location(lat: coordinates.latitude, long: coordinates.longitude, acc: accuracy)

      socketManager.sendLocation(sendingTo, position: currentPosition)
      gotLocation()
    }
  }

}

