//
//  ViewController.swift
//  BatteryCafe
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var searchTextFieldOriginY: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        searchTextFieldOriginY.constant = -40
    }

    @IBAction func didPushedSearchButton(sender: AnyObject) {
        self.view.setNeedsUpdateConstraints()
        if searchTextFieldOriginY.constant == 0 {
            searchTextFieldOriginY.constant = -40
        } else {
            searchTextFieldOriginY.constant = 0
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    @IBAction func didPushedSettingButton(sender: AnyObject) {
        print("setting")
    }
  
}
