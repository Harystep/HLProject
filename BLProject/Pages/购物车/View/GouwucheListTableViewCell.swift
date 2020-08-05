//
//  GouwucheListTableViewCell.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/18.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class GouwucheListTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var priceLb: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var subTitleLb: UILabel!
    
    @IBOutlet weak var shadowBack: UIView!
    @IBOutlet weak var priceAndCountView: UIView!
    @IBOutlet weak var lostStateLb: UILabel!
    
    @IBOutlet weak var addBt: UIButton!
    @IBOutlet weak var minsBt: UIButton!
    @IBOutlet weak var countLb: UILabel!
    @IBOutlet weak var selectBt: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        addBt.onTap {
//            self.countLb.text = "\((self.countLb.text?.intValue ?? 1) + 1)"
//        }
//        minsBt.onTap {
//            let count = (self.countLb.text?.intValue ?? 2) - 1
//
//            self.countLb.text = "\(count > 0 ? count : 1)"
//        }
//        selectBt.onTap {
//            self.selectBt.isSelected = !self.selectBt.isSelected
//        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class ShoppingCarHeaderView: BaseView {
    
    @IBOutlet weak var leftCountLb: UILabel!
    @IBOutlet weak var cleanBt: UIButton!
    func setupSubViews() {
        
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
}
