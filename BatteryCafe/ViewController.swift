//
//  ViewController.swift
//  BatteryCafe
//
//  Created by minami on 10/13/15.
//  Copyright (c) 2015 TeamDeNA. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    let defaultRadius = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //バッテリー残量
        UIDevice.currentDevice().batteryMonitoringEnabled = true
        let batteryLevel = UIDevice.currentDevice().batteryLevel
        println(batteryLevel)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "batteryLevelDidChange:", name: UIDeviceBatteryLevelDidChangeNotification, object: nil)
        
        //GoogleMap
        mapView.myLocationEnabled = true
        mapView.settings.myLocationButton = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 300
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            println("Location services not available.")
        }
    }

    func batteryLevelDidChange(notification: NSNotificationCenter?) {
        let batteryLevel = UIDevice.currentDevice().batteryLevel
        println(batteryLevel)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        let nowCoordinate = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
            mapView.camera = GMSCameraPosition.cameraWithLatitude(nowCoordinate.latitude, longitude: nowCoordinate.longitude, zoom: 14)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }


}

