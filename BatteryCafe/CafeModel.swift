//
//  CafeModel.swift
//  BatteryCafe
//
//  Created by minami on 10/13/15.
//  Copyright (c) 2015 TeamDeNA. All rights reserved.
//

import UIKit

class CafeModel: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
   
    var resources = [CafeData]()
   
    func getResources() -> [CafeData] {
        return resources
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

                guard let status = json["status"] as? String else { return }
                if let cafes = json["results"] as? NSArray {
                    var tmpObjects = [CafeData]()
                    for cafe in cafes {
                        tmpObjects.append(CafeData(cafe: cafe as! NSDictionary))
                    }
                    self.resources = tmpObjects
                    NSNotificationCenter.defaultCenter().postNotificationName("didFetchCafeResourcesMap", object: nil)
                    NSNotificationCenter.defaultCenter().postNotificationName("didFetchCafeResourcesList", object: nil)
                }
                } catch {}
        })
        task.resume()
    }
}
