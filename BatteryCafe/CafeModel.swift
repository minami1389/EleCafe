//
//  CafeModel.swift
//  BatteryCafe
//
//  Created by minami on 10/13/15.
//  Copyright (c) 2015 TeamDeNA. All rights reserved.
//

import UIKit

class CafeModel: NSObject, NSURLSessionDelegate, NSURLSessionDataDelegate {
   
    override init() {
        super.init()
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
        var urlString = "http://oasis.mogya.com/api/v0/search?"
        let n = 34.70849
        let w = 135.48775
        let s = 34.69727
        let e = 135.50951
        urlString += "n=\(n)"
        urlString += "&w=\(w)"
        urlString += "&s=\(s)"
        urlString += "&e=\(e)"
        let url = NSURL(string: urlString)!
        println(urlString)
        let task = session.dataTaskWithURL(url, completionHandler: {(data, response, err) -> Void in
            let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
            println("\(dataString)")
        })
        task.resume()
    }
    
    
}
