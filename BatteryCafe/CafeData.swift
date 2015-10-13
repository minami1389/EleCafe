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
   
    init(cafe: NSDictionary) {
        super.init()
        self.setModel(cafe)
    }
   
    func setModel(cafe: NSDictionary) {
        let latitude: AnyObject! = cafe["latitude"]
        let longitude: AnyObject! = cafe["longitude"]
        let name: AnyObject! = cafe["title"]
        let address: AnyObject! = cafe["address"]
        self.latitude = latitude.doubleValue
        self.longitude = longitude.doubleValue
        self.name = name.description
        self.address = address.description
    }
   
   
}
