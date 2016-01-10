//
//  MapViewController.swift
//  BatteryCafe
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit
import GoogleMaps
import Reachability
import Google
class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    var didSelectIndex = 0
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchOriginY: NSLayoutConstraint!
    @IBOutlet weak var progresView: UIProgressView!
    @IBOutlet weak var mapView: GMSMapView!
    
    private var nowCoordinate = CLLocationCoordinate2D()
    
    private let locationManager = CLLocationManager()
    
    private var didBeginChangeCameraPosition = false
    private var didEndChangeCameraPosition = false
    private var cameraMoveTimer: NSTimer!
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "MapViewController")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNetworkObserver()
        setupMapView()
        setupProgresView()
        setupLocationManager()
    }
    
    override func viewDidAppear(animated: Bool) {
        setupFetchCafeNotification()
        setupProgressNotification()
        setupSettingNotification()
    }
    
//Network
    private func setupNetworkObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "connectNetwork", name: ReachabilityNotificationName.Connect.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "disConnectNetwork", name: ReachabilityNotificationName.DisConnect.rawValue, object: nil)
        let connectable = NetworkObserver.sharedInstance.startCheckReachability()
        if !connectable {
            disConnectNetwork()
        }
    }
    
    func connectNetwork() {
        
    }
    
    func disConnectNetwork() {
        let alert = UIAlertController(title: "エラー", message: "ネットワークに繋がっていません。接続を確かめて再度お試しください。", preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(alertAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
//MapView
    private func setupMapView() {
        mapView.myLocationEnabled = true
        mapView.delegate = self
    }
    
    private func createMarker() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.mapView.clear()
            let cafes = ModelLocator.sharedInstance.getCafe().getResources()
            for var i = 0; i < cafes.count; i++ {
                let cafe = cafes[i]
                let aMarker = GMSMarker()
                aMarker.position = CLLocationCoordinate2DMake(cafe.latitude, cafe.longitude)
                aMarker.map = self.mapView
                aMarker.appearAnimation = kGMSMarkerAnimationPop
                aMarker.userData = i
                let cafeData = ModelLocator.sharedInstance.getCafe()
                if cafe.cafeCategory >= 0 {
                    aMarker.icon = UIImage(named: "pin-cafe_\(cafeData.cafeCategories[cafe.cafeCategory]).png")
                } else {
                    aMarker.icon = UIImage(named: "pin-\(cafeData.categories[cafe.category]).png")
                }
            }
        }
    }
    
    func mapView(mapView: GMSMapView!, markerInfoWindow marker: GMSMarker!) -> UIView! {
        guard let index = marker.userData as? Int else { return  nil }
        let markerView = CustomMarkerView.instance()
        let cafe = ModelLocator.sharedInstance.getCafe().getResources()[index]
        markerView.shopNameLabel.text = cafe.name
        markerView.wifiLabel.text = cafe.wireless
        markerView.layoutIfNeeded()
        return markerView
    }
    
    func mapView(mapView: GMSMapView!, didChangeCameraPosition position: GMSCameraPosition!) {
        if !didBeginChangeCameraPosition {
            cameraMoveTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "checkChangeCameraPosition", userInfo: nil, repeats: true)
            didBeginChangeCameraPosition = true
        }
        didEndChangeCameraPosition = false
    }
    
    func checkChangeCameraPosition() {
        if didEndChangeCameraPosition {
            ModelLocator.sharedInstance.getCafe().fetchCafes(mapView.camera.target, dis:Distance.Default)
            cameraMoveTimer.invalidate()
            didBeginChangeCameraPosition = false
            didEndChangeCameraPosition = false
        } else {
            didEndChangeCameraPosition = true
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        guard let index = marker.userData as? Int else { return }
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DetailVC") as! DetailViewController
        detailVC.index = index
        self.navigationController?.presentViewController(detailVC, animated: true, completion: nil)
    }

//Progress
    func setupProgresView() {
        progresView.transform = CGAffineTransformMakeScale(1.0, 3.0)
    }
    
    func setupProgressNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didStartProgress", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didWriteProgress", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didStartProgress:", name: "didStartProgress", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didWriteProgress:", name: "didWriteProgress", object: nil)
    }
    
    func didStartProgress(notification: NSNotification?) {
        progresView.hidden = false
    }
    
    func didWriteProgress(notification: NSNotification?) {
        let beforeProgress = progresView.progress
        progresView.setProgress(beforeProgress+0.3, animated: true)
    }
    
    func finishProgress() {
        progresView.setProgress(1.0, animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.8 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.progresView.hidden = true
            self.progresView.progress = 0.0
        }
    }
    
