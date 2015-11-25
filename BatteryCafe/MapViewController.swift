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
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //GoogleMap
        mapView.myLocationEnabled = true
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
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let nowLatitude = newLocation.coordinate.latitude
        let nowLongitude = newLocation.coordinate.longitude
        appDelegate.nowCoordinate = CLLocationCoordinate2D(latitude: nowLatitude, longitude: nowLongitude)
        mapView.camera = GMSCameraPosition.cameraWithLatitude(nowLatitude, longitude: nowLongitude, zoom: 14)
        NSNotificationCenter.defaultCenter().postNotificationName("didGetLocation", object: nil)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFetchCafeResources", name: "didFetchCafeResourcesMap", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didFetchCafeResourcesMap", object: nil)
     }

    
    func didFetchCafeResources() {
        createMarker()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFetchCafeResources", name: "didFetchCafeResourcesMap", object: nil)
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
    
    func createTestMarker() {
        let aMarker = GMSMarker()
        aMarker.title = "テスト"
        aMarker.position = CLLocationCoordinate2DMake(appDelegate.nowCoordinate.latitude, appDelegate.nowCoordinate.longitude)
        aMarker.snippet = "test"
        aMarker.map = mapView
    }
    
    @IBAction func didPushedCurrenLocationButton(sender: AnyObject) {
        let nowLatitude = appDelegate.nowCoordinate.latitude
        let nowLongitude = appDelegate.nowCoordinate.longitude
        mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(nowLatitude, longitude: nowLongitude, zoom: 14))
    }
    
    @IBAction func didPushedChangeSceneButton(sender: AnyObject) {
        self.performSegueWithIdentifier("toListVC", sender: self)
    }

      
}

