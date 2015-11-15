//
//  ListViewController.swift
//  BatteryCafe
//
//  Created by minami on 11/13/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    @IBAction func didPushedChangeMap(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(false)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cafes = ModelLocator.sharedInstance.getCafe().getResources()
        return cafes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cafes = ModelLocator.sharedInstance.getCafe().getResources()
        let cafe = cafes[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomCell") as! CustomTableViewCell
        cell.icon.image = UIImage(named: "stabu.jpg")
        cell.shopName.text = cafe.name
        cell.address.text = cafe.address
        cell.wifiInfo.text = cafe.wireless
        return cell
    }
}
