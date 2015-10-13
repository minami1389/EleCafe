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
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
        var urlString = "http://oasis.mogya.com/api/v0/search?"
        urlString += "n=\(north)"
        urlString += "&w=\(west)"
        urlString += "&s=\(south)"
        urlString += "&e=\(east)"
        println(urlString)
        let url = NSURL(string: urlString)!
        let task = session.dataTaskWithURL(url, completionHandler: {(data, response, err) -> Void in
            let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? NSDictionary {
                if let cafes = json["results"] as? NSArray {
                    var tmpObjects = [CafeData]()
                    for cafe in cafes {
                        tmpObjects.append(CafeData(cafe: cafe as! NSDictionary))
                    }
                    self.resources = tmpObjects
                    println(self.resources)
                }
            } else {
                println("Failed")
            }
        })
        task.resume()
    }
    
    
    
    
}
