//
//  MyDQGViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/22.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class MyDQGViewController: BaseViewController {
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    var regularListData: [JSON]?
    var timeAlert : TimeAlertView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        getMyOrderList()
        self.getConfig()
    }
    
    func getMyOrderList() {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         ] as [String : Any]
        NetworkManager.request(api: .getRegularOrderList, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.regularListData = jsonObj["dataList"].arrayValue
                    self.addCell(with: self.regularListData!)
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func addCell(with list: [JSON]) {
        mainTableView.addElements(list, cell: MyDQGCell.self, cellNibName: "MyDQGCell") { (data, cell, row) in
            cell.stateLb.text = "剩余\(data["surplus"].stringValue)次"
            cell.startTimeLb.text = data["tradetime"].stringValue
            let utilStr = "燕窝含量：\(data["unit"].stringValue)"
            let priceStr = "价格：\(data["orderprice"].stringValue)元"
            let sendModeStr = "配送模式：\(data["sendtype"].stringValue)"
            let sendCountStr = "次数：\(data["sendcount"].stringValue)次"
            let timeStr = "送达时段：\(data["donestagetime"].stringValue)"
            let startTimeStr = "起送日期：\(data["startsendtime"].stringValue)"
            let textArray = [utilStr, priceStr, sendModeStr, sendCountStr, timeStr, startTimeStr]
            for (i,tempView) in cell.centerBtBack.subviews.enumerated() {
                let tempLb = tempView as! UILabel
                tempLb.text = textArray[i]
            }
            if data["surplus"].intValue == 0 {
                cell.setView(isFinish: true)
            }else{
                cell.changeTimeBt.onTap {
                    
                    self.timeAlert = TimeAlertView.init(frame: CGRect.zero)
                    MainWindow.addSubview(self.timeAlert!)
                    self.timeAlert?.snp.makeConstraints({ (make) in
                        make.edges.equalToSuperview()
                    })
                    self.timeAlert?.defaultTime = data["donestagetime"].stringValue
                    self.timeAlert?.timeArray = self.configInfo?["sendtimestage"].arrayValue
                    
                    self.timeAlert?.selectClosure = {
                        (timeInfo) in
                        self.editOrder(type: "2", changeID: timeInfo["id"].stringValue, orderNo: data["regularno"].stringValue, sendTime: data["startsendtime"].stringValue, resultClosure: {
                            (result) in
                            if result {
                                self.regularListData![row]["donestagetime"] = timeInfo["showtext"]
                                self.addCell(with: self.regularListData!)
                                self.timeAlert?.removeFromSuperview()
                                self.view.makeToast("修改成功")
                            }
                        })
                    }
                }
                cell.changeAddressBt.onTap {
                    let pushedVC = ChangeDQGAddressViewController.init(nibName: "ChangeDQGAddressViewController", bundle: nil)
                    pushedVC.defaultAddressid = data["addressid"].stringValue
                    pushedVC.selectAddressCosure = {
                        (addressInfo) in
                        self.editOrder(type: "1", changeID: addressInfo["addressid"].stringValue, orderNo: data["regularno"].stringValue, sendTime: data["startsendtime"].stringValue, resultClosure: {
                            (result) in
                            if result {
                                self.regularListData![row]["addressid"] = addressInfo["addressid"]
                                self.addCell(with: self.regularListData!)
                                self.view.makeToast("修改成功")
                            }
                        })
                        
                        
                    }
                    UIViewController.currentViewController()?.navigationController?.pushViewController(pushedVC, animated: true)
                }
            }
            
        }
        mainTableView.reloadData()
    }
    
    /// 编辑订单
    ///
    /// - Parameter type: 1：地址 2：时段
    func editOrder(type: String, changeID: String, orderNo: String, sendTime: String, resultClosure: @escaping ((Bool) -> Void)) {
        if self.configInfo == nil{
            self.view.makeToast("网络错误，请重试")
            self.getConfig()
            return
        }
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "regularno" : orderNo,
                         "sendtime" : sendTime,
                         "editinfo" : changeID,
                         "edittype" : type
                         ] as [String : Any]
        NetworkManager.request(api: .editRegularOrderInfo, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    resultClosure(true)
                }else{
                    resultClosure(false)
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                resultClosure(false)
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)
        let _ = self.addTitle(title: "定期购订单", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
        mainTableView.tableFooterView = UIView.init()
        mainTableView.estimatedRowHeight = 50
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


class MyDQGCell: BaseTableViewCell {
    
    @IBOutlet weak var stateLb: UILabel!
    @IBOutlet weak var bottomBtBack: UIView!
    
    @IBOutlet weak var centerBtBack: UIView!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var changeTimeBt: UIButton!
    @IBOutlet weak var changeAddressBt: UIButton!
    
    @IBOutlet weak var startTimeLb: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setView(isFinish: false)
        
    }
    
    func setView(isFinish: Bool) {
        if isFinish {
            bottomLine.snp.remakeConstraints { (make) in
                make.top.equalTo(centerBtBack.snp.bottom).offset(29)
                make.leading.trailing.bottom.equalToSuperview()
            }
            bottomBtBack.isHidden = true
        }else{
            bottomLine.snp.remakeConstraints { (make) in
                make.top.equalTo(centerBtBack.snp.bottom).offset(72)
                make.leading.trailing.bottom.equalToSuperview()
            }
            bottomBtBack.isHidden = false
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


class TimeAlertView: BaseView {
    
    @IBOutlet weak var timeBtsBack: UIView!
    var defaultTime: String?{
        didSet{
            if timeArray != nil {
                for (i,tempTime) in timeArray!.enumerated() {
                    if (tempTime["showtext"].string ?? "") == defaultTime! {
                        self.selectTimeBt(button: timeBtArray[i])
                    }
                }
            }
        }
    }
    var timeArray: [JSON]?{
        didSet{
            timeBtArray.removeAll()
            self.addTimeString()
        }
    }
    var timeBtArray = Array<UIButton>.init()
    
    func addTimeString() {
        for (i,tempTime) in timeArray!.enumerated() {
            let timeBt = UIButton.init()
            timeBtsBack.addSubview(timeBt)
            timeBt.snp.makeConstraints { (make) in
                make.height.equalTo(30)
                if i % 2 == 0{
                    make.leading.equalToSuperview()
                    if i == 0{
                        make.top.equalToSuperview()
                    }else{
                        make.top.equalTo(timeBtArray.last!.snp.bottom).offset(10)
                        make.width.equalTo(timeBtArray.last!)
                    }
                }else{
                    make.trailing.equalToSuperview()
                    make.leading.equalTo(timeBtArray.last!.snp.trailing).offset(20)
                    make.top.equalTo(timeBtArray.last!)
                }
                if i == (timeArray?.count ?? 0) - 1 {
                    make.bottom.equalToSuperview()
                }
            }
            timeBt.setTitle(tempTime["showtext"].stringValue, for: .normal)
            timeBt.setBackgroundImage(#imageLiteral(resourceName: "timeBtImageNormal"), for: .normal)
            timeBt.setBackgroundImage(#imageLiteral(resourceName: "timeBtImage"), for: .selected)
            timeBt.tag = i
            timeBt.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
            timeBt.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .selected)
            timeBt.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            timeBt.onTap {
                self.selectTimeBt(button: timeBt)
            }
            timeBtArray.append(timeBt)
            if self.defaultTime != nil {
                if (tempTime["showtext"].string ?? "") == self.defaultTime! {
                    self.selectTimeBt(button: timeBt)
                }
            }
        }
    }
    
    func selectTimeBt(button: UIButton) {
        self.currentSelectIndex = button.tag
        for tempBt in self.timeBtArray {
            if tempBt == button {
                tempBt.isSelected = true
            }else{
                tempBt.isSelected = false
            }
        }
    }
    
    var currentSelectIndex: Int?
    var selectClosure: ((JSON) -> Void)?
    
    @IBAction func bottomBtAction(_ sender: UIButton) {
        if sender.tag == 0{
            self.removeFromSuperview()
            return
        }
        if currentSelectIndex != nil && timeArray != nil {
            self.selectClosure?(timeArray![currentSelectIndex!])
        }
    }
    
    
    
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
    
    @objc func injected() {
        //        setupSubViews()
        
    }
    
}
