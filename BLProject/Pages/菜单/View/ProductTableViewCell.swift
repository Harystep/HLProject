//
//  ProductTableViewCell.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/16.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class ProductTableViewCell: BaseTableViewCell {
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var subTitleLb: UILabel!
    
    @IBOutlet weak var priceLb: UILabel!
    @IBOutlet weak var shadowBack: UIView!
    @IBOutlet weak var needHelpBt: UIButton!
    
    @IBOutlet weak var selectBt: UIButton!
    
    @IBOutlet weak var bottomPriceBack: UIView!
    @IBOutlet weak var addToCarBt: UIButton!
    var productData: JSON?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        shadowBack.shadow(offset: CGSize.init(width: 0, height: 1), opacity: 0.2, radius: 1, cornerRadius: 6, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        addToCarBt.onTap {
            MainWindow.makeToast("加入购物车成功")
        }
        needHelpBt.isHidden = true
        selectBt.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
