//
//  CustomCalendarCell.swift
//  BLProject
//
//  Created by XinLiang on 2018/11/16.
//  Copyright © 2018 xinliang. All rights reserved.
//

import UIKit
import FSCalendar

class CustomCalendarCell: FSCalendarCell {
    var selectLayer: CAShapeLayer?
    override init!(frame: CGRect) {
        super.init(frame: frame)
        selectLayer = CAShapeLayer.init()
        selectLayer!.fillColor = #colorLiteral(red: 0.9757710099, green: 0.9153273702, blue: 0.823864162, alpha: 1)
        selectLayer?.actions = ["hidden" : NSNull.init()]
        self.contentView.layer.insertSublayer(selectLayer!, below: self.titleLabel.layer)
        selectLayer?.isHidden = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let diameter : CGFloat = 25
        selectLayer!.path = UIBezierPath.init(ovalIn: CGRect.init(x: self.titleLabel.center.x - diameter / 2, y: self.titleLabel.center.y-diameter/2, width: diameter, height: diameter)).cgPath
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
}
