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
    private var lastFetchCoordinate = CLLocationCoordinate2DMake(0.0, 0.0)
    private var lastFetchDistance = Distance.Narrow
    
    private var isFetching = false
    
    private var resourceStore = [[CafeData]](count: 4, repeatedValue: [CafeData]())
    
    var resources = [CafeData]()
   
    func getResources() -> [CafeData] {
        resources.removeAll()
        for var i = 0; i < resourceStore.count; i++ {
            mergeResources(resourceStore[i])
        }
        return resources
    }
    
    func mergeResources(cafes:[CafeData]) {
        for cafe in cafes {
            if self.isNewCafeData(cafe) {
                resources.append(cafe)
            }
        }
    }
    
    func fetchCafes(coordinate: CLLocationCoordinate2D!, dis:Distance) {
        if isFetching == true { return }
        isFetching = true
        
        let thisTimeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let lastTimeLocation = CLLocation(latitude: lastFetchCoordinate.latitude, longitude: lastFetchCoordinate.longitude)
        let diff = thisTimeLocation.distanceFromLocation(lastTimeLocation)
        print(diff)
        print(lastFetchDistance)
        print(dis)
        if diff < 1000 && lastFetchDistance == dis {
            return
        }
        
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
        lastFetchCoordinate = coordinate
        lastFetchDistance = dis
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
                print("error:\(error)")
                return
            }
        
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary

                guard let _ = json["status"] as? String else { return }
                if let cafes = json["results"] as? NSArray {
                    self.isFetching = false
                    if cafes.count == 0 {
                        NSNotificationCenter.defaultCenter().postNotificationName("didFailedFetchCafeResourcesMap", object:self, userInfo:["distance":self.distance.rawValue])
                        return
                    }
                    self.storeResourcesWithCafes(cafes)
                    NSNotificationCenter.defaultCenter().postNotificationName("didFetchCafeResourcesMap", object: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("didFetchCafeResourcesList", object: nil)
                }
                } catch {}
        })
        task.resume()
    }
    
    func storeResourcesWithCafes(cafes:NSArray) {
        var fetchedCafes = [CafeData]()
        for cafe in cafes {
            let cafeData = CafeData(cafe: cafe as! NSDictionary)
            fetchedCafes.append(cafeData)
        }
        
        var didStore = false
        for var i = 0; i < resourceStore.count; i++ {
            if resourceStore[i].count == 0 {
                resourceStore[i] = fetchedCafes
                didStore = true
                return
            }
        }
        if didStore == false {
            resourceStore.removeFirst()
            resourceStore.append(fetchedCafes)
        }
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
