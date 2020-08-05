//
//  ConfirmDQGViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/21.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class ConfirmDQGViewController: BaseViewController {
    
    @IBOutlet weak var cardTopLb: UILabel!
    @IBOutlet weak var cardBottomLb: UILabel!
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    
    @IBOutlet weak var addressBack: UIView!
    @IBOutlet weak var payBt: UIButton!
    var parameter: Dictionary<String, Any>?
    var sendPrice: Float?
    @IBOutlet weak var totalPriceLb: UILabel!
    
    @IBOutlet weak var wechatPayBack: UIView!
    @IBOutlet weak var aliPayBack: UIView!
    @IBOutlet weak var phoneLb: UILabel!
    @IBOutlet weak var addressLb: UILabel!
    
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var customPayBack: UIView!
    @IBOutlet weak var sendPriceLb: UILabel!
    @IBOutlet weak var addAddressBack: UIView!
    @IBOutlet weak var sendInfoTextView: PlaceholderTextView!
    
    var addressInfo: JSON?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        getAddressList()
        getCardList()
        payViewClick(view: wechatPayBack)
        self.totalPriceLb.text = parameter?["orderprice"] as? String
        self.sendPriceLb.text = "含\(self.sendPrice ?? 0)元配送费"
        NotificationCenter.default.addObserver(self, selector: #selector(aliPaySuccess), name: NSNotification.Name.init("alipaysuccess"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func aliPaySuccess() {
        self.showDINGQIGOU()
    }
    
    func showDINGQIGOU() {
        self.tabBarController?.selectedIndex = 2
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    
    func getAddressList() {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         ] as [String : Any]
        NetworkManager.request(api: .addressList, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    let addressData = jsonObj["dataList"].arrayValue.first
                    if addressData != nil{
                        self.addressInfo = addressData
                        self.nameLb.text = addressData!["receivename"].stringValue
                        self.phoneLb.text = addressData!["receivephone"].stringValue
                        self.addressLb.text = addressData!["fullAddress"].stringValue
                    }else{
                        self.addAddressBack.isHidden = false
                    }
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)
        let _ = self.addTitle(title: "确认订单", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
        
        payBt.onTap {
            self.buyAction()
//            self.navigationController?.popToRootViewController(animated: false)
//            self.tabBarController?.selectedIndex = 2
        }
        addressBack.addTapGesture { (tap) in
            self.showAddressList()
        }
        wechatPayBack.addTapGesture { (tap) in
            self.payViewClick(view: tap.view!)
        }
        aliPayBack.addTapGesture { (tap) in
            self.payViewClick(view: tap.view!)
        }
        customPayBack.addTapGesture { (tap) in
            self.payViewClick(view: tap.view!)
        }
        addAddressBack.isHidden = true
        addAddressBack.addTapGesture { (tap) in
            self.showAddressList()
        }
    }
    
    func showAddressList() {
        let pushedVC = AddressViewController.init(nibName: "AddressViewController", bundle: nil)
        pushedVC.selectAddressCosure = {
            (addressData: JSON) in
            self.addAddressBack.isHidden = true
            self.addressInfo = addressData
            self.nameLb.text = addressData["receivename"].stringValue
            self.phoneLb.text = addressData["receivephone"].stringValue
            self.addressLb.text = addressData["fullAddress"].stringValue
        }
        self.navigationController?.pushViewController(pushedVC, animated: true)
    }
    
    var paytype = 2
    func payViewClick(view: UIView) {
        if view.tag == 3 {
            if !self.canCardUse{
                self.view.makeToast("无打折卡可用")
                return
            }
            let pushedVC = MyCardViewController.init(nibName: "MyCardViewController", bundle: nil)
            pushedVC.selectCard = true
            pushedVC.selectCardClosure = {
                (index) in
                self.resetPayView(with: view)
                self.resetCardView(with: self.cardList![index])
            }
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }else{
            self.resetPayView(with: view)
        }
        
    }
    
    func resetPayView(with selectView: UIView) {
        for subView in [wechatPayBack, aliPayBack, customPayBack] {
            let tempView = subView!
            let button = tempView.viewWithTag(999) as! UIButton
            if tempView == selectView {
                tempView.superview?.bringSubview(toFront: tempView)
                tempView.shadow(offset: CGSize.zero, opacity: 0.2, radius: 20, cornerRadius: 6, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
                button.isSelected = true
                self.paytype = tempView.tag
            }else{
                button.isSelected = false
                tempView.shadow(offset: CGSize.zero, opacity: 0, radius: 0, cornerRadius: 0, color: UIColor.black)
            }
        }
    }
    
    var currentCardNo: String?
    func payWithCard(with orderNo: String) {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "orderno" : orderNo,
                         "ordertype" : "2",
                         "cardno" : currentCardNo!
            ] as [String : Any]
        NetworkManager.request(api: .consumeCard, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    MainWindow.makeToast("支付成功")
                    self.showDINGQIGOU()
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    var canCardUse = true
    var cardList: [JSON]?
    func getCardList() {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         ] as [String : Any]
        NetworkManager.request(api: .getPosCardList, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.cardList = jsonObj["dataList"].arrayValue
                    if self.cardList!.count > 0 {
                        self.resetCardView(with: self.cardList![0])
                    }else{
                        self.canCardUse = false
                        
                    }
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func resetCardView(with data: JSON) {
        let money = String.init(format: "%.2f", data["point"].floatValue)
        cardTopLb.text = "打折卡(\(money)元可用)"
        cardBottomLb.text = "享\("\(data["cashPayRate"].floatValue / 10)")折优惠"
        currentCardNo = data["cardNo"].stringValue
    }
    
    func buyAction() {

//        //        let sting = dayArray.com
//        let parameter = [
//            "rid" : self.regularData["regularinfo"]["rid"].string ?? "",
//            "userid" : userId ?? "",
//            "addressid" : "",
//            "orderprice" : self.priceLb.text,
//            "sendstarttime" : startDateLb.text,
//            "nuit" : utilKey,
//            "timestate" : timeKey,
//            "sendcount" : countKey,
//            "sendday" : sendDayKey,
//            "sendweek" : sendWeek
//        ]
        if self.parameter == nil {
            self.view.makeToast("网络错误，请重试")
            return
        }
        if self.addressInfo == nil {
            self.view.makeToast("请添加收货地址")
            return
        }
        self.parameter!["paytype"] = self.paytype
        self.parameter!["addressid"] = self.addressInfo!["addressid"].stringValue
        self.parameter!["content"] = self.sendInfoTextView.text ?? ""
        if paytype == 3 {
            self.parameter!["cardno"] = currentCardNo!
        }
        NetworkManager.request(api: .createOrderByRegular, parameters: self.parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
//                    self.view.makeToast("创建订单成功")
                    let obj = jsonObj["dataList"].type == .null ? jsonObj["dataObj"] : jsonObj["dataList"]
                    let orderNo = obj["orderno"].stringValue
                    if self.paytype == 3 {
                        self.payWithCard(with: orderNo)
                    }else if self.paytype == 2{
//                        let userId = self.userInfo!["uid"].string
//                        let token = self.userInfo!["usertoken"].string
                        let url = "https://www.coding88.com/pay.html?orderno=\(orderNo)&paytype=2"
                        self.showPayWeb(with: url)
                    }else{
                        self.payWithAli(with: obj)
                    }
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
