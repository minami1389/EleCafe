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

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchOriginY: NSLayoutConstraint!
    @IBOutlet weak var progresView: UIProgressView!
    @IBOutlet weak var mapView: GMSMapView!
    
    private var nowCoordinate = CLLocationCoordinate2D()
    
    private let locationManager = CLLocationManager()
    
    private var didBeginChangeCameraPosition = false
    private var didEndChangeCameraPosition = false
    private var cameraMoveTimer: NSTimer!
    private var didLaunch = false
    
    private var progressTimer:NSTimer!
    
    private var tappedMarkerName = ""
    
    private let defaultZoom:Float = 14
    
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
        let alertAction = UIAlertAction(title: "OK", style: .Cancel) { (action) -> Void in
            ModelLocator.sharedInstance.getCafe().fetchCafes(self.mapView.camera.target, dis:Distance.Default)
            self.startProgress()
        }
        alert.addAction(alertAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
//MapView
    private func setupMapView() {
        mapView.myLocationEnabled = true
        mapView.delegate = self
    }
    
    private func createMarker() {
        mapView.clear()
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
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
                if cafe.entry_id == self.tappedMarkerName {
                    self.mapView.selectedMarker = aMarker
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
        if cameraMoveTimer != nil {
            cameraMoveTimer.invalidate()
        }
        cameraMoveTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "fetchCafe", userInfo: nil, repeats: false)
    }
    
    func fetchCafe() {
        if NetworkObserver.sharedInstance.connectable {
            ModelLocator.sharedInstance.getCafe().fetchCafes(mapView.camera.target, dis:Distance.Default)
            startProgress()
        }
    }
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!) {
        guard let index = marker.userData as? Int else { return }
        let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DetailVC") as! DetailViewController
        detailVC.index = index
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        guard let index = marker.userData as? Int else { return false }
        let cafes = ModelLocator.sharedInstance.getCafe().getResources()
        tappedMarkerName = cafes[index].entry_id
        print(cafes[index].entry_id)
        return false
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
    
    func startProgress() {
        let beforeProgress = progresView.progress
        progresView.setProgress(beforeProgress+0.2, animated: true)
        progresView.hidden = false
        progressTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "writeProgress", userInfo: nil, repeats: true)
    }
    
    func writeProgress() {
        let beforeProgress = progresView.progress
        progresView.setProgress(beforeProgress+0.2, animated: true)
    }
    
    func finishProgress() {
        progressTimer.invalidate()
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
        if !didLaunch {
            mapView.camera = GMSCameraPosition.cameraWithTarget(nowCoordinate, zoom: defaultZoom)
            didLaunch = true
        }
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
            showServerErrorAlert(failedType)
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
    
    func showServerErrorAlert(statusCode:Int) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let alertController = UIAlertController(title: "サーバーエラー", message: "エラーが発生しました(\(statusCode))", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
//IBAction
    @IBAction func didPushedCurrenLocationButton(sender: AnyObject) {
        mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget(nowCoordinate, zoom: 14))
    }
    
    @IBAction func didPushedChangeSceneButton(sender: AnyObject) {
        self.performSegueWithIdentifier("toListVC", sender: self)
    }
    
    @IBAction func didPushedSearchButton(sender: AnyObject) {
        switchSearchBar()
    }
    
    @IBAction func didPushedSettingButton(sender: AnyObject) {
        if let settingVC = self.storyboard?.instantiateViewControllerWithIdentifier("SettingVC") as? SettingViewController {
            settingVC.modalPresentationStyle = .OverCurrentContext
            self.presentViewController(settingVC, animated: false, completion: nil)
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
            disappearCoverView()
        } else {
            searchOriginY.constant = 0
            searchTextField.becomeFirstResponder()
            appearCoverView()
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func searchCafeFromAddress() {
        let address = searchTextField.text
        CLGeocoder().geocodeAddressString(address!, inRegion: nil, completionHandler: { (placemarks, error) in
            if error != nil {
                print("Search Error:\(error)")
            } else {
                let place = placemarks![0]
               self.mapView.animateToCameraPosition(GMSCameraPosition.cameraWithTarget((place.location?.coordinate)!, zoom: self.defaultZoom))
            }
        })
    }
    
    @IBAction func didTapCoverView(sender: AnyObject) {
        disappearCoverView()
        switchSearchBar()
    }
    
    func appearCoverView() {
        coverView.hidden = false
        coverView.alpha = 0
        UIView.animateWithDuration(0.5) { () -> Void in
            self.coverView.alpha = 0.3
        }
    }
    
    func disappearCoverView() {
        UIView.animateWithDuration(0.5) { () -> Void in
            self.coverView.alpha = 0.0
        }
        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "didDisappearCoverView", userInfo: nil, repeats: false)
    }
    
    func didDisappearCoverView() {
        coverView.hidden = true
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

