//
//  ViewController.swift
//  BatteryCafe
//
//  Created by minami on 10/13/15.
//  Copyright (c) 2015 TeamDeNA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var batteryLevelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        UIDevice.currentDevice().batteryMonitoringEnabled = true
        let batteryLevel = UIDevice.currentDevice().batteryLevel
        batteryLevelLabel.text = String("\(batteryLevel)")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "batteryLevelDidChange:", name: UIDeviceBatteryLevelDidChangeNotification, object: nil)
    }

    func batteryLevelDidChange(notification: NSNotificationCenter?) {
        let batteryLevel = UIDevice.currentDevice().batteryLevel
        batteryLevelLabel.text = String("\(batteryLevel)")
    }


}

