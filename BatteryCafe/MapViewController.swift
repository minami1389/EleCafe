//
//  MapViewController.swift
//  BatteryCafe
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    let defaultRadius = 300
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //バッテリー残量
        UIDevice.currentDevice().batteryMonitoringEnabled = true
        let batteryLevel = UIDevice.currentDevice().batteryLevel
        print(batteryLevel)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "batteryLevelDidChange:", name: UIDeviceBatteryLevelDidChangeNotification, object: nil)
        
        //GoogleMap
        mapView.myLocationEnabled = true
        //mapView.settings.myLocationButton = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 300
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            print("Location services not available.")
        }
        
    }
    
    func batteryLevelDidChange(notification: NSNotificationCenter?) {
        let batteryLevel = UIDevice.currentDevice().batteryLevel
        print(batteryLevel)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let nowCoordinate = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
        mapView.camera = GMSCameraPosition.cameraWithLatitude(nowCoordinate.latitude, longitude: nowCoordinate.longitude, zoom: 14)
        fetchCafes(nowCoordinate)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func fetchCafes(nowCoordinate: CLLocationCoordinate2D) {
        var n = Float(nowCoordinate.latitude + 0.1)
        if n > 90 {
            n -= 0.02
        }
        var s = Float(nowCoordinate.latitude - 0.1)
        if s < -90 {
            s += 0.02
        }
        var w = Float(nowCoordinate.longitude - 0.1)
        if w <= -180 {
            w += 0.02
            
        }
        var e = Float(nowCoordinate.longitude + 0.1)
        if e > 180 {
            e -= 0.02
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFetchCafeResources", name: "didFetchCafeResources", object: nil)
        ModelLocator.sharedInstance.getCafe().requestOasisApi(n, west: w, south: s, east: e)
    }
    
    func didFetchCafeResources() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didFetchCafeResources", object: nil)
        createMarker()
    }
    
    func createMarker() {
        let cafes = ModelLocator.sharedInstance.getCafe().getResources()
        for cafe in cafes {
            let aMarker = GMSMarker()
            aMarker.title = cafe.name
            aMarker.position = CLLocationCoordinate2DMake(cafe.latitude, cafe.longitude)
            aMarker.snippet = cafe.address
            aMarker.map = mapView
        }
    }
    
    @IBAction func didPushedCurrenLocationButton(sender: AnyObject) {
    }
    
    @IBAction func didPushedChangeSceneButton(sender: AnyObject) {
        self.performSegueWithIdentifier("toListVC", sender: self)
    }

}

