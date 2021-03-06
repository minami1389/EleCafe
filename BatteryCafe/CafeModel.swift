//
//  CafeModel.swift
//  BatteryCafe
//
//  Created by minami on 10/13/15.
//  Copyright (c) 2015 TeamDeNA. All rights reserved.
//

import UIKit
import CoreLocation
import Google

enum Distance: Double {
    case Narrow = 1.0
    case Default = 2.0
    case Wide = 5.0
}

enum FetchFailedType: Int {
    case MoreFoundNarrowDistance = 0
    case MoreFoundDefaultDistance = 1
    case NotFoundDefaultDistance = 2
    case NotFoundWideDistance = 3
    case ServerError = 4
    case FetchError = 5
}

class CafeModel: NSObject, NSURLSessionDelegate {
    
    let categories = ["fastfood","cafe","restaurant","netcafe","lounge","convenience","workingspace","others"]
    let cafeCategories = ["doutor","starbucks","tullys"]
    
    private var setting = [Bool]()
    private let earthRadius = 6378.137
    private var distance = Distance.Default
    private var lastFetchCoordinate = CLLocationCoordinate2DMake(0.0, 0.0)
    var lastFetchDistance = Distance.Default
    
    private var isFetching = false
    
    private var resourceStore = [[CafeData]](count: 4, repeatedValue: [CafeData]())
    
    private var resources = [CafeData]()
   
    func getResources() -> [CafeData] {
        resources.removeAll()
        for i in 0 ..< resourceStore.count {
            mergeResources(resourceStore[i])
        }
        return resources
    }
    
    func objectWithEntryId(entry_id: String) -> CafeData? {
        for cafe in resources {
            if cafe.entry_id == entry_id {
                return cafe
            }
        }
        return nil
    }
    
    private func mergeResources(cafes:[CafeData]) {
        for newData in cafes {
            if settingState()[newData.category] && checkWifiState(newData) {
                insertToResources(newData)
            }
        }
    }
    
    private func checkWifiState(data:CafeData) -> Bool {
        if settingState().last == false {
            return true
        } else {
            return data.isWifi
        }
    }
    
    private func insertToResources(newData:CafeData) {
        let disNewData = distanceWithCoordinate(newData.coordinate())
        for i in 0 ..< self.resources.count {
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
    
    func lastTimeLocation() -> CLLocation {
        return CLLocation(latitude: lastFetchCoordinate.latitude, longitude: lastFetchCoordinate.longitude)
    }
    
    func fetchCafes(coordinate: CLLocationCoordinate2D!, dis:Distance) {
        if !NetworkObserver.sharedInstance.connectable { return }
        if isFetching == true { return }
        isFetching = true
        
        let thisTimeLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let lastTimeLocation = CLLocation(latitude: lastFetchCoordinate.latitude, longitude: lastFetchCoordinate.longitude)
        let diff = thisTimeLocation.distanceFromLocation(lastTimeLocation)
        if diff < 1000 && lastFetchDistance == dis {
            isFetching = false
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
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("Location", action: "LatLng", label: String(coordinate.longitude)+","+String(coordinate.latitude), value: nil).build() as [NSObject : AnyObject])
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
        
        let task = session.downloadTaskWithRequest(request) { (url, res, err) -> Void in
            self.isFetching = false
            let statusCode = (res as! NSHTTPURLResponse).statusCode
            if statusCode != 200 {
                NSNotificationCenter.defaultCenter().postNotificationName("didFailedFetchCafeResources", object:self, userInfo:["failedType":statusCode])
                return
            }
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(NSData(contentsOfURL: url!)!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                if let status = json["status"] as? String {
                    if status == "OK" {
                        self.didFetchCafeResources(json)
                    }
                } else if let status = json["status"] as? Int {
                    if status == 400 {
                        if let message = json["message"] as? String where message == "too much spots found. narrow the search range. " {
                            NSNotificationCenter.defaultCenter().postNotificationName("didFailedFetchCafeResources", object:self, userInfo:["failedType":FetchFailedType.MoreFoundDefaultDistance.rawValue])
                            return
                        }
                        self.didMoreFoundCafeResources()
                    } else {
                        NSNotificationCenter.defaultCenter().postNotificationName("didFailedFetchCafeResources", object:self, userInfo:["failedType":status])
                    }
                }
            } catch {}
        }
        task.resume()
    }
    
    func didFetchCafeResources(json: NSDictionary) {
        if let cafes = json["results"] as? NSArray {
            if cafes.count != 0 {
                self.storeResourcesWithCafes(cafes)
                NSNotificationCenter.defaultCenter().postNotificationName("didFetchCafeResources", object:nil, userInfo:nil)
            } else {
                switch self.distance {
                case Distance.Default:
                    NSNotificationCenter.defaultCenter().postNotificationName("didFailedFetchCafeResources", object:self, userInfo:["failedType":FetchFailedType.NotFoundDefaultDistance.rawValue])
                case Distance.Wide:
                    NSNotificationCenter.defaultCenter().postNotificationName("didFailedFetchCafeResources", object:self, userInfo:["failedType":FetchFailedType.NotFoundWideDistance.rawValue])
                default:
                    break
                }
            }
        }
    }
    
    func didMoreFoundCafeResources() {
        switch self.distance {
        case Distance.Narrow:
            NSNotificationCenter.defaultCenter().postNotificationName("didFailedFetchCafeResources", object:self, userInfo:["failedType":FetchFailedType.MoreFoundNarrowDistance.rawValue])
        case Distance.Default:
            NSNotificationCenter.defaultCenter().postNotificationName("didFailedFetchCafeResources", object:self, userInfo:["failedType":FetchFailedType.MoreFoundDefaultDistance.rawValue])
        default:
            break
        }
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
       NSNotificationCenter.defaultCenter().postNotificationName("didWriteProgress", object: self, userInfo: ["now":Int(totalBytesWritten/100), "total":Int(totalBytesExpectedToWrite/100)])
    }
    
    private func storeResourcesWithCafes(cafes:NSArray) {
        var fetchedCafes = [CafeData]()
        for cafe in cafes {
            let cafeData = CafeData(cafe: cafe as! NSDictionary)
            fetchedCafes.append(cafeData)
        }
        
        var didStore = false
        for i in 0 ..< resourceStore.count {
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
        let userDefault = NSUserDefaults.standardUserDefaults()
        userDefault.setObject(setting, forKey: "setting")
        NSNotificationCenter.defaultCenter().postNotificationName("didChangeSetting", object:self)
    }
    
    func settingState() -> [Bool] {
        let userDefault = NSUserDefaults.standardUserDefaults()
        if let obj = userDefault.objectForKey("setting") as? [Bool] {
            setting = obj
        }
        return setting
    }
}
