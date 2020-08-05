//
//  OrderDetailViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/23.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class OrderDetailViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var ZTPhoneAddressLb: UILabel!
    @IBOutlet weak var ZTTimeLb: UILabel!
    @IBOutlet weak var receivePhoneLb: UILabel!
    @IBOutlet weak var receiveAddressLb: UILabel!
    @IBOutlet weak var receiveNameLb: UILabel!
    var state : OrderCellState?
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    var dataSource = Array<JSON>.init()
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var topZTBack: UIView!
    @IBOutlet weak var topReceiverBack: UIView!
    
    @IBOutlet weak var topStateLb: UILabel!
    @IBOutlet weak var topStateImage: UIImageView!
    
    @IBOutlet weak var bottomLeftBt: UIButton!
    @IBOutlet weak var bottomRightBt: UIButton!
    
    @IBOutlet weak var footerBack: UIView!
    @IBOutlet weak var bakcBt: UIButton!
    
    @IBOutlet weak var bottomView1: UIView!
    @IBOutlet weak var bottomView2: UIView!
    @IBOutlet weak var bottomView3: UIView!
    @IBOutlet weak var bottomView4: UIView!
    @IBOutlet weak var bottomView5: UIView!
    @IBOutlet weak var bottomView6: UIView!
    
    
    var detailData: JSON?
    var newDetailData: JSON?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        setupTableView()
        
        let names = ["待付款", "待发货", "配送中", "待提货", "待评价", "已取消", "已完成"]
        let images = [#imageLiteral(resourceName: "daifu"), #imageLiteral(resourceName: "daifahuo"), #imageLiteral(resourceName: "peisong"), #imageLiteral(resourceName: "daiti"), #imageLiteral(resourceName: "daiping"), #imageLiteral(resourceName: "quxiao"),#imageLiteral(resourceName: "quxiao")]
        topStateLb.text = names[state!.rawValue - 1]
        topStateImage.image = images[state!.rawValue - 1]
        if state == .waitReceive {
            topZTBack.isHidden = false
            topReceiverBack.isHidden = true
        }else{
            topZTBack.isHidden = true
            topReceiverBack.isHidden = false
        }
        if state == .waitPay {
            bottomLeftBt.setTitle("取消", for: .normal)
            bottomLeftBt.onTap {
                self.cancleOrder(with: self.detailData!["orderno"].stringValue)
            }
            bottomRightBt.setTitle("付款", for: .normal)
            bottomRightBt.onTap {
                self.pay(with: self.detailData!)
            }
        }
        if state == .canceled || state == .finish {
            bottomLeftBt.setTitle("删除订单", for: .normal)
            bottomRightBt.removeFromSuperview()
            bottomLeftBt.onTap {
                self.deleteOrder(with: self.detailData!["orderno"].stringValue)
            }
        }
        if state == .waitReceive || state == .waitSend || state == .onTheWay {
            bottomViewHeight.constant = 0
            bottomView.isHidden = true
        }
        if state == .waitComment {
            bottomLeftBt.setTitle("删除订单", for: .normal)
            bottomLeftBt.onTap {
                self.deleteOrder(with: self.detailData!["orderno"].stringValue)
            }
            bottomRightBt.setTitle("评价", for: .normal)
            bottomRightBt.onTap {
                let pushedVC = AddCommentViewController.init(nibName: "AddCommentViewController", bundle: nil)
                pushedVC.orderData = self.newDetailData
                self.navigationController?.pushViewController(pushedVC, animated: true)
            }
        }
        getOrderDetail(with: detailData!["orderno"].stringValue)
    }
    
    func pay(with orderInfo: JSON) {
        let paytype = orderInfo["paytype"].intValue
        let orderNo = orderInfo["orderno"].stringValue
        if paytype == 3 {
            //self.payWithCard(with: orderNo)
        }else if paytype == 2 {
            let url = "https://www.coding88.com/pay.html?orderno=\(orderNo)&paytype=2"
            self.showPayWeb(with: url)
        }else{
            self.payWithAli(with: orderInfo)
        }
    }
    
    func deleteOrder(with orderNo: String) {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "orderno" : orderNo
            ] as [String : Any]
        NetworkManager.request(api: .cancleOrder, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    MainWindow.makeToast(jsonObj["msg"].string ?? "订单删除成功")
                    self.popBack()
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func cancleOrder(with orderNo: String) {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "orderno" : orderNo
            ] as [String : Any]
        NetworkManager.request(api: .cancleOrder, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    MainWindow.makeToast(jsonObj["msg"].string ?? "订单取消成功")
                    self.popBack()
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func getOrderDetail(with orderID: String) {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "orderno" : orderID
                         ] as [String : Any]
        NetworkManager.request(api: .getOrderDetail, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.newDetailData = jsonObj["dataObj"]
                    self.dataSource = self.newDetailData!["detailList"].arrayValue
                    self.mainTableView.reloadData()
                    self.resetSubviews()
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func resetSubviews() {
        let detail = self.newDetailData!
        var sendStr = "配送上门"
        if detail["sendtype"].intValue == 3 {
            self.topReceiverBack.isHidden = false
            self.topZTBack.isHidden = true
            self.receiveNameLb.text = detail["receiveuser"].stringValue
            self.receivePhoneLb.text = detail["receivephone"].stringValue
            self.receiveAddressLb.text = detail["receiveaddress"].stringValue
        }else{
            if detail["sendtype"].intValue == 2 {
                sendStr = "打包带走"
            }else {
                sendStr = "店内用餐"
            }
            self.topReceiverBack.isHidden = true
            self.topZTBack.isHidden = false
            self.ZTTimeLb.text = detail["sendtime"].stringValue
            self.ZTPhoneAddressLb.text = "\(detail["storephone"].stringValue)\n\(detail["storeaddress"].stringValue)"
        }
        setText(with: bottomView1, str1: "配送方式", str2: sendStr)
        if state == .waitReceive{
            setText(with: bottomView2, str1: "订单号", str2: detail["orderno"].stringValue)
            setText(with: bottomView3, str1: "下单时间", str2: detail["tradetime"].stringValue)
            setText(with: bottomView4, str1: "订单金额", str2: "￥" + detail["orderprice"].stringValue)
            setText(with: bottomView6, str1: "实付金额", str2: "￥" + detail["saleprice"].stringValue)
            bottomView5.removeFromSuperview()
        }else if state == .canceled{
            setText(with: bottomView2, str1: "订单号", str2: detail["orderno"].stringValue)
            setText(with: bottomView3, str1: "下单时间", str2: detail["tradetime"].stringValue)
            setText(with: bottomView4, str1: "订单金额", str2: "￥" + detail["orderprice"].stringValue)
            setText(with: bottomView5, str1: "订单金额", str2: "￥" + detail["orderprice"].stringValue)
            bottomView6.removeFromSuperview()
        }else{
            setText(with: bottomView2, str1: "配送时间", str2: detail["sendtime"].stringValue)
            setText(with: bottomView3, str1: "订单号", str2: detail["orderno"].stringValue)
            setText(with: bottomView4, str1: "下单时间", str2: detail["tradetime"].stringValue)
            setText(with: bottomView5, str1: "订单金额", str2: "￥" + detail["orderprice"].stringValue)
            setText(with: bottomView6, str1: "实付金额", str2: "￥" + detail["saleprice"].stringValue)
        }
        
    }
    
    func setText(with tempView: UIView, str1: String, str2: String) {
        (tempView.subviews[0] as! UILabel).text = str1
        (tempView.subviews[1] as! UILabel).text = str2
    }
    
    func setUpSubviews() {
        self.setNaviHeight(with: naviBack)
        let titleLb = self.addTitle(title: "订单详情", naviBackView: naviBack)
        titleLb.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.addCustomCorner(with: mainTableView, radius: 14)
        bakcBt.setImage(#imageLiteral(resourceName: "fan hui").withRenderingMode(.alwaysTemplate), for: .normal)
        bakcBt.tintColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        bakcBt.onTap {
            self.popBack()
        }
    }
    
    func setupTableView() {
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.register(UINib.init(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
        mainTableView.estimatedRowHeight = 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.dataSource[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
        cell.addToCarBt.isHidden = true
        if state == .waitPay {
            
        }
        if state == .waitComment {
            cell.addToCarBt.isHidden = true
            cell.needHelpBt.isHidden = false
            cell.needHelpBt.onTap {
                let pushedVC = AddNeedHelpOrderViewController.init(nibName: "AddNeedHelpOrderViewController", bundle: nil)
                pushedVC.orderData = data
                self.navigationController?.pushViewController(pushedVC, animated: true)
            }
        }
        
        cell.mainImage.kf.setImage(with: URL.init(string: data["imagesrc"].stringValue))
        cell.titleLb.text = data["vegetablename"].stringValue
        cell.subTitleLb.text = data["producecontent"].stringValue
        cell.priceLb.text = data["saleprice"].stringValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
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
