//
//  ConfirmBuyViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/19.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit
import DatePickerDialog

class ConfirmBuyViewController: BaseViewController {

    @IBOutlet weak var selectTimeBt: UIButton!
    @IBOutlet weak var cardTopLb: UILabel!
    @IBOutlet weak var cardBottomLb: UILabel!
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    
    @IBOutlet weak var buySelectBack: UIView!

    @IBOutlet weak var selectStoreBack: UIView!
    @IBOutlet weak var topStoreView: UIView!
    @IBOutlet weak var bottomStoreView: UIView!
    
    @IBOutlet weak var selectReceiverBack: UIView!
    @IBOutlet weak var moreStoreBack: UIView!
    
    @IBOutlet weak var receiverView: UIView!
    @IBOutlet weak var payStateBack: UIView!
    @IBOutlet weak var additionalTextBack: UIView!
    
    @IBOutlet weak var outRangeView: UIView!
    
    @IBOutlet weak var addAddressBack: UIView!
    @IBOutlet weak var priceLb: UILabel!
    @IBOutlet weak var sendTimeLb: UILabel!
    @IBOutlet weak var receiveNameLb: UILabel!
    @IBOutlet weak var receivePhoneLb: UILabel!
    @IBOutlet weak var receiveAddressLb: UILabel!
    
    @IBOutlet weak var payBt: UIButton!
    @IBOutlet weak var moreStoreBt: UIButton!
    @IBOutlet weak var additionalTextView: PlaceholderTextView!
    
    var isFromShopCar = true
    var carIds: [String]?
    var priceText: String?
    var coordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        getStoreList(with: nil, lng: nil)
        self.getLocationResult = { (location, state, error) in
            if error == nil {
                print(location?.rgcData?.city ?? "未定位出城市")
                self.coordinate =  location?.location?.coordinate
                if self.cardDataList.count > 0 {
                    self.resetStoreView(with: self.cardDataList)
                }
            }
        }
        getLocation()
        self.priceLb.text = self.priceText
        getAddressList(showDefault: true)
        getCardList()
        self.getConfig()
        NotificationCenter.default.addObserver(self, selector: #selector(aliPaySuccess), name: NSNotification.Name.init("alipaysuccess"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func aliPaySuccess() {
        self.showOrderList(with: 0)
    }
    
