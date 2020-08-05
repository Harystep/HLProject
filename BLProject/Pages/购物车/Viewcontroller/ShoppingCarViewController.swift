//
//  ShoppingCarViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/14.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class ShoppingCarViewController: BaseViewController {

    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    
    @IBOutlet weak var priceLb: UILabel!
    @IBOutlet weak var selectAllBt: UIButton!
    @IBOutlet weak var confirmBt: UIButton!
    let tableHeader = ShoppingCarHeaderView.init(frame: CGRect.zero)
    var carListData: JSON?
    
    var titleLb: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        getShopCarList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mainTableView.mj_header.beginRefreshing()
    }
    
    func resetListView() {
        self.mainTableView.reloadData()
        var count = 0
        for enableProduct in self.carListData?["dataObj"]["enableList"].array ?? [] {
            count += enableProduct["productcount"].intValue
        }
//        titleLb?.text = "购物车" + (count == 0 ? "" : "\(count)")
        titleLb?.text = "购物车(\(count))"
        self.refreshPrice()
    }
    
    func getShopCarList() {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
            ] as [String : Any]
        NetworkManager.request(api: .getShopCarByUser, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            self.mainTableView.mj_header.endRefreshing()
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.carListData = jsonObj
                    self.resetListView()
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
        self.addCustomCorner(with: mainTableView.superview!, radius: 14)
        titleLb = self.addTitle(title: "购物车(0)", naviBackView: naviBack)
        let rightBt = self.addRightBt(title: "删除", naviBackView: naviBack)
        rightBt.onTap {
            var disableIds = Array<String>.init()
            self.carListData?["dataObj"]["disableList"].arrayValue.forEach({ (tempOrder) in
                if (tempOrder["select"].int ?? 0) == 1 {
                    disableIds.append(tempOrder["productid"].stringValue)
                }
            })
            self.carListData?["dataObj"]["enableList"].arrayValue.forEach({ (tempOrder) in
                if (tempOrder["select"].int ?? 0) == 1 {
                    disableIds.append(tempOrder["productid"].stringValue)
                }
            })
            if disableIds.count == 0 {
                self.view.makeToast("请选择订单")
                return
            }
            self.deleteProduct(with: disableIds)
        }
        setupTableView()
        confirmBt.onTap {
            if self.priceLb.text?.floatValue == 0.0 {
                self.view.makeToast("请选择订单")
                return
            }
            var carIDs = Array<String>.init()
            self.carListData?["dataObj"]["enableList"].arrayValue.forEach({ (tempOrder) in
                if (tempOrder["select"].int ?? 0) == 1 {
                    carIDs.append(tempOrder["carid"].stringValue)
                }
            })
            let pushedVC = ConfirmBuyViewController.init(nibName: "ConfirmBuyViewController", bundle: nil)
            pushedVC.carIds = carIDs
            pushedVC.priceText = self.priceLb.text
            pushedVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        selectAllBt.onTap {
            self.selectAllBt.isSelected = !self.selectAllBt.isSelected
            let selectNum = self.selectAllBt.isSelected ? 1 : 0
            for i in 0..<(self.carListData?["dataObj"]["enableList"].array ?? []).count {
                self.carListData?["dataObj"]["enableList"][i]["select"] = JSON(selectNum)
            }
            self.resetListView()
        }
    }
    
    func refreshPrice() {
        var price = 0.0
        self.carListData?["dataObj"]["enableList"].arrayValue.forEach({ (tempOrder) in
            if (tempOrder["select"].int ?? 0) == 1 {
                price += tempOrder["price"].doubleValue * tempOrder["productcount"].doubleValue
            }
        })
        self.priceLb.text = "\(price)"
    }
    
    func setupTableView() {
        self.addCustomCorner(with: mainTableView, radius: 14)
        mainTableView.register(UINib.init(nibName: "GouwucheListTableViewCell", bundle: nil), forCellReuseIdentifier: "GouwucheListTableViewCell")
        mainTableView.estimatedRowHeight = 50
        mainTableView.separatorStyle = .none
        
        mainTableView.numberOfSectionsIn { () -> Int in
            let disableCount = self.carListData?["dataObj"]["disableList"].arrayValue.count ?? 0
            if disableCount > 0 {
                self.tableHeader.leftCountLb.text = "失效宝贝(\(disableCount))"
                return 2
            }
            return 1
            }.numberOfRows { (section) -> Int in
                if section == 0{
                    return self.carListData?["dataObj"]["enableList"].arrayValue.count ?? 0
                }else{
                    return self.carListData?["dataObj"]["disableList"].arrayValue.count ?? 0
                }
            }.cellForRow { (indexPath) -> UITableViewCell in
                var list = self.carListData?["dataObj"]["enableList"].arrayValue
                if indexPath.section == 1{
                    list = self.carListData?["dataObj"]["disableList"].arrayValue
                }
                var procudtData = list![indexPath.row]
                let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "GouwucheListTableViewCell", for: indexPath) as! GouwucheListTableViewCell
                cell.mainImage.kf.setImage(with: URL.init(string: procudtData["productimg"].stringValue))
                cell.titleLb.text = procudtData["productname"].stringValue
                cell.subTitleLb.text = procudtData["content"].stringValue
                cell.countLb.text = procudtData["productcount"].stringValue
                cell.priceLb.text = procudtData["price"].stringValue
                cell.addBt.onTap {
                    self.addProductToShopCar(with: procudtData["productid"].stringValue, successClosure: {
                        self.carListData?["dataObj"]["enableList"][indexPath.row]["productcount"] = JSON(procudtData["productcount"].intValue + 1)
                        self.resetListView()
                    }, needToast: false)
                    
                }
                cell.minsBt.onTap {
                    if cell.countLb.text?.intValue == 1 {
                        return
                    }
                    self.minsProductInShopCar(with: procudtData["productid"].stringValue, successClosure: {
                        self.carListData?["dataObj"]["enableList"][indexPath.row]["productcount"] = JSON(procudtData["productcount"].intValue - 1)
                        self.resetListView()
                    })
                }
                cell.selectBt.isSelected = (procudtData["select"].int ?? 0) == 1
                cell.selectBt.onTap {
                    cell.selectBt.isSelected = !cell.selectBt.isSelected
                    if indexPath.section == 1 {
                        self.carListData?["dataObj"]["disableList"][indexPath.row]["select"] = cell.selectBt.isSelected ? 1 : 0
                    }else{
                        self.carListData?["dataObj"]["enableList"][indexPath.row]["select"] = cell.selectBt.isSelected ? 1 : 0
                    }
                    if !cell.selectBt.isSelected {
                        self.selectAllBt.isSelected = false
                    }
                    self.resetListView()
                }
                if indexPath.section == 0 {
                    cell.priceAndCountView.isHidden = false
                    cell.lostStateLb.isHidden = true
                }else{
                    cell.priceAndCountView.isHidden = true
                    cell.lostStateLb.isHidden = false
                }
                return cell
            }.viewForHeaderInSection { (section) -> UIView? in
                if section == 0{
                    return nil
                }else{
                    let headerBack = UIView.init()
                    headerBack.addSubview(self.tableHeader)
                    self.tableHeader.snp.makeConstraints({ (make) in
                        make.edges.equalToSuperview()
                    })
                    self.tableHeader.cleanBt.onTap {
                        self.clearDiableProduct()
                    }
                    return headerBack
                }
            }.heightForHeaderInSection { (section) -> CGFloat in
                if section == 0 {
                    return 0.01
                }else{
                    return 35
                }
            }.heightForFooterInSection { (section) -> CGFloat in
                return 0.01
            }.didSelectRowAt { (indexPath) in
                let pushedVC = ProductDetailViewController.init(nibName: "ProductDetailViewController", bundle: nil)
                var list = self.carListData?["dataObj"]["enableList"].arrayValue
                if indexPath.section == 1{
                    list = self.carListData?["dataObj"]["disableList"].arrayValue
                }
                let procudtData = list![indexPath.row]
                pushedVC.productInfo = procudtData
                pushedVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        mainTableView.tableFooterView = UIView.init()
        mainTableView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            self.getShopCarList()
        })
    }
    
    func clearDiableProduct() {
        var disableIds = Array<String>.init()
        self.carListData?["dataObj"]["disableList"].arrayValue.forEach({ (tempOrder) in
            disableIds.append(tempOrder["productid"].stringValue)
        })
        self.deleteProduct(with: disableIds)
    }
    
    func deleteProduct(with productID: [String]) {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        var productids = ""
        productID.forEach { (tempProduct) in
            productids += tempProduct
            productids += ","
        }
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "productids" : productids,
                         ] as [String : Any]
        NetworkManager.request(api: .deleteProduct, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    let newEnableList = JSON(self.carListData?["dataObj"]["enableList"].arrayValue.filter({ (tempOrder) -> Bool in
                        return !productID.contains(tempOrder["productid"].stringValue)
                    }) ?? [])

                     let newDisableList = JSON(self.carListData?["dataObj"]["disableList"].arrayValue.filter({ (tempOrder) -> Bool in
                        return !productID.contains(tempOrder["productid"].stringValue)
                    }) ?? [])
                    self.carListData?["dataObj"]["enableList"] = newEnableList
                    self.carListData?["dataObj"]["disableList"] = newDisableList
                    self.mainTableView.reloadData()
                    self.view.makeToast(jsonObj["msg"].string ?? "删除成功")
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func minsProductInShopCar(with productId: String, count: Int? = 1, successClosure: (() -> Void)? = {() in }) {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "productid" : productId,
                         "count" : count ?? 1] as [String : Any]
        NetworkManager.request(api: .subProductToShopCar, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    successClosure?()
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
