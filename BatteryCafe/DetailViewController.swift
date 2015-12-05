//
//  DetailViewController.swift
//  BatteryCafe
//
//  Created by Baba Minami on 12/5/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit
import GoogleMaps


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
    
    var otherLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustSize()
    }
    
    func prepareView() {
        let cafes = ModelLocator.sharedInstance.getCafe().getResources()
        let cafe = cafes[index]
        shopNameLabel.text = cafe.name
        shopAddressLabel.text = cafe.address
        shopWifiLabel.text = cafe.wireless
        print(cafe.other)
        
        otherLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 36, height: 0))
        otherLabel.text = cafe.other
        otherLabel.numberOfLines = 0
        otherLabel.sizeToFit()
        topView.addSubview(otherLabel)
        topViewHeight.constant = otherLabel.frame.size.height
    }
    
    func adjustSize() {
        
    }



    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didPushedCloseButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func didPushedSettingButton(sender: AnyObject) {
    }
    @IBAction func didPushedVisitWebsiteButton(sender: AnyObject) {
    }
    
}
