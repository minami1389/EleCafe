//
//  DlNodeView.swift
//  BatteryCafe
//
//  Created by Baba Minami on 12/13/15.
//  Copyright © 2015 TeamDeNA. All rights reserved.
//

import UIKit
import Ji

class DlNodeView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    let dtLabelWidth:CGFloat = 84
    let bottomMargin:CGFloat = 14
 
    override init(frame: CGRect) {
        super.init(frame: CGRectZero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(dlNode:JiNode, index:Int, width:CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: 0))
        
        let dtLabel = UILabel(frame: CGRect(x: 0, y: 0, width: dtLabelWidth, height: 0))
        dtLabel.font = UIFont(name: "HiraKakuProN-W6", size: 13.0)
        dtLabel.textColor = UIColor(red: 78/255, green: 75/255, blue: 73/255, alpha: 1.0)
        dtLabel.text = dlNode.xPath("//dt[\(index+1)]").first?.content
        dtLabel.sizeToFit()
        dtLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(dtLabel)
        
        let ddLabel = UILabel(frame: CGRect(x: dtLabelWidth, y: -4, width: width - dtLabelWidth, height: 0))
        ddLabel.font = UIFont(name: "HiraKakuProN-W3", size: 13.0)
        ddLabel.textColor = UIColor(red: 78/255, green: 75/255, blue: 73/255, alpha: 1.0)
        let ddTexts = dlNode.xPath("//dd[\(index+1)]/text()")
        var ddLabelText = ""
        for var i = 0; i < ddTexts.count; i++ {
            ddLabelText += "\(ddTexts[i].content!)"
            if i+1 != ddTexts.count {
                ddLabelText += "\n"
            }
        }
       
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 17
        paragraphStyle.maximumLineHeight = 17
        let attributedText = NSMutableAttributedString(string: ddLabelText)
        attributedText.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attributedText.length))
        ddLabel.attributedText = attributedText
        
        ddLabel.numberOfLines = 0
        ddLabel.sizeToFit()
        self.addSubview(ddLabel)
        
        self.frame.size.height = ddLabel.frame.size.height + bottomMargin
        
    }
}
