//
//  CustomMarkerView.swift
//  BatteryCafe
//
//  Created by Baba Minami on 12/23/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit

class CustomMarkerView: UIView {

    @IBOutlet weak var shopNameLabel: UILabel!
    @IBOutlet weak var wifiLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    class func instance() -> CustomMarkerView {
        let view = UINib(nibName: "CustomMarkerView", bundle: nil).instantiateWithOwner(self, options: nil).first as! CustomMarkerView
        view.layer.masksToBounds = false
        view.layer.shadowOpacity = 0.5
        view.layer.shadowColor = UIColor(red: 202/255, green: 202/255, blue: 202/255, alpha: 1.0).CGColor
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.translatesAutoresizingMaskIntoConstraints = true
        view.shopNameLabel.font = UIFont(name: "HiraKakuProN-W6", size: 14)
        view.wifiLabel.font = UIFont(name: "HiraKakuProN-W6", size: 9)

        return view
    }
}
