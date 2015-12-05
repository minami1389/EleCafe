//
//  ListViewController.swift
//  BatteryCafe
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit
import CoreLocation

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchOriginY: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didFetchCafeResources", name: "didFetchCafeResourcesMap", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "didFetchCafeResourcesList", object: nil)
    }

    func didFetchCafeResources() {
        tableView.reloadData()
    }

    @IBAction func didPushedChangeMap(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cafes = ModelLocator.sharedInstance.getCafe().getResources()
        return cafes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cafes = ModelLocator.sharedInstance.getCafe().getResources()
        let cafe = cafes[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomCell") as! CustomTableViewCell
        cell.shopName.text = cafe.name
        cell.address.text = cafe.address
        cell.wifiInfo.text = cafe.wireless
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailVC = DetailViewController()
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
//NavigationBar
    @IBAction func didPushedSearchButton(sender: AnyObject) {
        switchSearchBar()
    }
  
    @IBAction func didPushedSettingButton(sender: AnyObject) {
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switchSearchBar()
        searchCafeFromAddress()
        searchTextField.text = ""
        return true
    }
    
    func switchSearchBar() {
        self.view.setNeedsUpdateConstraints()
        if searchOriginY.constant == 0 {
            searchOriginY.constant = -40
            searchTextField.resignFirstResponder()
        } else {
            searchOriginY.constant = 0
            searchTextField.becomeFirstResponder()
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    func searchCafeFromAddress() {
        let address = searchTextField.text
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!, inRegion: nil, completionHandler: { (placemarks, error) in
            if error != nil {
                print("error:\(error)")
            } else {
                let place = placemarks![0]
                let latitude = place.location!.coordinate.latitude
                let longitude = place.location!.coordinate.longitude
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                ModelLocator.sharedInstance.getCafe().fetchCafes(coordinate)
            }
        })
    }

}
