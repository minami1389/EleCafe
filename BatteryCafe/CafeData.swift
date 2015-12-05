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
    var name = ""
    var address = ""
    var wireless = ""
    var category = []
    var other = ""
   
    init(cafe: NSDictionary) {
        super.init()
        self.setModel(cafe)
    }
   
    func setModel(cafe: NSDictionary) {
        let latitude: AnyObject! = cafe["latitude"]
        let longitude: AnyObject! = cafe["longitude"]
        let name: AnyObject! = cafe["title"]
        let address: AnyObject! = cafe["address"]
        let wireless: AnyObject! = cafe["wireless"]
        let category: AnyObject! = cafe["category"]
        let other: AnyObject! = cafe["other"]
        
        self.latitude = latitude.doubleValue
        self.longitude = longitude.doubleValue
        self.name = name.description
        self.address = address.description
        self.wireless = wireless.description
        if let c = category as? NSArray { self.category = c }
        self.other = other.description
    }
    
    func isEqualCafeData(data: CafeData) -> Bool {
        if self.latitude != data.latitude || self.longitude != data.longitude {
            return false
        } else {
            return true
        }
    }
       
}