    var addressList: Array<JSON> = []
    func getAddressList(showDefault: Bool) {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         ] as [String : Any]
        NetworkManager.request(api: .addressList, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.addressList = jsonObj["dataList"].arrayValue
                    self.setReceiver(with: true, receiver: nil)
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func setReceiver(with isDefault:Bool, receiver: JSON?) {
        var currentReceiver : JSON!
        if isDefault {
            if self.addressList.count == 0{
                self.currentAddress = nil
                return
            }else {
                
                let defaultAddressList = self.addressList.filter { (tempAddress) -> Bool in
                    return tempAddress["isdefault"].intValue == 1
                    }
                if defaultAddressList.count == 0 {
                    currentReceiver = self.addressList.first!
                }else{
                    currentReceiver = defaultAddressList.first!
                }
            }
        }else{
            currentReceiver = receiver!
        }
        
        receiveNameLb.text = currentReceiver["receivename"].stringValue
        receivePhoneLb.text = currentReceiver["receivephone"].stringValue
        receiveAddressLb.text = currentReceiver["fullAddress"].stringValue
        self.currentAddress = currentReceiver
        if self.orderType == 3 {
            self.getStoreList(with: self.currentAddress!["lat"].stringValue, lng: self.currentAddress!["lng"].stringValue)
        }
    }
    
    var nearestStoreId: String?
    var cardDataList: Array<JSON> = []
    func getStoreList(with lat: String?, lng: String?) {
        var parameter : [String: Any]? = nil
        var api : API = .storeList
        if lat != nil {
            parameter = ["lat" : lat!, "lng" : lng!]
            api = .getStoreWidthDistance
        }
        NetworkManager.request(api: api, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.cardDataList = jsonObj["dataList"].arrayValue
                    if lat != nil {
                        //外送，找最近的门店
                        let inRangeStore = self.cardDataList.filter({ (tempStore: JSON) -> Bool in
                            return tempStore["distributeScope"].intValue == 1
                          })
                        if inRangeStore.count == 0 {
                            self.nearestStoreId = nil
                            self.setReceiverState(state: 0)
                            return
                        }
                        let nearestStore = self.cardDataList.sorted(by: { (store1, store2) -> Bool in
                            return store1["storeRange"].floatValue < store2["storeRange"].floatValue
                        }).first!
                        self.nearestStoreId = nearestStore["storeid"].stringValue
                        self.setReceiverState(state: 2)
                    }else{
                        //自提或者店内
                        self.resetStoreView(with: self.cardDataList)
                    }
                    
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func resetStoreView(with storeList: [JSON]) {
        self.setStoreInfo(with: topStoreView, storeInfo: storeList[0])
        topStoreView.tag = 0
        self.selectStore(storeView: topStoreView)
        if storeList.count > 1 {
            self.setStoreInfo(with: bottomStoreView, storeInfo: storeList[1])
            bottomStoreView.tag = 1
            self.moreStoreBack.isHidden = storeList.count <= 2
        }else{
            bottomStoreView.removeFromSuperview()
        }
    }
    
    func getDistance(with lat: String, lng: String, successClosure: ((String) -> Void)?) {
        if self.coordinate == nil {
            successClosure?("未知")
            return
        }
        let json = [["lat1" : self.coordinate!.latitude, "lng1" : self.coordinate!.longitude, "lat2" : lat, "lng2" : lng]]
        let parameter = ["param" : try! json.json()]
        NetworkManager.request(api: .getDistance, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    let distance = jsonObj["dataList"].arrayValue.first!["distance"].floatValue / 1000.0
                    
                    successClosure?(String.init(format: "%.1fkm", distance))
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func setStoreInfo(with view: UIView, storeInfo: JSON) {
        let storeNameLb = view.viewWithTag(998) as! UILabel
        let addressLb = view.viewWithTag(997) as! UILabel
        storeNameLb.text = storeInfo["storename"].stringValue
        addressLb.text = storeInfo["storeaddress"].stringValue
        
        let distanceLb = view.viewWithTag(996) as! UILabel
        self.getDistance(with: storeInfo["lat"].stringValue, lng: storeInfo["lng"].stringValue) { (distance) in
            distanceLb.text = distance
        }
    }
    
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)
        let _ = self.addTitle(title: "确认订单", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
        for tempView in buySelectBack.subviews {
            let tempBt = tempView as! UIButton
            tempBt.onTap {
                self.buySelectBack.subviews.forEach({ (tempView) in
                    let selectBt = tempView as! UIButton
                    if selectBt == tempBt {
                        selectBt.isSelected = true
                    }else{
                        selectBt.isSelected = false
                    }
                })
                self.orderTypeSelect(type: tempBt.tag)
            }
        }
        (topStoreView.viewWithTag(999) as! UIImageView).image = #imageLiteral(resourceName: "mendianicon").withRenderingMode(.alwaysTemplate)
        (bottomStoreView.viewWithTag(999) as! UIImageView).image = #imageLiteral(resourceName: "mendianicon").withRenderingMode(.alwaysTemplate)
        self.selectStore(storeView: self.topStoreView)
        topStoreView.addTapGesture { (tap) in
            self.selectStore(storeView: self.topStoreView)
        }
        bottomStoreView.addTapGesture { (tap) in
            self.selectStore(storeView: self.bottomStoreView)
        }
        
        receiverView.shadow(offset: CGSize.zero, opacity: 0.2, radius: 20, cornerRadius: 6, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        receiverView.addTapGesture { (tap) in
            let pushedVC = AddressViewController.init(nibName: "AddressViewController", bundle: nil)
            pushedVC.selectAddressCosure = {
                (addressData: JSON) in
                self.addAddressBack.isHidden = true
                self.setReceiver(with: false, receiver: addressData)
                
            }
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        
        
        for tempView in payStateBack.subviews {
            if tempView.isKind(of: UILabel.self){
                continue
            }
            tempView.addTapGesture(handler: { (tap) in
                self.payStateViewClick(view: tap.view!)
            })
        }
        self.payStateViewClick(view: payStateBack.subviews[1])
        additionalTextBack.snp.makeConstraints { (make) in
            make.top.equalTo(selectStoreBack.snp.bottom)
        }
        outRangeView.isHidden = true
        selectReceiverBack.isHidden = true
        addAddressBack.isHidden = true
        addAddressBack.addTapGesture { (tap) in
            let pushedVC = AddAddressViewController.init(nibName: "AddAddressViewController", bundle: nil)
            pushedVC.addressListPage = self
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        //选择更多门店
        moreStoreBt.onTap {
            let pushedVC = StoreListViewController.init(nibName: "StoreListViewController", bundle: nil)
            pushedVC.selectStoreCosure = {
                (storeData, index) in
                if index == self.topStoreView.tag {
                    self.selectStore(storeView: self.topStoreView)
                }else if index == self.bottomStoreView.tag {
                    self.selectStore(storeView: self.bottomStoreView)
                }else {
                    self.setStoreInfo(with: self.topStoreView, storeInfo: storeData)
                    self.topStoreView.tag = index
                    self.selectStore(storeView: self.topStoreView)
                }
            }
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        //去支付
        payBt.onTap {
            if self.orderInfo != nil {
                self.pay(with: self.orderInfo!)
                return
            }
            self.createOrderByShopCar()
        }
        
        self.sendTimeLb.text = "请设置时间"
        var dateStr = ""
        selectTimeBt.onTap {
            DatePickerDialog.init(textColor: UIColor.black, buttonColor: UIColor.blue, font: UIFont.systemFont(ofSize: 15), locale: Locale.init(identifier: "zh_CN"), showCancelButton: true).show("选择日期", doneButtonTitle: "确定", cancelButtonTitle: "取消", defaultDate: Date(), minimumDate: Date(), maximumDate: nil, datePickerMode: .date, callback: { (selectDate) in
                if let dt = selectDate {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy.MM.dd"
                    dateStr = formatter.string(from: dt)
                    
                    let timeAlert = TimeAlertView.init(frame: CGRect.zero)
                    MainWindow.addSubview(timeAlert)
                    timeAlert.snp.makeConstraints({ (make) in
                        make.edges.equalToSuperview()
                    })
                    timeAlert.defaultTime = self.configInfo?["sendtimestage"][0]["showtext"].stringValue
                    timeAlert.timeArray = self.configInfo?["sendtimestage"].arrayValue
                    
                    timeAlert.selectClosure = {
                        (timeInfo) in
                        self.sendTimeLb.text = dateStr + " " + timeInfo["showtext"].stringValue
                        timeAlert.removeFromSuperview()
                    }
                }
            })
        }
    }
    var orderInfo: JSON?
    func createOrderByShopCar() {
        
        if self.sendTimeLb.text == "请设置时间" {
            self.view.makeToast("请设置时间")
            return
        }
        
        var carids = ""
        self.carIds!.forEach { (tempCarid) in
            carids += tempCarid + ","
        }
        carids.removeLast()
        var storeid = self.cardDataList[self.currentStoreIndex]["storeid"].stringValue
        if self.orderType == 3 {
            storeid = nearestStoreId!
            if currentAddress == nil {
                self.view.makeToast("请添加收货地址")
                return
            }
        }
        let sendTime = (sendTimeLb.text ?? "").replacingOccurrences(of: ["."], with: "-")
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        var parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "storeid" : storeid,
                         "carid" : carids,
                         "sendtype" : self.orderType,
                         "paytype" : self.paytype,
                         "sendinfo" : self.additionalTextView.text ?? "",
                         "sendtime" : sendTime
            
                         ] as [String : Any]
        if currentAddress != nil {
            parameter["addressid"] = currentAddress!["addressid"].stringValue
        }
        if paytype == 3 {
            parameter["cardno"] = currentCardNo!
        }
        var api : API = .createOrderByProduct
        if self.isFromShopCar {
            api = .createOrderByShopcar
        }else{
            parameter["vid"] = carids
            parameter["carid"] = nil
        }
        NetworkManager.request(api: api, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
//                    self.view.makeToast("创建订单成功")
                    
                    let obj = jsonObj["dataList"].type == .null ? jsonObj["dataObj"] : jsonObj["dataList"]
                    self.orderInfo = obj
                    self.pay(with: obj)
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func pay(with orderInfo: JSON) {
        let orderNo = orderInfo["orderno"].stringValue
        if self.paytype == 3 {
            self.payWithCard(with: orderNo)
        }else if self.paytype == 2 {
            let url = "https://www.coding88.com/pay.html?orderno=\(orderNo)&paytype=2"
            self.showPayWeb(with: url)
        }else{
            self.payWithAli(with: orderInfo)
        }
    }
    
    var currentCardNo: String?
    func payWithCard(with orderNo: String) {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "orderno" : orderNo,
                         "ordertype" : "1",
                         "cardno" : currentCardNo!
                         ] as [String : Any]
        NetworkManager.request(api: .consumeCard, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    MainWindow.makeToast("支付成功")
                    self.showOrderList(with: 0)
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
    
    var currentStoreIndex = 0
    func selectStore(storeView: UIView) {
        currentStoreIndex = storeView.tag
        if storeView == topStoreView {
            bottomStoreView.shadow(offset: CGSize.zero, opacity: 0, radius: 0, cornerRadius: 0, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
            let storeImage = bottomStoreView.viewWithTag(999) as! UIImageView
            storeImage.tintColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            let storeName = bottomStoreView.viewWithTag(998) as! UILabel
            storeName.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        }else{
            topStoreView.shadow(offset: CGSize.zero, opacity: 0, radius: 0, cornerRadius: 0, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
            let storeImage = topStoreView.viewWithTag(999) as! UIImageView
            storeImage.tintColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
            let storeName = topStoreView.viewWithTag(998) as! UILabel
            storeName.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        }
        storeView.shadow(offset: CGSize.zero, opacity: 0.2, radius: 20, cornerRadius: 6, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        storeView.superview?.bringSubview(toFront: storeView)
        let storeImage = storeView.viewWithTag(999) as! UIImageView
        storeImage.tintColor = #colorLiteral(red: 0.8156862745, green: 0.5803921569, blue: 0.2705882353, alpha: 1)
        let storeName = storeView.viewWithTag(998) as! UILabel
        storeName.textColor = #colorLiteral(red: 0.8156862745, green: 0.5803921569, blue: 0.2705882353, alpha: 1)
    }
    
    var currentAddress : JSON?
    var orderType = 1
    func orderTypeSelect(type: Int) {
        orderType = type + 1
        if type == 2 {
            if self.addressList.count == 0 {
                self.setReceiverState(state: 1)
            }else {
                self.getStoreList(with: self.currentAddress!["lat"].stringValue, lng: self.currentAddress!["lng"].stringValue)
            }
            self.selectStoreBack.isHidden = true
        }else{
            self.selectStoreBack.isHidden = false
            self.selectReceiverBack.isHidden = true
            self.outRangeView.isHidden = true
            self.setAddAddress(hidden: true)
            self.additionalTextBack.snp.remakeConstraints { (make) in
                make.top.equalTo(self.selectStoreBack.snp.bottom)
            }
        }
    }

    /*收货人视图状态 state：0：不在配送范围， 1：添加收货地址， 2：地址正常*/
    func setReceiverState(state: Int) {
        if state == 0 {
            //不在配送范围
            self.outRangeView.isHidden = false
            self.setAddAddress(hidden: true)
            self.selectReceiverBack.isHidden = false
        }else if state == 1 {
            //无地址可用
            self.outRangeView.isHidden = true
            self.setAddAddress(hidden: false)
            self.selectReceiverBack.isHidden = true
        }else{
            //有默认地址
            self.outRangeView.isHidden = true
            self.setAddAddress(hidden: false)
            self.selectReceiverBack.isHidden = false
        }
    }
    
    var paytype = 1
    func payStateViewClick(view: UIView) {
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
        paytype = selectView.tag
        self.payStateBack.subviews.forEach({ (subView) in
            if !subView.isKind(of: UILabel.self){
                let stateBt = subView.viewWithTag(999) as! UIButton
                if subView == selectView {
                    subView.shadow(offset: CGSize.zero, opacity: 0.2, radius: 20, cornerRadius: 6, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
                    stateBt.isSelected = true
                    subView.superview?.bringSubview(toFront: subView)
                }else{
                    subView.shadow(offset: CGSize.zero, opacity: 0, radius: 0, cornerRadius: 6, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0))
                    stateBt.isSelected = false
                }
            }
            
        })
    }
    
    func setAddAddress(hidden: Bool) {
        self.addAddressBack.isHidden = hidden
        if hidden {
            self.additionalTextBack.snp.remakeConstraints { (make) in
                make.top.equalTo(self.selectReceiverBack.snp.bottom)
            }
        }else{
            self.additionalTextBack.snp.remakeConstraints { (make) in
                make.top.equalTo(self.addAddressBack.snp.bottom)
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
