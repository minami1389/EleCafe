//
//  ListViewController.swift
//  BatteryCafe
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit
import CoreLocation
import Google
import SVProgressHUD

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var progressView: UIProgressView!
    
    var cafeResources = [CafeData]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "ListViewController")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        SVProgressHUD.show()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //progress
        progressView.transform = CGAffineTransformMakeScale(1.0, 3.0)
    }

    override func viewDidAppear(animated: Bool) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.cafeResources = ModelLocator.sharedInstance.getCafe().getResources()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                SVProgressHUD.dismiss()
                self.tableView.reloadData()
                self.tableView.alpha = 0
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.tableView.alpha = 1
                })
                self.setupFetchCafeNotification()
                self.setupProgressNotification()
                self.setupSettingNotification()
            })
        }
    }

    @IBAction func didPushedChangeMap(sender: AnyObject) {
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("Button", action: "ListtoMapButton", label: "List", value: nil).build() as [NSObject : AnyObject])
        self.dismissViewControllerAnimated(true, completion: nil)
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
            let distanceInKilometersString = NSString(format: "%.1lf", distanceFromHere(cafe) / 1000.0)
            cell.distanceLabel.text = "\(distanceInKilometersString)km"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.minimumLineHeight = 10
            paragraphStyle.maximumLineHeight = 10
            let attributedText = NSMutableAttributedString(string: cafe.wireless)
            attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
            cell.wifiInfo.attributedText = attributedText
        
            let cafeData = ModelLocator.sharedInstance.getCafe()
            var imageName = ""
            if cafe.cafeCategory >= 0 {
                imageName = "list_cafe_\(cafeData.cafeCategories[cafe.cafeCategory]).png"
            } else {
                imageName = "list_\(cafeData.categories[cafe.category]).png"
            }
            cell.icon.image = UIImage(named: imageName)
            return cell
        }
    }
    
    func distanceFromHere(cafe:CafeData) -> CLLocationDistance {
        let hereLat = NSUserDefaults.standardUserDefaults().objectForKey("nowCoordinateLatitude") as! Double
        let hereLng = NSUserDefaults.standardUserDefaults().objectForKey("nowCoordinateLongitude") as! Double
        let here = CLLocation(latitude: hereLat, longitude: hereLng)
        let cafe = CLLocation(latitude: cafe.latitude, longitude: cafe.longitude)
        return here.distanceFromLocation(cafe)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row % 6 != 5 {
            let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier("DetailVC") as! DetailViewController
            let index = indexPath.row - indexPath.row/6
            detailVC.cafe = ModelLocator.sharedInstance.getCafe().getResources()[index]
            GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("Button", action: "pin", label: "List", value: Int(detailVC.cafe.entry_id)).build() as [NSObject : AnyObject])
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row % 6 == 5 {
            return 64
        } else {
            return 98
        }
    }
    
//Setting
    @IBAction func didPushedSettingButton(sender: AnyObject) {
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("Button", action: "SettingButton", label: "List", value: nil).build() as [NSObject : AnyObject])
        let settingVC = self.storyboard?.instantiateViewControllerWithIdentifier("SettingVC") as! SettingViewController
        settingVC.modalPresentationStyle = .OverCurrentContext
        settingVC.modalTransitionStyle = .CrossDissolve
        self.presentViewController(settingVC, animated: false, completion: nil)
    }

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
