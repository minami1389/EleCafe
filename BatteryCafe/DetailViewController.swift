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
    
    var otherLabel:UILabel!
    
    let marginLR:CGFloat = 18
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewWebsiteButton.layer.shadowColor = UIColor(red: 206/255, green: 206/255, blue: 206/255, alpha: 1.0).CGColor
        viewWebsiteButton.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        viewWebsiteButton.layer.shadowOpacity = 1.0
        
        prepareView()
    }
    
    func prepareView() {
        let cafes = ModelLocator.sharedInstance.getCafe().getResources()
        let cafe = cafes[index]
        shopNameLabel.text = cafe.name
        shopAddressLabel.text = cafe.address
        shopWifiLabel.text = cafe.wireless
        
        prepareOtherView(cafe)
    }
    
    func prepareOtherView(cafe: CafeData) {
        if cafe.other == "" { return } //①
    
        let jiDoc = Ji(htmlString: cafe.other)
        let dlNodes = jiDoc?.xPath("//body/dl")
        prepareMiddleView(dlNodes)
    }
    
    func prepareMiddleView(dlNodes:[JiNode]?) {
        if dlNodes == nil { return }
        var originY:CGFloat = 0
        for dlNode in dlNodes! {
            let dtNodes = dlNode.childrenWithName("dt")
            let ddNodes = dlNode.childrenWithName("dd")
            if dtNodes.count != ddNodes.count { break }
            for var i = 0; i < ddNodes.count; i++ {
                let dlNodeView = DlNodeView(dlNode:dlNode, index:i, width:self.view.frame.size
                    .width - marginLR * 2)
                dlNodeView.frame.origin.y = originY
                originY += dlNodeView.frame.size.height
                middleView.addSubview(dlNodeView)
            }
        }
        middleViewHeight.constant = originY
    }
    
    
    

    

    @IBAction func didPushedSettingButton(sender: AnyObject) {
    }
    @IBAction func didPushedVisitWebsiteButton(sender: AnyObject) {
    }
    
}
