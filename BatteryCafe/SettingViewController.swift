//
//  SettingViewController.swift
//  BatteryCafe
//
//  Created by Baba Minami on 12/23/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let cellMargin:CGFloat = 14
    
    let categories = ["ファーストフード","カフェ・喫茶店","飲食店","ネットカフェ","待合室・ラウンジ","コンビニエンスストア","コワーキングスペース","その他"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SettingCell", forIndexPath: indexPath) as! SettingCollectionViewCell
        cell.categoryNameLabel.text = categories[indexPath.row]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SettingCollectionViewCell
        cell.categoryImageView.image = UIImage(named: "cafe_off-75@2x.png")
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SettingCollectionViewCell
        cell.categoryImageView.image = UIImage(named: "cafe-75@2x.png")
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.size.width - cellMargin*2) / 3
        let cellHeight = cellWidth / 13 * 15
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
    @IBAction func didPushedCloseButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }


}
