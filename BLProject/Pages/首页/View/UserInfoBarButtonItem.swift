//
//  UserInfoBarView.swift
//  ScenicCheck
//
//  Created by XinLiang on 2017/12/4.
//  Copyright © 2017年 xi-anyunjingzhiwei. All rights reserved.
//

import UIKit

class UserInfoBarView: UIView {
    
    var bandgeCount : Int = 0{
        didSet{
            bandgeLb.text = "\(bandgeCount)"
        }
    }
    
    let bandgeLb = UILabel.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setSubviews()
    }
    
    func setSubviews() -> Void {
        let mainImage = UIImageView.init()
        self.addSubview(mainImage)
        mainImage.contentMode = .scaleAspectFit
        mainImage.snp.makeConstraints { (make) in
//            make.center.equalTo(self)
            make.leading.equalTo(self)
            make.top.equalTo(self).offset(2)
            make.trailing.equalTo(self).offset(-8)
            make.bottom.equalTo(self)
            make.width.height.equalTo(31)
        }
        mainImage.image = UIImage.init(named: "icon_myself_p")
        
        
        bandgeLb.font = UIFont.systemFont(ofSize: 11)
        self.addSubview(bandgeLb)
        bandgeLb.textAlignment = NSTextAlignment.center
        bandgeLb.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        bandgeLb.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        bandgeLb.snp.makeConstraints { (make) in
            make.trailing.top.equalTo(self)
            make.width.height.equalTo(14)
        }
//        bandgeLb.text = "0"
        bandgeLb.cornerRadius = 7
        bandgeLb.maskToBounds = true
        bandgeLb.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
