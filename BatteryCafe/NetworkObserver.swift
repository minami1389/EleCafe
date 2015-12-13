//
//  NetworkObserver.swift
//  BatteryCafe
//
//  Created by Baba Minami on 12/13/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit
import Reachability

enum ReachabilityNotificationName: String {
    case Connect = "Connection"
    case DisConnect = "DisConnection"
}

class NetworkObserver: NSObject {
    
    var internetReachability:Reachability!
    var wifiReachability:Reachability!
    var connectable = false
    
    class var sharedInstance: NetworkObserver {
        struct Singleton {
            static var instance = NetworkObserver()
        }
        return Singleton.instance
    }
    
    func startReachability() -> Bool {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
        internetReachability = Reachability.reachabilityForInternetConnection()
        internetReachability.startNotifier()
        wifiReachability = Reachability.reachabilityForLocalWiFi()
        wifiReachability.startNotifier()
        let connectable3G = connectableWithReachability(internetReachability)
        let connectableWifi = connectableWithReachability(wifiReachability)
        connectable = connectable3G || connectableWifi
        return connectable3G || connectableWifi
    }
    
    func connectableWithReachability(reachability:Reachability) -> Bool {
        return reachability.currentReachabilityStatus() != .NotReachable
    }
    
    func reachabilityChanged(note:NSNotification) {
        if let reachability = note.object as? Reachability {
            if connectable != connectableWithReachability(reachability) {
                connectable = !connectable
                var notificationName = ""
                if connectable {
                    notificationName = ReachabilityNotificationName.Connect.rawValue
                } else {
                    notificationName = ReachabilityNotificationName.DisConnect.rawValue
                }
                let notification = NSNotification(name: notificationName, object: nil)
                NSNotificationCenter.defaultCenter().postNotification(notification)
            }
        }
    }
    
}
