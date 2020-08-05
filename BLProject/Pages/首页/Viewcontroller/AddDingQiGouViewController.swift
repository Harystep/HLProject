//
//  AddDingQiGouViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/21.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit
import WebKit
import DatePickerDialog

class AddDingQiGouViewController: BaseViewController {
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var priceLb: UILabel!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var topNumLb: UILabel!
    let webView = WKWebView.init()
    
    @IBOutlet weak var topBannerBack: UIView!
    @IBOutlet weak var mainScroll: UIScrollView!
    
    @IBOutlet weak var selectDateBt: UIButton!
    @IBOutlet weak var startDateLb: UILabel!
    @IBOutlet weak var webBackView: UIView!
    @IBOutlet weak var buyNowBt: UIButton!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var descLb: UILabel!
    
    @IBOutlet weak var firstBack: UIView!
    @IBOutlet weak var secondBack: UIView!
    @IBOutlet weak var thirdBack: UIView!
    @IBOutlet weak var fourthBack: UIView!
    @IBOutlet weak var fifthBack: UIView!
    var regularData: JSON!
    var sendPrice: Float?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        getData()
    }
    
    func getData() {
        NetworkManager.request(api: .getRegularDetail, parameters: nil, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.regularData = jsonObj["dataList"]
                    self.resetSubViews(with: self.regularData)
                    
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    var customDayid : String?
    func resetSubViews(with data: JSON) {
        let regularInfo = data["regularinfo"]
        let loopList = regularInfo["imagelist"].arrayValue
        var imageList = Array<String>.init()
        for tempLoop in loopList {
            imageList.append(tempLoop["href"].stringValue)
        }
        let topLoopView = SDCycleScrollView.init(frame: topBannerBack.bounds, imageURLStringsGroup: imageList)
        topBannerBack.insertSubview(topLoopView!, at: 0)
        topLoopView?.showPageControl = false
        self.topNumLb.text = "\(1)/\(imageList.count)"
        topLoopView?.itemDidScrollOperationBlock = {
            currentIndex in
            self.topNumLb.text = "\(currentIndex + 1)/\(imageList.count)"
        }
        
        nameLb.text = regularInfo["regularname"].stringValue
        descLb.text = regularInfo["content"].stringValue
        
        webView.loadHTMLString(regularInfo["regulardetails"].stringValue, baseURL: nil)
        
        
        var utilList = Array<String>.init()
        for tempUtil in data["util"].arrayValue {
            utilList.append(tempUtil["val"].stringValue)
        }
        
        
        var sendDayList = Array<String>.init()
        for tempday in data["sendday"].arrayValue {
            let sendDayStr = tempday["val"].stringValue
            if sendDayStr == "自选" {
                customDayid = tempday["key"].stringValue
            }else{
                sendDayList.append(sendDayStr)
            }
        }
        
        var sendCountList = Array<String>.init()
        for tempcount in data["sendcount"].arrayValue {
            sendCountList.append(tempcount["val"].stringValue)
        }
        
        var sendTimeList = Array<String>.init()
        for temptime in data["sendtimestage"].arrayValue {
            sendTimeList.append(temptime["showtext"].stringValue)
        }
        
        waterLabelsView1.labelNames = utilList
        waterLabelsView2.labelNames = sendDayList
        waterLabelsView3.labelNames = ["一", "二", "三", "四", "五", "六", "日"]
        waterLabelsView4.labelNames = sendCountList
        waterLabelsView5.labelNames = sendTimeList
        
    }
    
    func buyAction() {
        if waterLabelsView1.selectIndex == nil {
            self.view.makeToast("请选择燕窝含量")
            return
        }
        if waterLabelsView2.selectIndex == nil && waterLabelsView3.selectIndexs.count == 0 {
            self.view.makeToast("请选择配送模式")
            return
        }
        
        if waterLabelsView4.selectIndex == nil {
            self.view.makeToast("请选择配送次数")
            return
        }
        if waterLabelsView5.selectIndex == nil {
            self.view.makeToast("请选择送达时段")
            return
        }
        if !self.judgeLogin() {
            return
        }
        let utilKey = self.regularData["util"].arrayValue[waterLabelsView1.selectIndex!]["key"].stringValue
        let countKey = self.regularData["sendcount"].arrayValue[waterLabelsView4.selectIndex!]["key"].stringValue
        let timeKey = self.regularData["sendtimestage"].arrayValue[waterLabelsView5.selectIndex!]["id"].stringValue
        var sendDayKey = customDayid
        if waterLabelsView2.selectIndex != nil {
            sendDayKey = self.regularData["sendday"].arrayValue[waterLabelsView2.selectIndex!]["key"].stringValue
        }

        var sendWeek = ""
        waterLabelsView3.selectIndexs.forEach { (tempIndex) in
            sendWeek += "\(tempIndex + 1),"
        }

        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = [
            "userid" : userId ?? "",
            "token" : token ?? "",
            "rid" : self.regularData["regularinfo"]["rid"].stringValue,
            "addressid" : "",
            "orderprice" : self.priceLb.text,
            "sendstarttime" : startDateLb.text,
            "unit" : utilKey,
            "timestage" : timeKey,
            "sendcount" : countKey,
            "sendday" : sendDayKey,
            "sendweek": sendWeek
        ] as! [String : String]
        let pushedVC = ConfirmDQGViewController.init(nibName: "ConfirmDQGViewController", bundle: nil)
        pushedVC.parameter = parameter
        pushedVC.sendPrice = self.sendPrice
        self.navigationController?.pushViewController(pushedVC, animated: true)
    }
    
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)
        let _ = self.addTitle(title: "定期购", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
        webBackView.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(ScreenWidth)
            make.height.equalTo(ScreenHeight)
        }
        buyNowBt.onTap {
            self.buyAction()
        }
        mainScroll.didScroll { (scroll) in
            if scroll.contentSize.height - scroll.bounds.size.height == scroll.contentOffset.y {
                self.webView.scrollView.isScrollEnabled = true
            }else{
                self.webView.scrollView.isScrollEnabled = false
            }
        }
        addSubViews()
        let tomorrowDate = Date().addingDays(1)
        let tomorrowStr = tomorrowDate?.dateString(format: "yyyy-MM-dd", locale: "zh_CN")
        startDateLb.text = tomorrowStr!
        selectDateBt.onTap {
            DatePickerDialog.init(textColor: UIColor.black, buttonColor: UIColor.blue, font: UIFont.systemFont(ofSize: 15), locale: Locale.init(identifier: "zh_CN"), showCancelButton: true).show("选择日期", doneButtonTitle: "确定", cancelButtonTitle: "取消", defaultDate: tomorrowDate!, minimumDate: tomorrowDate!, maximumDate: nil, datePickerMode: .date, callback: { (selectDate) in
                if let dt = selectDate {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    self.startDateLb.text = formatter.string(from: dt)
                }
            })
        }
    }
    
    let waterLabelsView1 = WaterFlowLabelsView.init(frame: CGRect.zero)
    let waterLabelsView2 = WaterFlowLabelsView.init(frame: CGRect.zero)
    let waterLabelsView3 = WaterFlowLabelsView.init(frame: CGRect.zero)
    let waterLabelsView4 = WaterFlowLabelsView.init(frame: CGRect.zero)
    let waterLabelsView5 = WaterFlowLabelsView.init(frame: CGRect.zero)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        waterLabelsView1.labelNames = ["9g", "5g"]
