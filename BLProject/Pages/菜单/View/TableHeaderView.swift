//
//  TableHeaderView.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/16.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class TableHeaderView: BaseView {

    @IBOutlet weak var stateView: UIView!
    var lastSelectBt: UIButton?
    @IBOutlet weak var firstBt: UIButton!
    
    var clickItemClosure: ((Int, Int) -> Void)?
    
    func click(with index: Int) {
        self.selectBtAction(stateView.superview?.subviews[index].subviews.last as! UIButton)
    }
    
    @IBAction func selectBtAction(_ sender: UIButton) {
        if lastSelectBt != nil {
            if lastSelectBt! == sender {
                return
            }
            lastSelectBt!.isSelected = false
        }
        sender.isSelected = true
        self.clickItemClosure?(lastSelectBt!.tag, sender.tag)
        stateView.snp.remakeConstraints { (make) in
            make.centerX.equalTo(sender)
            make.bottom.equalToSuperview().offset(-5)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.stateView.layoutIfNeeded()
        }) { (finish) in
            
        }
        lastSelectBt = sender
    }
    
    func setupSubViews() {
//        self.shadowColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
//        self.shadow(offset: CGSize.init(width: 1, height: 2), opacity: 0.3, radius: 2)
        self.selectBtAction(firstBt)
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
