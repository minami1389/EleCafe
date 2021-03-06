//
//  CustomTableViewCell.swift
//  BatteryCafe
//
//  Created by minami on 11/14/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var containView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var wifiInfo: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containView.layer.borderColor = UIColor(red: 237, green: 237, blue: 237, alpha: 1.0).CGColor
        shopName.font = UIFont(name: "HiraKakuProN-W6", size: 11)
        shopName.adjustsFontSizeToFitWidth = true
        address.font = UIFont(name: "HiraKakuProN-W3", size: 8)
        wifiInfo.font = UIFont(name: "HiraKakuProN-W6", size: 7)
        distanceLabel.font = UIFont(name: "HiraKakuProN-W3", size: 8)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
