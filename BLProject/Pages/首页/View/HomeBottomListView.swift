//
//  HomeBottomListView.swift
//  BLProject
//
//  Created by XinLiang on 2018/9/8.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class HomeBottomListView: BaseView {
    @IBOutlet weak var topBannerBack: UIImageView!
    @IBOutlet weak var cellBack: UIView!
    
    //初始化时将xib中的view添加进来
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customLoadNibView()
    }
    
    //初始化时将xib中的view添加进来
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customLoadNibView()
    }
}
