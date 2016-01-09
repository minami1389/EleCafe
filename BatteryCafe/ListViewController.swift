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
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "connectNetwork", name: ReachabilityNotificationName.Connect.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "disConnectNetwork", name: ReachabilityNotificationName.DisConnect.rawValue, object: nil)
        cafeResources = ModelLocator.sharedInstance.getCafe().getResources()
        
        //progress
        progressView.transform = CGAffineTransformMakeScale(1.0, 3.0)
    }

    override func viewDidAppear(animated: Bool) {
        setupFetchCafeNotification()
        setupProgressNotification()
        setupSettingNotification()
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

    @IBAction func didPushedChangeMap(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let adCount = cafeResources.count/6
        return cafeResources.count + adCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row % 6 == 5 {
            let cell = tableView.dequeueReusableCellWithIdentifier("BannerCell") as! BannerTableViewCell
            cell.bannerView.rootViewController = self
            return cell
        } else {
            let index = indexPath.row - indexPath.row/6
            let cafe = cafeResources[index]
            let cell = tableView.dequeueReusableCellWithIdentifier("CustomCell") as! CustomTableViewCell
            cell.shopName.text = cafe.name
            cell.address.text = cafe.address
    
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = 10
            paragraphStyle.maximumLineHeight = 10
            let attributedText = NSMutableAttributedString(string: cafe.wireless)
            attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
            cell.wifiInfo.attributedText = attributedText
        
            let cafeData = ModelLocator.sharedInstance.getCafe()
            var imageName = ""
            if cafe.cafeCategory >= 0 {
                imageName = "list-cafe_\(cafeData.cafeCategories[cafe.cafeCategory]).png"
            } else {
                imageName = "list-\(cafeData.categories[cafe.category]).png"
            }
            cell.icon.image = UIImage(named: imageName)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row % 6 != 5 {
            didSelectIndex = indexPath.row - indexPath.row/6
            self.performSegueWithIdentifier("listToDetail", sender: nil)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row % 6 == 5 {
            return 64
        } else {
            return 98
        }
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
                ModelLocator.sharedInstance.getCafe().fetchCafes(coordinate, dis:Distance.Default)
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
    
//FetchCafe
    func setupFetchCafeNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didFetchCafeResources", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didFailedFetchCafeResources", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFetchCafeResources", name: "didFetchCafeResources", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFailedFetchCafeResources", name: "didFailedFetchCafeResources", object: nil)
    }
    
    func didFetchCafeResources() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.cafeResources = ModelLocator.sharedInstance.getCafe().getResources()
            self.tableView.reloadData()
            self.finishProgress()
        }
    }
    
    func didFailedFetchCafeResources() {
    
    }

}
