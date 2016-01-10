//
//  SettingViewController.swift
//  BatteryCafe
//
//  Created by Baba Minami on 12/23/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit
import Google

class SettingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let cellMargin:CGFloat = 14
    
//    let categories = ["ファーストフード","カフェ・喫茶店","飲食店","ネットカフェ","待合室・ラウンジ","コンビニエンスストア","コワーキングスペース","その他"]
    let categories = ["fastfood","cafe","restaurant","netcafe","lounge","convenience","workingspace","others"]
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "SettingViewController")
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let settingState = ModelLocator.sharedInstance.getCafe().settingState()
        for var i = 0; i < settingState.count; i++ {
            if settingState[i] == false {
                collectionView.selectItemAtIndexPath(NSIndexPath(forItem: i, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.None)
            }
        }
        
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SettingCell", forIndexPath: indexPath) as! SettingCollectionViewCell
        cell.categoryImageView.image = UIImage(named: imageName(indexPath.item, selected: cell.selected))
        return cell
    }
    
    func imageName(index:Int, selected:Bool) -> String {
        if selected {
            return "set-\(categories[index])_off.png"
        } else {
            return "set-\(categories[index])_on.png"
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SettingCollectionViewCell
        cell.categoryImageView.image = UIImage(named: imageName(indexPath.item, selected: true))
        ModelLocator.sharedInstance.getCafe().changeSettingState(indexPath.item)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SettingCollectionViewCell
        cell.categoryImageView.image = UIImage(named: imageName(indexPath.item, selected: false))
        ModelLocator.sharedInstance.getCafe().changeSettingState(indexPath.item)
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
