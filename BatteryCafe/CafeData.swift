//
//  CafeData.swift
//  BatteryCafe
//
//  Created by minami on 10/13/15.
//  Copyright (c) 2015 TeamDeNA. All rights reserved.
//

import UIKit

class CafeData: NSObject {
    var latitude = 0.0
    var longitude = 0.0
    var cafeName = ""
   
    init(cafe: NSDictionary) {
        super.init()
        self.setModel(cafe)
    }
   
    func setModel(cafe: NSDictionary) {
        let latitude: AnyObject! = cafe["latitude"]
        let longitude: AnyObject! = cafe["longitude"]
        let cafeName: AnyObject! = cafe["title"]
        self.latitude = latitude.doubleValue
        self.longitude = longitude.doubleValue
        self.cafeName = cafeName.description
    }
   
   
}