//LocationManager
    func setupLocationManager() {
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
        nowCoordinate = CLLocationCoordinate2D(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
        mapView.camera = GMSCameraPosition.cameraWithTarget(nowCoordinate, zoom: 12)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:\(error)")
    }
  
//FetchCafeResource
    func setupFetchCafeNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didFetchCafeResources", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didFailedFetchCafeResources", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFetchCafeResources:", name: "didFetchCafeResources", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFailedFetchCafeResources:", name: "didFailedFetchCafeResources", object: nil)
    }
    
    func didFetchCafeResources(notification: NSNotification?) {
        optimizationCameraZoom()
        createMarker()
        finishProgress()
    }
    
    func didFailedFetchCafeResources(notification: NSNotification?) {
        guard let failedType = notification?.userInfo!["failedType"] as? Int else { return }
        print("failedType:\(failedType)")
        switch failedType {
        case FetchFailedType.MoreFoundNarrowDistance.rawValue:
            finishProgress()
            break
        case FetchFailedType.MoreFoundDefaultDistance.rawValue:
            ModelLocator.sharedInstance.getCafe().fetchCafes(mapView.camera.target, dis:Distance.Narrow)
        case FetchFailedType.NotFoundDefaultDistance.rawValue:
            ModelLocator.sharedInstance.getCafe().fetchCafes(mapView.camera.target, dis:Distance.Wide)
        case FetchFailedType.NotFoundWideDistance.rawValue:
            showNotFoundInWideAlert()
            finishProgress()
        default:
            break
        }
    }
    
    func optimizationCameraZoom() {
        let mostCloseCafe = ModelLocator.sharedInstance.getCafe().getResources()[0]
        let locA = CLLocation(latitude: mostCloseCafe.latitude, longitude: mostCloseCafe.longitude)
        let locB = CLLocation(latitude: mapView.camera.target.latitude, longitude: mapView.camera.target.longitude)
        let distance = locA.distanceFromLocation(locB) + 2000
        let zoom = GMSCameraPosition.zoomAtCoordinate(mapView.camera.target, forMeters: distance, perPoints: 320)
        if zoom < mapView.camera.zoom {
            mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(mapView.camera.target.latitude, longitude: mapView.camera.target.longitude, zoom: zoom))
        }
    }
    
    func showNotFoundInWideAlert() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let alertController = UIAlertController(title: "エラー", message: "\(Int(Distance.Wide.rawValue))km以内に電源が\nありませんでした。", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
//IBAction
    @IBAction func didPushedCurrenLocationButton(sender: AnyObject) {
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("Button", action: "CurrentLocationButton", label: "Map", value: nil).build() as [NSObject : AnyObject])
        mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(nowCoordinate, zoom: 12))
    }
    
    @IBAction func didPushedChangeSceneButton(sender: AnyObject) {
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("Button", action: "MaptoListButton", label: "Map", value: nil).build() as [NSObject : AnyObject])
        self.performSegueWithIdentifier("toListVC", sender: self)
        
    }
    
    @IBAction func didPushedSearchButton(sender: AnyObject) {
        switchSearchBar()
    }
    
    @IBAction func didPushedSettingButton(sender: AnyObject) {
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("Button", action: "SettingButton", label: "Map", value: nil).build() as [NSObject : AnyObject])
        if let settingVC = self.storyboard?.instantiateViewControllerWithIdentifier("SettingVC") as? SettingViewController {
            settingVC.modalPresentationStyle = .OverCurrentContext
            self.presentViewController(settingVC, animated: true, completion: nil)
        }
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
            GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("Button", action: "SearchButton", label: "Map", value: nil).build() as [NSObject : AnyObject])
            searchOriginY.constant = 0
            searchTextField.becomeFirstResponder()
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func searchCafeFromAddress() {
        let address = searchTextField.text
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("Search", action: address, label: "Map", value: nil).build() as [NSObject : AnyObject])
        CLGeocoder().geocodeAddressString(address!, inRegion: nil, completionHandler: { (placemarks, error) in
            if error != nil {
                print("Search Error:\(error)")
            } else {
                let place = placemarks![0]
               self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget((place.location?.coordinate)!, zoom: 12))
            }
        })
    }
    
//Setting
    func setupSettingNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didChangeSetting", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didChangeSetting", name: "didChangeSetting", object: nil)
    }
    
    func didChangeSetting() {
        createMarker()
    }

}

