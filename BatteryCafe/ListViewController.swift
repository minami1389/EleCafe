//
//  ListViewController.swift
//  BatteryCafe
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit
import CoreLocation

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchOriginY: NSLayoutConstraint!
    
    var didSelectIndex = 0
    
    var cafeResources = [CafeData]()
    
    let categories = ["fastfood","cafe","restaurant","netcafe","lounge","convenience","workingspace","others"]
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "connectNetwork", name: ReachabilityNotificationName.Connect.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "disConnectNetwork", name: ReachabilityNotificationName.DisConnect.rawValue, object: nil)
        cafeResources = ModelLocator.sharedInstance.getCafe().getResources()
        
        //progress
        progressView.transform = CGAffineTransformMakeScale(1.0, 2.0)
        setupProgressNotification()
    }

    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFetchCafeResources", name: "didFetchCafeResourcesMap", object: nil)
        setupSettingNotification()
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didFetchCafeResourcesList", object: nil)
    }


//Network
    func conectNetwork() {
        
    }
    
    func disConnectNetwork() {
        let alert = UIAlertController(title: "エラー", message: "ネットワークに繋がっていません。接続を確かめて再度お試しください。", preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(alertAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    
    func didFetchCafeResources() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.cafeResources = ModelLocator.sharedInstance.getCafe().getResources()
            self.tableView.reloadData()
            self.finishProgress()
        }
    }

    @IBAction func didPushedChangeMap(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cafeResources.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cafe = cafeResources[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomCell") as! CustomTableViewCell
        cell.shopName.text = cafe.name
        cell.address.text = cafe.address
        cell.wifiInfo.text = cafe.wireless
        cell.icon.image = UIImage(named: "list-\(categories[indexPath.row]).png")
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        didSelectIndex = indexPath.row
        self.performSegueWithIdentifier("listToDetail", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailVC = segue.destinationViewController as? DetailViewController {
            detailVC.index = didSelectIndex
        }
    }
    
//NavigationBar
    @IBAction func didPushedSearchButton(sender: AnyObject) {
        switchSearchBar()
    }
  
    @IBAction func didPushedSettingButton(sender: AnyObject) {
        let settingVC = self.storyboard?.instantiateViewControllerWithIdentifier("SettingVC") as! SettingViewController
        settingVC.modalPresentationStyle = .OverCurrentContext
        self.presentViewController(settingVC, animated: true, completion: nil)
    }
    
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
                ModelLocator.sharedInstance.getCafe().fetchCafes(coordinate, dis:Distance.Narrow)
            }
        })
    }

//Setting
    func setupSettingNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didChangeSetting", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didChangeSetting", name: "didChangeSetting", object: nil)
    }
    
    func didChangeSetting() {
        cafeResources = ModelLocator.sharedInstance.getCafe().getResources()
        tableView.reloadData()
    }
    
//Progress
    func setupProgressNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didStartProgress", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didWriteProgress", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didStartProgress", name: "didStartProgress", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didWriteProgress:", name: "didWriteProgress", object: nil)
    }
    
    func didStartProgress() {
        progressView.hidden = false
    }
    
    func didWriteProgress(notification: NSNotification?) {
        let beforeProgress = progressView.progress
        progressView.setProgress(beforeProgress+0.3, animated: true)
    }
    
    func finishProgress() {
        progressView.setProgress(1.0, animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.8 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.progressView.hidden = true
            self.progressView.progress = 0.0
        }
    }

}
