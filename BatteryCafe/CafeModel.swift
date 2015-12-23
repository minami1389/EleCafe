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

class CafeModel: NSObject, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    private var setting = [Bool](count: 8, repeatedValue: true)
    
    private let earthRadius = 6378.137
    private var distance = Distance.Narrow
    private var lastFetchCoordinate = CLLocationCoordinate2DMake(0.0, 0.0)
    private var lastFetchDistance = Distance.Narrow
    
    private var isFetching = false
    
    private var resourceStore = [[CafeData]](count: 4, repeatedValue: [CafeData]())
    
    private var resources = [CafeData]()
   
    func getResources() -> [CafeData] {
        resources.removeAll()
        for var i = 0; i < resourceStore.count; i++ {
            mergeResources(resourceStore[i])
        }
        return resources
    }
    
    private func mergeResources(cafes:[CafeData]) {
        for newData in cafes {
            if setting[newData.category] {
                insertToResources(newData)
            }
        }
    }
    
    private func insertToResources(newData:CafeData) {
        let disNewData = distanceWithCoordinate(newData.coordinate())
        for var i = 0; i < self.resources.count; i++ {
            let compareData = resources[i]
            if newData.isEqualCafeData(compareData) { return }
            let disCompareData = distanceWithCoordinate(compareData.coordinate())
            if disNewData < disCompareData {
                resources.insert(newData, atIndex: i)
                return
            }
        }
        resources.append(newData)
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

    
    private func requestOasisApi(north: Double, west: Double, south: Double, east: Double) {
        var urlString = "http://oasis.mogya.com/api/v0/search?"
        urlString += "n=\(north)"
        urlString += "&w=\(west)"
        urlString += "&s=\(south)"
        urlString += "&e=\(east)"
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        let request = NSURLRequest(URL: NSURL(string: urlString)!)
        let task = session.downloadTaskWithRequest(request)
        task.resume()
        NSNotificationCenter.defaultCenter().postNotificationName("didStartProgress", object: nil)
    }
    
//Download Delegate
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let data = NSData(contentsOfURL: location)
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
                NSNotificationCenter.defaultCenter().postNotificationName("didFetchCafeResourcesMap", object: nil, userInfo:["distance":self.distance.rawValue])
                NSNotificationCenter.defaultCenter().postNotificationName("didFetchCafeResourcesList", object: nil)
            }
        } catch {}
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let now = totalBytesWritten
        let total = totalBytesExpectedToWrite
        print(now)
        print(total)
        NSNotificationCenter.defaultCenter().postNotificationName("didWriteProgress", object: self, userInfo: ["now":Int(totalBytesWritten/100), "total":Int(totalBytesExpectedToWrite/100)])
    }
    
    private func storeResourcesWithCafes(cafes:NSArray) {
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
    
    private func isNewCafeData(cafeData: CafeData) -> Bool {
        for cafe in self.resources {
            if cafeData.isEqualCafeData(cafe) {
                return false
            }
        }
        return true
    }
    
    private func distanceWithCoordinate(coordinateA:CLLocationCoordinate2D) -> CLLocationDistance {
        let locA = CLLocation(latitude: coordinateA.latitude, longitude: coordinateA.longitude)
        let locB = CLLocation(latitude: lastFetchCoordinate.latitude, longitude: lastFetchCoordinate.longitude)
        let distance = locA.distanceFromLocation(locB)
        return distance
    }
    
    func changeSettingState(index:Int) {
        setting[index] = !setting[index]
        NSNotificationCenter.defaultCenter().postNotificationName("didChangeSetting", object:self)
    }
    
    func settingState() -> [Bool] {
        return setting
    }
    
    
}
