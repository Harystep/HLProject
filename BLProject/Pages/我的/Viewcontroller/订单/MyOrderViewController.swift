//
//  MyOrderViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/22.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class MyOrderViewController: BaseViewController {
    
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var topBtsBack: UIScrollView!
    var buttonList : Array<UIButton> = []
    let topStateView = UIView.init()
    @IBOutlet weak var mainTableView: UITableView!
    var orderType: Int = 0{
        didSet{
            currentType = orderType
        }
    }
    var currentType: Int = 0
    var dataSourceDic = Dictionary<Int, Array<JSON>>.init()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.currentType != 0 {
            self.getOrderList(with: 0)
        }
        self.getOrderList(with: self.currentType)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        self.clickTopBtAction(sender: self.topBtsBack.viewWithTag(1000 + orderType) as! UIButton)
//        getOrderList(with: orderType)
    }
    
    func getOrderList(with type: Int) {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        var parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         ] as [String : Any]
        if type != 0 {
            parameter["orderstatus"] = type
        }
        NetworkManager.request(api: .getOrderList, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.dataSourceDic[type] = jsonObj["dataList"].arrayValue
                    if type == self.currentType {
                        self.mainTableView.reloadData()
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
        let _ = self.addTitle(title: "我的订单", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
        addTopButtons()
        clickTopBtAction(sender: topBtsBack.viewWithTag(1000) as! UIButton)
        
        mainTableView.estimatedRowHeight = 50
        mainTableView.tableFooterView = UIView.init()
        mainTableView.register(UINib.init(nibName: "OrderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderTableViewCell")
        mainTableView.numberOfRows { (section) -> Int in
            return self.dataSourceDic[self.currentType]?.count ?? 0
            }.cellForRow { (indexPath) -> UITableViewCell in
                let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "OrderTableViewCell", for: indexPath) as! OrderTableViewCell
                let data = self.dataSourceDic[self.currentType]![indexPath.row]
                if data["sendtype"].intValue == 1{
                    cell.topLb.text = "门店自提>\(data["storename"].stringValue)"
                }else if data["sendtype"].intValue == 2{
                    cell.topLb.text = "打包带走>\(data["storename"].stringValue)"
                }else if data["sendtype"].intValue == 3{
                    cell.topLb.text = "外送>\(data["storename"].stringValue)"
                }
                cell.moneyLb.text = data["orderprice"].stringValue
                let time = data["tradetime"].stringValue.replacingOccurrences(of: ["-"], with: ".")
                cell.timeLb.text = time
                var count = data["detailList"].arrayValue.count
                if count > 3 {
                    count = 3
                }
                let imageList = [cell.firstImage, cell.secondImage, cell.thirdImage]
                for i in 0..<count {
                    let tempDetail = data["detailList"][i]
                    imageList[i]?.kf.setImage(with: URL.init(string: tempDetail["imagesrc"].stringValue))
                }
                cell.setCurrentCell(state: OrderCellState(rawValue: data["orderstatus"].intValue)!)
                cell.bottomRight.onTap {
                    self.cellBottomBtAction(state: cell.state!, index: 2, data: data)
                }
                cell.bottomCenter.onTap {
                    self.cellBottomBtAction(state: cell.state!, index: 1, data: data)
                }
                cell.bottomLeft.onTap {
                    self.cellBottomBtAction(state: cell.state!, index: 0, data: data)
                }
                return cell
            }.didSelectRowAt { (indexPath) in
                let data = self.dataSourceDic[self.currentType]![indexPath.row]
                self.showOrderDetail(state: OrderCellState(rawValue: data["orderstatus"].intValue)!, data: data)
        }
        
    }
    
    
    
    func showOrderDetail(state: OrderCellState, data: JSON) {
        let pushedVC = OrderDetailViewController.init(nibName: "OrderDetailViewController", bundle: nil)
        pushedVC.detailData = data
        pushedVC.state = state
        self.navigationController?.pushViewController(pushedVC, animated: true)
    }
    
    func cellBottomBtAction(state: OrderCellState, index: Int, data: JSON) {
        let switchNum = index * 10 + state.rawValue
        if switchNum == 21 {
            self.pay(with: data)
        }else if switchNum == 24 {
            let pushedVC = MealCodeViewController.init(nibName: "MealCodeViewController", bundle: nil)
            pushedVC.orderData = data
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }else if switchNum == 15 {
            self.showOrderDetail(state: state, data: data)
//            let pushedVC = AddNeedHelpOrderViewController.init(nibName: "AddNeedHelpOrderViewController", bundle: nil)
//            pushedVC.orderData = data
//            self.navigationController?.pushViewController(pushedVC, animated: true)
        }else if switchNum == 25 {
            let pushedVC = AddCommentViewController.init(nibName: "AddCommentViewController", bundle: nil)
            pushedVC.orderData = data
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }else {
            self.showOrderDetail(state: state, data: data)
        }
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
    
    func addTopButtons() {
        let names = ["全部", "待付款", "待发货", "配送中", "待提货", "待评价"]
        var lastView: UIView?
        for (i,name) in names.enumerated() {
            let tempBt = UIButton.init()
            tempBt.setTitle(name, for: .normal)
            tempBt.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            tempBt.setTitleColor(#colorLiteral(red: 0.831372549, green: 0.6862745098, blue: 0.4196078431, alpha: 1), for: .selected)
            tempBt.setTitleColor(#colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1), for: .normal)
            topBtsBack.addSubview(tempBt)
            tempBt.snp.makeConstraints { (make) in
                if i == 0 {
                    make.leading.equalToSuperview().offset(19)
                }else{
                    make.leading.equalTo(lastView!.snp.trailing).offset(23)
                }
                make.top.equalToSuperview().offset(17)
                make.bottom.equalToSuperview().offset(7)
                make.height.equalTo(22)
                if i == names.count - 1 {
                    make.trailing.equalToSuperview().offset(-19)
                }
            }
            lastView = tempBt
            buttonList.append(tempBt)
            tempBt.onTap {
                self.clickTopBtAction(sender: tempBt)
            }
            tempBt.tag = 1000 + i
        }
        topBtsBack.addSubview(topStateView)
        topStateView.snp.makeConstraints { (make) in
            make.leading.top.equalToSuperview()
            make.width.height.equalTo(0)
        }
        topStateView.backgroundColor = #colorLiteral(red: 0.8156862745, green: 0.5803921569, blue: 0.2705882353, alpha: 1)
    }
    
    func clickTopBtAction(sender: UIButton) {
        for tempBt in buttonList {
            if tempBt == sender {
                tempBt.isSelected = true
                topStateView.snp.remakeConstraints { (make) in
                    make.centerX.equalTo(tempBt)
                    make.top.equalTo(tempBt.snp.bottom).offset(7)
                    make.width.equalTo(tempBt).offset(-8)
                    make.height.equalTo(1)
                }
            }else{
                tempBt.isSelected = false
            }
        }
        self.currentType = sender.tag - 1000
        if self.dataSourceDic[self.currentType] == nil {
            self.getOrderList(with: self.currentType)
        }else{
            self.mainTableView.reloadData()
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
