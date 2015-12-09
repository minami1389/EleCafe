//
//  CafeModel.swift
//  BatteryCafe
//
//  Created by minami on 10/13/15.
//  Copyright (c) 2015 TeamDeNA. All rights reserved.
//

import UIKit
import CoreLocation

enum Distance: Double {
    case Narrow = 2.0
    case Wide = 10.0
}

class CafeModel: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
    
    private let earthRadius = 6378.137
    
    private var distance = Distance.Narrow
    
    var resources = [CafeData]()
   
    func getResources() -> [CafeData] {
        return resources
    }
    
    func fetchCafes(coordinate: CLLocationCoordinate2D!, dis:Distance) {
        
        let longitudeDistance = earthRadius * 2 * cos(coordinate.latitude * M_PI / 180) * M_PI / 360
        let latitudeDistance = earthRadius * M_PI / 360
        
        distance = dis
        let longitudeDiff = distance.rawValue / longitudeDistance
        let latitudeDiff = distance.rawValue / latitudeDistance
        
        var n = coordinate.latitude + latitudeDiff
        if n > 90 {
            n -= latitudeDiff * 2
        }
        var s = coordinate.latitude - latitudeDiff
        if s < -90 {
            s += latitudeDiff * 2
        }
        var w = coordinate.longitude - longitudeDiff
        if w <= -180 {
            w += longitudeDiff * 2
            
        }
        var e = coordinate.longitude + longitudeDiff
        if e > 180 {
            e -= longitudeDiff
        }
        requestOasisApi(n, west: w, south: s, east: e)
    }

    
    func requestOasisApi(north: Double, west: Double, south: Double, east: Double) {
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
                    print("cafeCount:\(cafes.count)")
                    if cafes.count == 0 {
                        NSNotificationCenter.defaultCenter().postNotificationName("didFailedFetchCafeResourcesMap", object:self, userInfo:["distance":self.distance.rawValue])
                        return
                    }
                    
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
