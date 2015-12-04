//
//  ViewController.swift
//  BatteryCafe
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTextFieldOriginY: NSLayoutConstraint!
    
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
//LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
 
        //prepareBatteryMonitoring()
    }
  
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didGetLocation", name: "didGetLocation", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didGetLocation", object: nil)
    }


//BatteryMonitoring
    /*func prepareBatteryMonitoring() {
        UIDevice.currentDevice().batteryMonitoringEnabled = true
        let batteryLevel = UIDevice.currentDevice().batteryLevel
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "batteryLevelDidChange:", name: UIDeviceBatteryLevelDidChangeNotification, object: nil)
    }
    func batteryLevelDidChange(notification: NSNotificationCenter?) {
        let batteryLevel = UIDevice.currentDevice().batteryLevel
    }*/
    
    
//FetchCafe
    func didGetLocation() {
        print("nnn")
        //ModelLocator.sharedInstance.getCafe().fetchCafes(appDelegate.nowCoordinate)
    }
    
//Search
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switchSearchBar()
        searchCafeFromAddress()
        searchTextField.text = ""
        return true
    }
    
    func switchSearchBar() {
        self.view.setNeedsUpdateConstraints()
        if searchTextFieldOriginY.constant == 0 {
            searchTextFieldOriginY.constant = -40
            searchTextField.resignFirstResponder()
        } else {
            searchTextFieldOriginY.constant = 0
            searchTextField.becomeFirstResponder()
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    func searchCafeFromAddress() {
        let address = searchTextField.text
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!, inRegion: nil, completionHandler: { (placemarks, error) in
            if error != nil {
                print("error:\(error)")
            } else {
                let place = placemarks![0]
                let latitude = place.location!.coordinate.latitude
                let longitude = place.location!.coordinate.longitude
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                ModelLocator.sharedInstance.getCafe().fetchCafes(coordinate)
            }
        })
    }

    @IBAction func didPushedSearchButton(sender: AnyObject) {
        switchSearchBar()
    }


//Setting
    @IBAction func didPushedSettingButton(sender: AnyObject) {
    }
  
}
