//
//  CustomCornerView.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/28.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class CustomCornerView: UIView {
    
    var customCornerRadius: CGFloat = 0
    
    func addCustomCorner(with radius: CGFloat) {
        self.customCornerRadius = radius
        
        if self.frame.size.width != 0 {
            self.cornerRadius(corners: [.topLeft, .topRight], radius: customCornerRadius)
        }
        self.clipsToBounds = true
    }

    override func layoutSubviews() {
        if self.frame.size.width != 0 {
            self.cornerRadius(corners: [.topLeft, .topRight], radius: customCornerRadius)
        }
        self.clipsToBounds = true
    }
}