//        waterLabelsView2.labelNames = ["每送", "两日送", "三日送"]
//        waterLabelsView3.labelNames = ["一", "二", "三", "四", "五", "六", "日"]
//        waterLabelsView4.labelNames = ["80", "60", "90"]
//        waterLabelsView5.labelNames = ["05:00-9:00", "09:00-12:00", "13:00-15:00", "15:00-17:00"]
//        getData()
    }
    
    func refreshPrice() {
        if waterLabelsView1.selectIndex == nil {
            return
        }
        if waterLabelsView4.selectIndex == nil {
            return
        }
        let utilKey = self.regularData["util"].arrayValue[waterLabelsView1.selectIndex!]["key"].stringValue
        let countKey = self.regularData["sendcount"].arrayValue[waterLabelsView4.selectIndex!]["key"].stringValue
        var price = self.regularData["priceinfo"]["\(utilKey)###\(countKey)"].floatValue
        if price <= self.regularData["sendinfo"]["costPrice"].floatValue {
            let newSendPrice = self.regularData["sendinfo"]["sendPrice"].floatValue
            price += newSendPrice
            self.sendPrice = newSendPrice
        }
        self.priceLb.text = "\(price)"
    }
    
    func addSubViews() {
        
        waterLabelsView1.clickSearchLabelBlock = {[weak self] (data: String) in
            self?.refreshPrice()
        }
        waterLabelsView1.minWidth = 90
        
        firstBack.addSubview(waterLabelsView1)
        waterLabelsView1.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        waterLabelsView2.clickSearchLabelBlock = {[weak self] (data: String) in
            self?.waterLabelsView3.cleanSelectState()
        }
        waterLabelsView2.minWidth = 90
        
        secondBack.addSubview(waterLabelsView2)
        waterLabelsView2.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        waterLabelsView3.clickSearchLabelBlock = {[weak self] (data: String) in
            self?.waterLabelsView2.cleanSelectState()
        }
        
        thirdBack.addSubview(waterLabelsView3)
        waterLabelsView3.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        waterLabelsView3.multiSelect = true
        
        waterLabelsView4.clickSearchLabelBlock = {[weak self] (data: String) in
            self?.refreshPrice()
        }
        waterLabelsView4.minWidth = 90
        
        fourthBack.addSubview(waterLabelsView4)
        waterLabelsView4.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        waterLabelsView5.clickSearchLabelBlock = {[weak self] (data: String) in
            
        }
        waterLabelsView5.minWidth = 90
        
        fifthBack.addSubview(waterLabelsView5)
        waterLabelsView5.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
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
