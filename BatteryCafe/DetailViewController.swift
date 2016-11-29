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
import Google
import SVProgressHUD

class DetailViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var shopAddressLabel: UILabel!
    @IBOutlet weak var shopWifiLabel: UILabel!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var naviconView: UIView!
    
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var middleViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewWebsiteButton: UIButton!
    
    
    
    private let defaultZoom:Float = 15
    
    let categories = ["fastfood","cafe","restaurant","netcafe","lounge","convenience","workingspace","others"]
    let cafeCategories = ["doutor","starbucks","tullys"]
    
    var otherLabel:UILabel!
    
    let LRMargin:CGFloat = 18
    let bottomMargin:CGFloat = 18
    
    var cafe:CafeData!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "DetailViewController")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTitleView(cafe)
        prepareOtherView(cafe)
        
        prepareViewWebsiteButton()
        prepareNaviConView()
        
        mapView.animateToCameraPosition(GMSCameraPosition.cameraWithLatitude(cafe.latitude, longitude: cafe.longitude, zoom: defaultZoom))
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(cafe.latitude, cafe.longitude)
        marker.map = mapView
        
    }
    
//banner
    

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
            for i in 0 ..< ddNodes.count {
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
        for i in 0 ..< brNodes!.count {
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
            imageName = "list_cafe_\(cafeCategories[cafe.cafeCategory]).png"
        } else {
            imageName = "list_\(categories[cafe.category]).png"
        }
        iconImageView.image = UIImage(named: imageName)
        shopNameLabel.text = cafe.name
        shopNameLabel.adjustsFontSizeToFitWidth = true
        shopAddressLabel.text = cafe.address
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 10
        paragraphStyle.maximumLineHeight = 10
        let attributedText = NSMutableAttributedString(string: cafe.wireless)
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
        shopWifiLabel.attributedText = attributedText
    }
    
    func prepareViewWebsiteButton() {
        guard let url = NSURL(string: cafe.url_pc) else { return }
        if UIApplication.sharedApplication().canOpenURL(url) {
            viewWebsiteButton.hidden = false
            viewWebsiteButton.layer.shadowColor = UIColor(red: 206/255, green: 206/255, blue: 206/255, alpha: 1.0).CGColor
            viewWebsiteButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
            viewWebsiteButton.layer.shadowOpacity = 1.0
            viewWebsiteButton.layer.shadowRadius = 0
        }
    }
    
    func prepareNaviConView() {
        naviconView.layer.shadowColor = UIColor(red: 206/255, green: 206/255, blue: 206/255, alpha: 1.0).CGColor
        naviconView.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        naviconView.layer.shadowOpacity = 1.0
        naviconView.layer.shadowRadius = 0
    }
    
    @IBAction func didPushedVisitWebsiteButton(sender: AnyObject) {
        GAI.sharedInstance().defaultTracker.send(GAIDictionaryBuilder.createEventWithCategory("Button", action: "VisitWebsiteButton", label: "Detail", value: nil).build() as [NSObject : AnyObject])
        if let url = NSURL(string: cafe.url_pc) {
            UIApplication.sharedApplication().openURL(url)
        } else {
            print("open url error:\(cafe.url_pc)")
        }
    }

    @IBAction func didPushedNaviConButton(sender: UIButton) {
        requestNaviConApi()
    }
    
}

extension DetailViewController: NSURLSessionDelegate {
    private func requestNaviConApi() {
        SVProgressHUD.showWithStatus("NaviConを起動中です")
        
        let urlString = "https://dev.navicon.com/webapi/cmd/navicon/createNaviConURL"
        let apikey = "ZNPpUk4QC4L992yt45LdwkF9nWIjrWVk9AYBM.X6xsXGdE0QHPTPLeaf0vLJdFE4AQr9YkIMMi85KqlG"
        guard let url = NSURL(string: urlString) else { return }
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        var bodyData = "apikey=\(apikey)"
        bodyData += "&regid=TqmT623X"
        bodyData += "&ver=2.0"
        bodyData += "&name1=\(cafe.name)"
        bodyData += "&coordinates1=\(cafe.latitude),\(cafe.longitude)"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data, res, err) in
            let statusCode = (res as! NSHTTPURLResponse).statusCode
            print("statud code : \(statusCode)")
            
            guard let data = data else {
                SVProgressHUD.dismiss()
                return
            }
            do {
                SVProgressHUD.dismiss()
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                dispatch_async(dispatch_get_main_queue(), {
                    guard let urlString = json["urlschema"] as? String else { return }
                    guard let url = NSURL(string:urlString) else { return }
                    UIApplication.sharedApplication().openURL(url)
                })
                
            } catch{
                SVProgressHUD.dismiss()
            }
        })
        task.resume()
        
        
    }
}
