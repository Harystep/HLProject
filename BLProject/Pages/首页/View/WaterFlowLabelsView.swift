//
//  WaterFlowLabelsView.swift
//  YamiNavigation2
//
//  Created by XinLiang on 2018/1/11.
//  Copyright © 2018年 xi-anyunjingzhiwei. All rights reserved.
//

import UIKit

class WaterFlowLabelsView: BaseView {

    @IBOutlet weak var labelBackView: UIView!
    var multiSelect: Bool = false
    
    var clickSearchLabelBlock : ((String) -> Void)?
    var minWidth: CGFloat = 0
    var selectIndexs = Array<Int>.init()
    var selectIndex: Int?
    var labelNames : Array<String>?{
        didSet{
            self.layoutSubviews()
        }
    }
    var labelsList = Array<UIButton>.init()
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.setUpLabels()
        
    }
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if labelNames != nil {
            if labelBackView.subviews.count == 0 {
                self.setUpLabels()
            }
        }else{
            for tempView in labelsList {
                tempView.removeFromSuperview()
            }
        }
    }
    
    func setUpLabels() {
        var lastTempView : UIButton?
        let insideWidth = CGFloat(7.5)//两边留边距
        let outsideDealtX = CGFloat(15)
        let outsideDealtY = CGFloat(15)
        let height = CGFloat(30)
        
        for nameIndex in 0..<(labelNames?.count)! {
            
            let labelName = labelNames![nameIndex]

            let tempButton = UIButton.init()
            tempButton.tag = nameIndex
            tempButton.addTarget(self, action: #selector(clickSearchLabel(sender:)), for: UIControlEvents.touchUpInside)
            tempButton.cornerRadius = 15
            tempButton.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
            tempButton.setTitle(labelName, for: UIControlState.normal)
            tempButton.titleLabel?.font = Font.systemFont(ofSize: 14)
            tempButton.setTitleColor(#colorLiteral(red: 0.137254902, green: 0.137254902, blue: 0.137254902, alpha: 1))
            labelBackView.addSubview(tempButton)
            var width = labelName.width(withConstrainedHeight: height, font: (tempButton.titleLabel?.font)!)
            width += insideWidth * 2     //两边留15
            if width > labelBackView.frame.size.width {
                width = labelBackView.frame.size.width
            }
            if minWidth != 0 && width < minWidth {
                width = minWidth
            }
            var tempFrame : CGRect!
            if lastTempView == nil {
                tempFrame = CGRect.init(x: 0, y: 0, width: width, height: height)
            }else{
                let lastViewRight = ceil((lastTempView?.frame.origin.x)! + (lastTempView?.frame.size.width)!)
                if ceil(lastViewRight + outsideDealtX * 2 + width) > labelBackView.frame.size.width {
                    var y = ceil((lastTempView?.frame.origin.y)! + (lastTempView?.frame.size.height)!)
                    y += outsideDealtY
                    tempFrame = CGRect.init(x: 0, y: y, width: width, height: height)
                }else{
                    tempFrame = CGRect.init(x: lastViewRight + outsideDealtX, y: (lastTempView?.frame.origin.y)!, width: width, height: height)
                }
            }
            tempButton.frame = tempFrame
            labelsList.append(tempButton)
            lastTempView = tempButton
            if nameIndex == (labelNames?.count)! - 1 {
                tempButton.snp.makeConstraints({ (make) in
                    make.top.equalTo(labelBackView).offset(tempFrame.origin.y)
                    make.bottom.equalTo(labelBackView)
                    make.leading.equalTo(tempFrame.origin.x)
//                    make.width.equalTo(tempFrame.size.width)
//                    make.height.equalTo(tempFrame.size.height)
                    make.size.equalTo(tempFrame.size)
                })
            }
        }
    }
    
    func cleanSelectState() {
        for tempBt in labelsList {
            tempBt.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
            tempBt.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        }
        selectIndex = nil
        selectIndexs.removeAll()
    }
    
    @objc func clickSearchLabel(sender: UIButton) {
        let labelName = labelNames![sender.tag]
//        sender.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
//        sender.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
//        if selectIndex != nil {
//            if !multiSelect {
//              labelsList[selectIndex!].backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
//                sender.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
//            }
//        }
        if multiSelect {//多选
            if selectIndexs.contains(sender.tag) {
                selectIndexs.remove(sender.tag)
                labelsList[sender.tag].backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
                sender.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
            }else{
                selectIndexs.append(sender.tag)
                sender.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
                sender.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
            }
        }else{//单选
            if sender.tag == selectIndex{
                return
            }
            if selectIndex != nil {
                labelsList[selectIndex!].backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
                labelsList[selectIndex!].setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
            }
            sender.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            sender.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
            selectIndex = sender.tag
        }
//        selectIndex = sender.tag
        self.clickSearchLabelBlock?(labelName)
    }
}
