//
//  OrderTableViewCell.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/22.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

enum OrderCellState : Int {
    case waitPay = 1
    case waitSend
    case onTheWay
    case waitReceive
    case waitComment
    case canceled
    case finish
}

class OrderTableViewCell: BaseTableViewCell {
    @IBOutlet weak var topStateLb: UILabel!
    @IBOutlet weak var bottomRight: UIButton!
    @IBOutlet weak var bottomCenter: UIButton!
    @IBOutlet weak var bottomLeft: UIButton!
    
    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var secondImage: UIImageView!
    @IBOutlet weak var thirdImage: UIImageView!
    @IBOutlet weak var topLb: UILabel!
    @IBOutlet weak var timeLb: UILabel!
    
    
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var moneyLb: UILabel!
    
    var state: OrderCellState?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setCurrentCell(state: OrderCellState) {
        self.state = state
        let names = ["待付款", "待发货", "配送中", "待提货", "待评价", "已取消", "已完成"]
        topStateLb.text = names[state.rawValue - 1]
        if state == .canceled {
            topStateLb.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        }else{
            topStateLb.textColor = #colorLiteral(red: 0.8156862745, green: 0.5803921569, blue: 0.2705882353, alpha: 1)
        }
        if state == .waitSend || state == .onTheWay {
            bottomLine.snp.remakeConstraints { (make) in
                make.top.equalTo(moneyLb.snp.bottom).offset(13)
                make.leading.trailing.bottom.equalToSuperview()
            }
            bottomLeft.isHidden = true
            bottomCenter.isHidden = true
            bottomRight.isHidden = true
        }else{
            bottomLine.snp.remakeConstraints { (make) in
                make.top.equalTo(bottomRight.snp.bottom).offset(11)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
        
        if state == .waitPay {
            bottomLeft.isHidden = true
            bottomCenter.isHidden = false
            bottomRight.isHidden = false
            bottomRight.setTitle("去付款", for: .normal)
            bottomCenter.setTitle("取消订单", for: .normal)
        }
        if state == .canceled || state == .finish {
            bottomLeft.isHidden = true
            bottomCenter.isHidden = false
            bottomRight.isHidden = false
            bottomRight.setTitle("查看", for: .normal)
            bottomCenter.setTitle("删除订单", for: .normal)
        }
        if state == .waitReceive {
            bottomLeft.isHidden = true
            bottomCenter.isHidden = true
            bottomRight.isHidden = false
            bottomRight.setTitle("取餐码", for: .normal)
        }
        if state == .waitComment {
            bottomLeft.isHidden = false
            bottomCenter.isHidden = false
            bottomRight.isHidden = false
            bottomRight.setTitle("去评价", for: .normal)
            bottomCenter.setTitle("申请售后", for: .normal)
            bottomLeft.setTitle("删除订单", for: .normal)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
