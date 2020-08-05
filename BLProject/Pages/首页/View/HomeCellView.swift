//
//  HomeCellView.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/15.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class HomeCellView: BaseView {
    
    var productData: JSON?
    @IBOutlet weak var priceLb: UILabel!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var addToCarBt: UIButton!
    func setupSubViews() {
        self.shadowColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        self.shadow(offset: CGSize.init(width: 1, height: 2), opacity: 0.3, radius: 2)
//        addToCarBt.onTap {
//            MainWindow.makeToast("加入购物车成功")
//        }
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
