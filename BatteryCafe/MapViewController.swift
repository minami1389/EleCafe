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

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchOriginY: NSLayoutConstraint!
    
    var nowCoordinate = CLLocationCoordinate2D()
    
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    let defaultRadius = 300
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var didBeginChangeCameraPosition = false
    var didEndChangeCameraPosition = false
    var cameraMoveTimer: NSTimer!
    
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
        nowCoordinate = CLLocationCoordinate2D(latitude: nowLatitude, longitude: nowLongitude)
        mapView.camera = GMSCameraPosition.cameraWithLatitude(nowLatitude, longitude: nowLongitude, zoom: 14)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
  
//FetchCafeResource
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFetchCafeResources", name: "didFetchCafeResourcesMap", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFailedFetchCafeResources:", name: "didFailedFetchCafeResourcesMap", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didFetchCafeResourcesMap", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didFailedFetchCafeResourcesMap", object: nil)
     }

    func didFetchCafeResources() {
        createMarker()
    }
    
    func didFailedFetchCafeResources(notification: NSNotification?) {
        let distance = notification?.userInfo!["distance"] as! Double
        switch distance {
        case Distance.Narrow.rawValue:
            ModelLocator.sharedInstance.getCafe().fetchCafes(mapView.camera.target, dis:Distance.Wide)
        case Distance.Wide.rawValue:
            showNotFoundInWideAlert()
        default:
            break
        }
    }
    
    func showNotFoundInWideAlert() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let alertController = UIAlertController(title: nil, message: "\(Int(Distance.Wide.rawValue))km以内に電源が\nありませんでした。", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
  
//MapView
    func createMarker() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.mapView.clear()
            let cafes = ModelLocator.sharedInstance.getCafe().getResources()
            print("markerCount:\(cafes.count)")
            for cafe in cafes {
                let aMarker = GMSMarker()
                aMarker.title = cafe.name
                aMarker.position = CLLocationCoordinate2DMake(cafe.latitude, cafe.longitude)
                aMarker.snippet = cafe.address
                aMarker.map = self.mapView
                aMarker.appearAnimation = kGMSMarkerAnimationPop
                //TODO:カテゴリ分け
                aMarker.icon = UIImage(named: "cafe.png")
            }
        }
    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        if didBeginChangeCameraPosition == false {
            cameraMoveTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkChangeCameraPosition", userInfo: nil, repeats: true)
            didBeginChangeCameraPosition = true
        }
        didEndChangeCameraPosition = false
    }
    
    func checkChangeCameraPosition() {
        if didEndChangeCameraPosition == true {
            ModelLocator.sharedInstance.getCafe().fetchCafes(mapView.camera.target, dis:Distance.Narrow)
            cameraMoveTimer.invalidate()
            didBeginChangeCameraPosition = false
            didEndChangeCameraPosition = false
        } else {
            didEndChangeCameraPosition = true
        }
    }
    

//Button
    @IBAction func didPushedCurrenLocationButton(sender: AnyObject) {
        let nowLatitude = nowCoordinate.latitude
        let nowLongitude = nowCoordinate.longitude
        mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(nowLatitude, longitude: nowLongitude, zoom: 14))
    }
    
    @IBAction func didPushedChangeSceneButton(sender: AnyObject) {
        self.performSegueWithIdentifier("toListVC", sender: self)
    }
    
//NavigationBar
    @IBAction func didPushedSearchButton(sender: AnyObject) {
        switchSearchBar()
    }
    
    @IBAction func didPushedSettingButton(sender: AnyObject) {
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
        if searchOriginY.constant == 0 {
            searchOriginY.constant = -48
            searchTextField.resignFirstResponder()
        } else {
            searchOriginY.constant = 0
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
                self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(latitude, longitude: longitude, zoom: 14))
            }
        })
    }

}

