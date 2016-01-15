//
//  BannerTableViewCell.swift
//  BatteryCafe
//
//  Created by Baba Minami on 1/9/16.
//  Copyright © 2016 TeamDeNA. All rights reserved.
//

import UIKit
import GoogleMobileAds

class BannerTableViewCell: UITableViewCell {

    
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bannerView.adUnitID = "ca-app-pub-7126530595198037/2962185900"
        let request = GADRequest()
        request.testDevices = ["25132294957416eaac338326282cc655"]
        let userDefault = NSUserDefaults.standardUserDefaults()
        if let latitude = userDefault.objectForKey("nowCoordinateLatitude") as? CGFloat {
            if let longitude = userDefault.objectForKey("nowCoordinateLongitude") as? CGFloat {
                if let accuracy = userDefault.objectForKey("nowCoordinateAccuracy") as? CGFloat {
                    request.setLocationWithLatitude(latitude, longitude: longitude, accuracy: accuracy)
                }
            }
        }
        bannerView.loadRequest(request)
    
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
