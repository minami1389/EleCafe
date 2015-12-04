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
    
    var didBeginChangeCameraPosition = false
    var didEndChangeCameraPosition = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //GoogleMap
        mapView.myLocationEnabled = true
        mapView.delegate = self
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
 
//LocationManager
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
  
//FetchCafeResource
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
  
//MapView
    func createMarker() {
        let cafes = ModelLocator.sharedInstance.getCafe().getResources()
        for cafe in cafes {
            let aMarker = GMSMarker()
            aMarker.title = cafe.name
            aMarker.position = CLLocationCoordinate2DMake(cafe.latitude, cafe.longitude)
            aMarker.snippet = cafe.address
            aMarker.map = mapView
            aMarker.appearAnimation = kGMSMarkerAnimationPop
            //TODO:カテゴリ分け
            aMarker.icon = UIImage(named: "stabu.jpg")
        }
    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        if didBeginChangeCameraPosition == false {
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkChangeCameraPosition", userInfo: nil, repeats: true)
            didBeginChangeCameraPosition = true
        }
        didEndChangeCameraPosition = false
    }
    
    func checkChangeCameraPosition() {
        if didEndChangeCameraPosition == true {
            if mapView.camera.target.longitude != appDelegate.nowCoordinate.longitude {
                ModelLocator.sharedInstance.getCafe().fetchCafes(mapView.camera.target)
            }
        } else {
            didEndChangeCameraPosition = true
        }
    }
    

//Button
    @IBAction func didPushedCurrenLocationButton(sender: AnyObject) {
        let nowLatitude = appDelegate.nowCoordinate.latitude
        let nowLongitude = appDelegate.nowCoordinate.longitude
        mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(nowLatitude, longitude: nowLongitude, zoom: 14))
    }
    
    @IBAction func didPushedChangeSceneButton(sender: AnyObject) {
        self.performSegueWithIdentifier("toListVC", sender: self)
    }
}

