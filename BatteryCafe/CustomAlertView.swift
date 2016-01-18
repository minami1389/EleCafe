//
//  CustomAlertView.swift
//  BatteryCafe
//
//  Created by Baba Minami on 1/10/16.
//  Copyright © 2016 TeamDeNA. All rights reserved.
//

import UIKit


protocol CustomAlertViewDelegate {
    func customAlertViewDidComplete(alertView: CustomAlertView)
}

class CustomAlertView: UIView {

    var delegate:CustomAlertViewDelegate!
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var completeButton: UIButton!
   
    override init(frame: CGRect) {
        super.init(frame: frame)
        NSBundle.mainBundle().loadNibNamed("CustomAlertView", owner: self, options: nil)
        bounds = CGRect(x: 0, y: 0, width: 280, height: 150)
        contentView.frame = bounds
        addSubview(contentView)
        
        completeButton.layer.shadowColor = UIColor(red: 202/255, green: 202/255, blue: 202/255, alpha: 1.0).CGColor
        completeButton.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        completeButton.layer.shadowOpacity = 1.0
        completeButton.layer.shadowRadius = 0
        
        self.hidden = true
        self.alpha = 0.0
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func show(title: String, detail:String) {
        titleLabel.text = title
        detailLabel.text = detail
        self.hidden = false
        UIView.animateWithDuration(0.2) { () -> Void in
            self.alpha = 1.0
        }
    }
    
    @IBAction func didPushCompleteButton(sender: AnyObject) {
        UIView.animateWithDuration(0.2) { () -> Void in
            self.alpha = 0.0
        }
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.hidden = true
        }
        if delegate != nil {
            delegate.customAlertViewDidComplete(self)
        }
    }
}
