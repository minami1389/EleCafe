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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cafes = ModelLocator.sharedInstance.getCafe().getResources()
        for cafe in cafes {
            let name = cafe.name
            let address = cafe.address
            let wireless = cafe.wireless
            let other = cafe.other
            print(name)
            print(address)
            print(wireless)
            print(other)
            print("")
        }

        
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
