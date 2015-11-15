//
//  ModelLocator.swift
//  BatteryCafe
//
//  Created by minami on 10/13/15.
//  Copyright (c) 2015 TeamDeNA. All rights reserved.
//

import UIKit

class ModelLocator: NSObject {
   
    class var sharedInstance: ModelLocator {
        struct Singleton {
            static var instance = ModelLocator()
        }
        return Singleton.instance
    }
    
    var cafes = CafeModel()
    
    override init() {
        print("ModelLocator init!")
    }
    
    func getCafe() -> CafeModel {
        return cafes
    }
    
    func setCafe(array:CafeModel) -> CafeModel {
        cafes = array
        return cafes
    }
   
}
