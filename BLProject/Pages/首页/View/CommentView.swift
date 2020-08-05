//
//  CommentView.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/21.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit
import SwiftyStarRatingView

class CommentView: BaseView {

    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var timeLb: UILabel!
    @IBOutlet weak var starRatingView: SwiftyStarRatingView!
    
    @IBOutlet weak var contentLb: UILabel!
    func setupSubViews() {
//        starRatingView.
    }
    
    //初始化时将xib中的view添加进来
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customLoadNibView()
        setupSubViews()
    }
    
    //初始化时将xib中的view添加进来
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customLoadNibView()
        setupSubViews()
    }
    
    @objc func injected() {
        //        setupSubViews()
        
    }

}
