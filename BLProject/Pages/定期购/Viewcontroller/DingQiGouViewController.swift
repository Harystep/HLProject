//
//  DingQiGouViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/14.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit
import FSCalendar

class DingQiGouViewController: BaseViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {

    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var changeMonthBtBack: UIView!
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var noListStateView: UIView!
    @IBOutlet weak var currentMonthLb: UILabel!
    @IBOutlet weak var nextMouthBt: UIButton!
    @IBOutlet weak var lastMoutnBt: UIButton!
    
    @IBOutlet weak var cancleBt: UIButton!
    @IBOutlet weak var productListBack: UIView!
    @IBOutlet weak var productList: UITableView!
    @IBOutlet weak var sendTimeLb: UILabel!
    
    var regularListData: JSON?
    
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    var selectDates: [Date?] = []
    var clickDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.userInfo != nil {
            getMyOrderList()
        }
    }
    
    func getMyOrderList() {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         ] as [String : Any]
        NetworkManager.request(api: .getRegularOrder, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.regularListData = jsonObj["dataObj"]
                    self.resetCalendar(with: self.regularListData!)
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func resetCalendar(with data: JSON) {
        var dateArray = Array<String>.init()
        for (key, value) in data {
            for tempOrder in value.arrayValue {
                if tempOrder["status"].intValue == 4 {
                    continue
                }
                let dateStr = tempOrder["sendtime"].stringValue
                if !dateArray.contains(dateStr){
                    dateArray.append(dateStr)
                }
            }
        }
//        for tempDate in selectDates {
//            self.calendar.deselect(tempDate!)
//        }
        selectDates.removeAll()
        
        for tempDateStr in dateArray {
            let tempDate = self.formatter.date(from: tempDateStr)
//            self.calendar.select(tempDate, scrollToDate: false)
//            if self.gregorian.isDateInToday(tempDate!){
//                self.calendar.appearance.titleTodayColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
//            }
            selectDates.append(tempDate)
        }
        self.calendar.reloadData()
    }
    
    func setUpSubviews() {
        self.view.bringSubview(toFront: noListStateView)
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addTitle(title: "我的定期购", naviBackView: naviBack)
        let rightBt = self.addRightBt(title: "定期购订单", naviBackView: naviBack)
        rightBt.onTap {
            
            let pushedVC = MyDQGViewController.init(nibName: "MyDQGViewController", bundle: nil)
            pushedVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        self.addCustomCorner(with: changeMonthBtBack, radius: 14)
        setupCalendar()
        setProductList()
    }
    
    var currentProductIndex: Int?
    var currentMainOrderKey: String?
//    var currentProductData: JSON?
    func setProductList() {
        productList.separatorStyle = .none
        productList.register(UINib.init(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
        productList.numberOfRows { (section) -> Int in
            if self.currentProductIndex == nil {
                return 0
            }
            let rowNum = self.regularListData![self.currentMainOrderKey!][self.currentProductIndex!]["userOrderList"].arrayValue.count
            if rowNum == 0 {
                self.noListStateView.isHidden = false
            }
            return rowNum
            }.cellForRow { (indexPath) -> UITableViewCell in
                let orderData = self.regularListData![self.currentMainOrderKey!][self.currentProductIndex!]["userOrderList"].arrayValue[indexPath.row]
                let cell = self.productList.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
                cell.bottomPriceBack.isHidden = true
                cell.selectBt.isHidden = false
                cell.mainImage.kf.setImage(with: URL.init(string: orderData["imghref"].string ?? ""))
                cell.titleLb.text = orderData["vegetablename"].string ?? ""
                cell.subTitleLb.text = orderData["content"].string ?? ""
                cell.selectBt.isSelected = orderData["issend"].intValue == 1
                cell.selectBt.onTap {
                    if !cell.selectBt.isSelected {
                        self.addSubOrder(with: self.regularListData![self.currentMainOrderKey!][self.currentProductIndex!]["suborderid"].stringValue, vid: orderData["vid"].stringValue)
                    }
                }
                return cell
        }
    }
    
    func setupCalendar() {
        calendar.register(CustomCalendarCell.self, forCellReuseIdentifier: "CustomCalendarCell")
        calendar.appearance.titleTodayColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        calendar.dataSource = self
        calendar.delegate = self
        calendar.allowsMultipleSelection = false
        calendar.clipsToBounds = true
        currentMonthLb.text = getCurrentMounth(with: Date.init())
        nextMouthBt.onTap {
           let nextDate = self.gregorian.date(byAdding: .month, value: 1, to: self.calendar.currentPage)
            self.calendar.setCurrentPage(nextDate!, animated: true)
        }
        lastMoutnBt.onTap {
            let lastDate = self.gregorian.date(byAdding: .month, value: -1, to: self.calendar.currentPage)
            self.calendar.setCurrentPage(lastDate!, animated: true)
        }
    }
    
    func getCurrentMounth(with date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: date)
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.makeConstraints { (make) in
            make.height.equalTo(bounds.height)
        }
        self.view.layoutSubviews()
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        calendar.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "CustomCalendarCell", for: date, at: position) as! CustomCalendarCell
        cell.selectLayer!.isHidden = true
        return cell
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        let customCell = cell as! CustomCalendarCell
        if self.gregorian.isDateInToday(date)  {
            customCell.selectLayer!.isHidden = true
            return
        }
        for tempDate in selectDates {
            if self.gregorian.isDate(date, inSameDayAs: tempDate!) {
                if selectedDate != nil && self.gregorian.isDate(date, inSameDayAs: selectedDate!) {
                    customCell.selectLayer!.isHidden = true
                }else{
                    customCell.selectLayer!.isHidden = false
                }
                customCell.titleLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                return
            }
        }
        customCell.selectLayer!.isHidden = true
    }
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        if self.gregorian.isDateInToday(date) {
            return "今"
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition)   -> Bool {
        return monthPosition == .current
    }
    
    var selectedDate: Date?
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        for tempDate in selectDates {
            if self.gregorian.isDate(date, inSameDayAs: tempDate!) {
                self.noListStateView.isHidden = true
                for (key, value) in self.regularListData! {
                    for (i,tempOrder) in value.arrayValue.enumerated() {
                        let dateStr = tempOrder["sendtime"].stringValue
                        if self.formatter.string(from: date) == dateStr {
                            self.currentProductIndex = i
                            self.currentMainOrderKey = key
                            self.sendTimeLb.text = "\(tempOrder["beginstagetime"].stringValue)-\(tempOrder["endstagetime"].stringValue)"
                            self.cancleBt.onTap {
                                self.cancleSubOrder(with: tempOrder["suborderno"].stringValue, sendTime: dateStr)
                            }
                        }
                    }
                }
                productList.reloadData()
                calendar.reloadData()
                return
            }
        }
        self.noListStateView.isHidden = false
        calendar.reloadData()
    }
    
//    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
//
//        for tempDate in selectDates {
//            if self.gregorian.isDate(date, inSameDayAs: tempDate!) {
//                self.noListStateView.isHidden = true
//                //        var dateArray = Array<JSON>.init()
//                for (key, value) in self.regularListData! {
//                    for (i,tempOrder) in value.arrayValue.enumerated() {
//                        let dateStr = tempOrder["sendtime"].stringValue
//                        if self.formatter.string(from: date) == dateStr {
//                            //                    dateArray += tempOrder["userOrderList"].arrayValue
//                            self.currentProductIndex = i
//                            self.currentMainOrderKey = key
//                            self.sendTimeLb.text = "\(tempOrder["beginstagetime"].stringValue)-\(tempOrder["endstagetime"].stringValue)"
//                            self.cancleBt.onTap {
//                                self.cancleSubOrder(with: tempOrder["suborderno"].stringValue, sendTime: dateStr)
//                            }
//                        }
//                    }
//                }
//                productList.reloadData()
//                return false
//            }
//        }
//        self.noListStateView.isHidden = false
//        return false
//    }
    
    func addSubOrder(with orderNo: String, vid: String) {
        let parameter = ["suborderid" : orderNo,
                         "vid" : vid
            ] as [String : Any]
        NetworkManager.request(api: .addSuborder, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    for i in 0..<self.regularListData![self.currentMainOrderKey!][self.currentProductIndex!]["userOrderList"].arrayValue.count {
                        if self.regularListData![self.currentMainOrderKey!][self.currentProductIndex!]["userOrderList"][i]["vid"].stringValue == vid {
                            self.regularListData![self.currentMainOrderKey!][self.currentProductIndex!]["userOrderList"][i]["issend"] = 1
                        }else{
                            self.regularListData![self.currentMainOrderKey!][self.currentProductIndex!]["userOrderList"][i]["issend"] = 0
                        }
                    }
                    self.productList.reloadData()
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func cancleSubOrder(with orderNo: String, sendTime: String) {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "suborderno" : orderNo,
                         "sendtime" : sendTime
                         ] as [String : Any]
        NetworkManager.request(api: .cancelRegularOrder, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.view.makeToast(jsonObj["msg"].string ?? "订单取消成功")
                    self.getMyOrderList()
                    self.noListStateView.isHidden = false
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        currentMonthLb.text = getCurrentMounth(with: calendar.currentPage)
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
