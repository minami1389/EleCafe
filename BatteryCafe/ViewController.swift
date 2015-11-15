//
//  ViewController.swift
//  BatteryCafe
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTextFieldOriginY: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switchSearchBar()
        return true
    }
    
    func switchSearchBar() {
        self.view.setNeedsUpdateConstraints()
        if searchTextFieldOriginY.constant == 0 {
            searchTextFieldOriginY.constant = -40
            searchTextField.resignFirstResponder()
        } else {
            searchTextFieldOriginY.constant = 0
            searchTextField.becomeFirstResponder()
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    @IBAction func didPushedSearchButton(sender: AnyObject) {
        switchSearchBar()
    }
    
    @IBAction func didPushedSettingButton(sender: AnyObject) {
        print("setting")
    }
  
}
