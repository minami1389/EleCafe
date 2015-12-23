//
//  AppDelegate.swift
//  BatteryCafe
//
//  Created by minami on 10/13/15.
//  Copyright (c) 2015 TeamDeNA. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let cGoogleMapsAPIkey = "AIzaSyDn7-msc2L2PoTvjlOoArxJwIfyFCXs1PU"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        GMSServices.provideAPIKey(cGoogleMapsAPIkey)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    
        let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
    
        return true
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        let batteryLebel = UIDevice.currentDevice().batteryLevel
        if batteryLebel <= 20 {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            let notification = UILocalNotification()
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.alertBody = "充電が残り\(batteryLebel)%です\n周辺の電源スポットを探しましょう"
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        completionHandler(UIBackgroundFetchResult.NoData)
    }
}

