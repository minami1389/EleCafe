//
//  CafeModel.swift
//  BatteryCafe
//
//  Created by minami on 10/13/15.
//  Copyright (c) 2015 TeamDeNA. All rights reserved.
//

import UIKit
import CoreLocation

class CafeModel: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
   
    var resources = [CafeData]()
   
    func getResources() -> [CafeData] {
        return resources
    }
    
    func fetchCafes(coordinate: CLLocationCoordinate2D) {
        var n = Float(coordinate.latitude + 0.1)
        if n > 90 {
            n -= 0.02
        }
        var s = Float(coordinate.latitude - 0.1)
        if s < -90 {
            s += 0.02
        }
        var w = Float(coordinate.longitude - 0.1)
        if w <= -180 {
            w += 0.02
            
        }
        var e = Float(coordinate.longitude + 0.1)
        if e > 180 {
            e -= 0.02
        }
        requestOasisApi(n, west: w, south: s, east: e)
    }

    
    func requestOasisApi(north: Float, west: Float, south: Float, east: Float) {
        var urlString = "http://oasis.mogya.com/api/v0/search?"
        urlString += "n=\(north)"
        urlString += "&w=\(west)"
        urlString += "&s=\(south)"
        urlString += "&e=\(east)"
        print(urlString)
        let url = NSURL(string: urlString)!
        let task = NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { data, response, error in
            if error != nil {
                print("error:")
                print(error)
                return
            }
        
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary

                guard let _ = json["status"] as? String else { return }
                var cafeResources = self.resources
                if let cafes = json["results"] as? NSArray {
                    for cafe in cafes {
                        let cafeData = CafeData(cafe: cafe as! NSDictionary)
                        if self.isNewCafeData(cafeData) {
                            cafeResources.append(cafeData)
                        }
                    }
                    self.resources = cafeResources
                    NSNotificationCenter.defaultCenter().postNotificationName("didFetchCafeResourcesMap", object: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("didFetchCafeResourcesList", object: nil)
                }
                } catch {}
        })
        task.resume()
    }
    
    func isNewCafeData(cafeData: CafeData) -> Bool {
        for cafe in self.resources {
            if cafeData.isEqualCafeData(cafe) {
                return false
            }
        }
        return true
    }
}
