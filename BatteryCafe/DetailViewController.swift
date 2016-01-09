//
//  DetailViewController.swift
//  BatteryCafe
//
//  Created by Baba Minami on 12/5/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit
import GoogleMaps
import Ji

class DetailViewController: UIViewController {
    
    var index = 0
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var shopAddressLabel: UILabel!
    @IBOutlet weak var shopWifiLabel: UILabel!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var middleViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewWebsiteButton: UIButton!
    
    let categories = ["fastfood","cafe","restaurant","netcafe","lounge","convenience","workingspace","others"]
    let cafeCategories = ["doutor","starbucks","tullys"]
    
    var otherLabel:UILabel!
    
    let LRMargin:CGFloat = 18
    let bottomMargin:CGFloat = 18
    
    var cafe:CafeData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cafes = ModelLocator.sharedInstance.getCafe().getResources()
        cafe = cafes[index]
        prepareTitleView(cafe)
        prepareOtherView(cafe)
        
        prepareViewWebsiteButton()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "connectNetwork", name: ReachabilityNotificationName.Connect.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "disConnectNetwork", name: ReachabilityNotificationName.DisConnect.rawValue, object: nil)
        
        mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(cafe.latitude, longitude: cafe.longitude, zoom: 12))
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(cafe.latitude, cafe.longitude)
        marker.map = mapView
    }
    
//banner
    
    
//Network
    func conectNetwork() {
        
    }
    
    func disConnectNetwork() {
        let alert = UIAlertController(title: "エラー", message: "ネットワークに繋がっていません。接続を確かめて再度お試しください。", preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(alertAction)
        presentViewController(alert, animated: true, completion: nil)
    }

    
//Prepare Other View
    func prepareOtherView(cafe: CafeData) {
        if cafe.other == "" { return }
        let jiDoc = Ji(htmlString: cafe.other)
        let dlNodes = jiDoc?.xPath("//body/dl")
        let brNodes = jiDoc!.xPath("//text()")
        if dlNodes?.count != 0 {
            prepareMiddleView(dlNodes)
        } else if brNodes?.count != 0 {
            prepareBottomView(brNodes)
        }
    }
    
    func prepareMiddleView(dlNodes:[JiNode]?) {
        var originY:CGFloat = 0
        for dlNode in dlNodes! {
            let dtNodes = dlNode.childrenWithName("dt")
            let ddNodes = dlNode.childrenWithName("dd")
            if dtNodes.count != ddNodes.count { break }
            for var i = 0; i < ddNodes.count; i++ {
                let dlNodeView = DlNodeView(dlNode:dlNode, index:i, width:self.view.frame.size
                    .width - LRMargin * 2)
                dlNodeView.frame.origin.y = originY
                originY += dlNodeView.frame.size.height
                middleView.addSubview(dlNodeView)
            }
        }
        middleViewHeight.constant = originY + bottomMargin
    }
        
    func prepareBottomView(brNodes:[JiNode]?) {
        let bottomViewLabel = UILabel(frame: CGRect(x: 0, y: -4, width: self.view.frame.size.width - LRMargin * 2, height: 0))
        bottomViewLabel.font = UIFont(name: "HiraKakuProN-W3", size: 13.0)
        bottomViewLabel.textColor = UIColor(red: 78/255, green: 75/255, blue: 73/255, alpha: 1.0)
        
        var brNodeText = ""
        for var i = 0; i < brNodes!.count; i++ {
            brNodeText += "\(brNodes![i].content!)"
            if i+1 != brNodes!.count {
                brNodeText += "\n"
            }
        }
      
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 17
        paragraphStyle.maximumLineHeight = 17
        let attributedText = NSMutableAttributedString(string: brNodeText)
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
        bottomViewLabel.attributedText = attributedText
        
        bottomViewLabel.numberOfLines = 0
        bottomViewLabel.sizeToFit()
        bottomView.addSubview(bottomViewLabel)
        bottomViewHeight.constant = bottomViewLabel.frame.size.height + bottomMargin
    }
 
//Prepare Etc View
    func prepareTitleView(cafe: CafeData) {
        var imageName = ""
        if cafe.cafeCategory >= 0 {
            imageName = "list-cafe_\(cafeCategories[cafe.cafeCategory]).png"
        } else {
            imageName = "list-\(categories[cafe.category]).png"
        }
        iconImageView.image = UIImage(named: imageName)
        shopNameLabel.text = cafe.name
        shopAddressLabel.text = cafe.address
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 10
        paragraphStyle.maximumLineHeight = 10
        let attributedText = NSMutableAttributedString(string: cafe.wireless)
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
        shopWifiLabel.attributedText = attributedText
    }
    
    func prepareViewWebsiteButton() {
        viewWebsiteButton.layer.shadowColor = UIColor(red: 206/255, green: 206/255, blue: 206/255, alpha: 1.0).CGColor
        viewWebsiteButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        viewWebsiteButton.layer.shadowOpacity = 1.0
    }
    
    @IBAction func didPushedSettingButton(sender: AnyObject) {
        let settingVC = self.storyboard?.instantiateViewControllerWithIdentifier("SettingVC") as! SettingViewController
        settingVC.modalPresentationStyle = .OverCurrentContext
        self.presentViewController(settingVC, animated: true, completion: nil)
    }
    @IBAction func didPushedVisitWebsiteButton(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: cafe.url_pc)!)
    }

}
