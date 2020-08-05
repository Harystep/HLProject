//
//  CustomAlertSheet.swift
//  HProject
//
//  Created by XinLiang on 2018/7/31.
//  Copyright © 2018年 xinliang. All rights reserved.
//
//com.xl.BLProject
import UIKit

class CustomAlertSheet: BaseView {
    
    @IBOutlet weak var topBt: UIButton!
    @IBOutlet weak var bottomBt: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var bottomViewBottom: NSLayoutConstraint!
    var clickBtClosure: ((_ index: Int) -> Void)?
    
    func setupSubViews() {
        
    }
    let animinationTime = 0.3
    func showAlertSheet() {
        bottomViewBottom.constant = 0
        UIView.animate(withDuration: animinationTime) {
            self.backView.layoutIfNeeded()
        }
    }
    
    
    @IBAction func btAction(_ sender: UIButton) {
        self.clickBtClosure?(sender.tag)
        dismiss()
    }
    
    @IBAction func cancleBtAction(_ sender: UIButton) {
        dismiss()
    }
    
    func dismiss() {
        bottomViewBottom.constant = -200
        UIView.animate(withDuration: animinationTime, animations: {
            self.backView.layoutIfNeeded()
        }) { (finish) in
            if finish {
                self.removeFromSuperview()
            }
        }
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
