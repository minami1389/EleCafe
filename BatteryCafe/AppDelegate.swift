//
//  AppDelegate.swift
//  BatteryCafe
//
//  Created by minami on 10/13/15.
//  Copyright (c) 2015 TeamDeNA. All rights reserved.
//

import UIKit
import GoogleMaps
import Google

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tracker: GAITracker?
    
    let kGoogleMapsAPIkey = "AIzaSyDn7-msc2L2PoTvjlOoArxJwIfyFCXs1PU"
    let kGoogleAnalyticsTrackingId = "UA-72207177-1"
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        GMSServices.provideAPIKey(kGoogleMapsAPIkey)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    
        let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        self.initGoogleAnalytics();
        
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
    
    func initGoogleAnalytics() -> Void {
        GAI.sharedInstance().trackUncaughtExceptions = true;
        GAI.sharedInstance().dispatchInterval = 20
//        GAI.sharedInstance().logger.logLevel = GAILogLevel.Verbose
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.tracker = GAI.sharedInstance().trackerWithTrackingId(kGoogleAnalyticsTrackingId)
        }
    }
}

