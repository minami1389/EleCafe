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
    
    let kGoogleMapsAPIKey = "AIzaSyBHlyIG7GgM0uNVCHg4EjWh6CALKvUfrKE"
    let kGoogleAnalyticsTrackingId = "UA-72207177-1"
    
    var didPushNotification = false
    

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        GMSServices.provideAPIKey(kGoogleMapsAPIKey)
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    
        let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(settings)
        
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        self.initGoogleAnalytics();
        
        UIDevice.currentDevice().batteryMonitoringEnabled = true
        
        let userDefault = NSUserDefaults.standardUserDefaults()
        if userDefault.boolForKey("didLaunchBefore") == false {
            userDefault.setBool(true, forKey: "didLaunchBefore")
            let setting = [true,true,true,true,true,true,true,true,false]
            NSUserDefaults.standardUserDefaults().setObject(setting, forKey: "setting")
        }
        
        return true
    }
    
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        showLocalNotification()
        completionHandler(UIBackgroundFetchResult.NoData)
    }
    
    func showLocalNotification() {
        let judgeBatteryLevel = 20
        let batteryLevel = Int(UIDevice.currentDevice().batteryLevel*100)
        if didPushNotification {
            didPushNotification = (batteryLevel <= judgeBatteryLevel)
            return
        }
        if batteryLevel <= judgeBatteryLevel && batteryLevel > 0 {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            let notification = UILocalNotification()
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.alertBody = "充電が少なくなっています。近くの電源を探しましょう。"
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
            didPushNotification = true
        }
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

