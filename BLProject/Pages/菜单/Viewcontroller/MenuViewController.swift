//
//  MenuViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/14.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class MenuViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    @IBOutlet weak var naviBack: UIView!
    
    @IBOutlet weak var backNavi: UIView!
    @IBOutlet weak var searchNavi: UIView!
    @IBOutlet weak var searchBT: UIButton!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var backNaviBackImage: UIImageView!
    
    @IBOutlet weak var anotherLocationBt: UIButton!
    @IBOutlet weak var locationBt: UIButton!
    @IBOutlet weak var locationLb: UILabel!
    @IBOutlet weak var anotherLocationLb: UILabel!
    @IBOutlet weak var topBanner: UIImageView!
    @IBOutlet weak var mainTableView: UITableView!
    let headerBack = UIView.init()
    let tableHeader = TableHeaderView.init(frame: CGRect.zero)
    let footer = UIView.init()
    
    var typeData: [JSON]?
    var currentType: Int = 0
    var dataSourceDic = Dictionary<Int, [JSON]>.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubViews()
        getTypeList()
        getTypeLoop()
        self.getLocationResult = { (location, state, error) in
            if error == nil {
                print(location?.rgcData?.city ?? "未定位出城市")
                self.locationLb.text = (location?.rgcData?.poiList ?? []).first?.name
                self.anotherLocationLb.text = (location?.rgcData?.poiList ?? []).first?.name
            }else{
                self.locationLb.text = "定位失败"
                self.anotherLocationLb.text = "定位失败"
            }
        }
        getLocation()
    }
    
    func getProductList(with type: Int) {
        let parameter = ["typeid" : self.typeData![type]["vtid"].stringValue]
        NetworkManager.request(api: .getProduct, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.dataSourceDic[type] = jsonObj["dataList"].arrayValue
                    self.mainTableView.reloadData()
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func getTypeList() {
        NetworkManager.request(api: .getTypeList, parameters: nil, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.typeData = jsonObj["dataList"].arrayValue
                    self.resetType(with: self.typeData!)
                    
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    var loopData: [JSON]?
    func getTypeLoop() {
        NetworkManager.request(api: .getTypeLoop, parameters: nil, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.loopData = jsonObj["dataObj"].arrayValue
                    self.resetBanner(with: self.loopData!)
                    
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    var currentLoopIndex: Int!
    var topLoop: SDCycleScrollView!
    func resetBanner(with loopInfo: [JSON]) {
        var imageList = Array<String>.init()
        for tempLoop in loopInfo {
            imageList.append(tempLoop["src"].stringValue)
        }
        let topLoopView = SDCycleScrollView.init(frame: topBanner.bounds, imageURLStringsGroup: imageList)
//        topBanner.addSubview(topLoopView!)
        topLoopView?.itemDidScrollOperationBlock = {
            currentIndex in
            self.currentLoopIndex = currentIndex
        }
        self.topLoop = topLoopView
        self.mainTableView.tableHeaderView = self.topLoop
    }
    
    func resetType(with typeInfo: [JSON]) {
        for (i, data) in typeInfo.enumerated() {
            let centerButtonBack = self.tableHeader.stateView.superview!
            let image = centerButtonBack.subviews[i].subviews.first?.viewWithTag(999) as? UIImageView
            let label = centerButtonBack.subviews[i].subviews.first?.viewWithTag(998) as? UILabel
            image?.kf.setImage(with: URL.init(string: data["typesrc"].stringValue))
            label?.text = data["vtname"].stringValue
        }
        self.resetList(with: currentType)
    }
    
    func setUpSubViews() {
        self.setNaviHeight(with: naviBack)
        self.addCustomCorner(with: mainTableView, radius: 14)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.register(UINib.init(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
        mainTableView.tableFooterView = UIView.init()
        mainTableView.estimatedRowHeight = 100
        if UIDevice.current.isX() {
            mainTableView.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: ScreenWidth, height: 108))
        }
        mainTableView.tableHeaderView?.addTapGesture(handler: { (tap) in
            let tempData = self.loopData![self.currentLoopIndex]
            if tempData["looptype"].intValue == 1 {
                return
            }
            self.showWebDetailView(with: tempData["looptype"].intValue, content: tempData["loopcontent"].stringValue)
        })

        footer.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        mainTableView.addSubview(footer)
        footer.isUserInteractionEnabled = false
        footer.frame = CGRect.init(x: 0, y: 132, width: ScreenWidth, height: ScreenHeight * 2)
        footer.layer.zPosition = -1
        
        searchBT.onTap {
            let pushedVC = SearchViewController.init(nibName: "SearchViewController", bundle: nil)
            pushedVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        locationBt.onTap {
            if !self.judgeLogin() {
                return
            }
            self.pushToLocationPage()
        }
        anotherLocationBt.onTap {
            self.pushToLocationPage()
        }
    }
    
    func pushToLocationPage() {
        let pushedVC = SelectLocationViewController.init(nibName: "SelectLocationViewController", bundle: nil)
        pushedVC.selectAddressClosure = {
            (address: Any) in
            let newAddress = address as! BMKPoiInfo
            self.locationLb.text = newAddress.name
        }
        pushedVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(pushedVC, animated: true)
    }
    
    func resetList(with type: Int) {
        currentType = type
        self.tableHeader.click(with: type)
        if self.dataSourceDic[type] == nil {
            if self.typeData == nil {
                self.getTypeList()
            }else{
                self.getProductList(with: type)
            }
        }else{
            self.mainTableView.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainTableView {
            if scrollView.contentOffset.y > 100 {
                self.backNavi.alpha = 1
                self.backNaviBackImage.alpha = 1
                self.searchNavi.alpha = 0
            }else{
                
                self.backNavi.alpha = scrollView.contentOffset.y / 100.0
                self.backNaviBackImage.alpha = scrollView.contentOffset.y / 100.0
                self.searchNavi.alpha = 1 - scrollView.contentOffset.y / 100.0
                
                if scrollView.contentOffset.y < 0 {
                    return
                }
                tableHeader.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().offset(10 * (1 - scrollView.contentOffset.y / 100.0))
                    make.trailing.equalToSuperview().offset(-10 * (1 - scrollView.contentOffset.y / 100.0))
                    make.top.bottom.equalToSuperview()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableHeader.superview != headerBack {
            headerBack.addSubview(tableHeader)
        }
        tableHeader.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.bottom.equalToSuperview()
        }
        tableHeader.clickItemClosure = {
            (lastIndex: Int, index: Int) in
            self.currentType = index
            if self.dataSourceDic[index] == nil {
                self.getProductList(with: index)
            }else{
                self.mainTableView.reloadData()
            }
            
//            self.topBanner.kf.setImage(with: URL.init(string: self.typeData![index]["bannersrc"].string ?? ""))
//            var indexPathList: Array<IndexPath> = []
//            for (i, _) in self.dataSource.enumerated() {
//                let tempIndex = IndexPath.init(row: i, section: 0)
//                indexPathList.append(tempIndex)
//            }
//            var animination = UITableViewRowAnimation.right
//            if lastIndex < index {
//                animination = .left
//            }
//            tableView.reloadRows(at: indexPathList, with: animination)
        }
        return headerBack
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
        let data = self.dataSourceDic[currentType]![indexPath.row]
        cell.mainImage.kf.setImage(with: URL.init(string: data["imageList"][0]["href"].stringValue))
        cell.titleLb.text = data["vegetablename"].stringValue
        cell.priceLb.text = data["price"].stringValue
        cell.subTitleLb.text = data["content"].stringValue
        cell.productData = data
        if data["select"].intValue == 1 {
            cell.addToCarBt.isSelected = true
        }else{
            cell.addToCarBt.isSelected = false
        }
        cell.addToCarBt.onTap {
            if !self.judgeLogin() {
                return
            }
            self.addProductToShopCar(with: data["vid"].stringValue, successClosure: {
                cell.addToCarBt.isSelected = true
                self.dataSourceDic[self.currentType]![indexPath.row]["select"] = 1
            })
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let list = self.dataSourceDic[currentType]
        return list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pushedVC = ProductDetailViewController.init(nibName: "ProductDetailViewController", bundle: nil)
        let data = self.dataSourceDic[currentType]![indexPath.row]
        pushedVC.productInfo = data
        pushedVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(pushedVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let list = self.dataSourceDic[currentType]
        if indexPath.row == (list?.count ?? 0) - 1 {
            footer.frame = CGRect.init(x: 0, y: Double(self.mainTableView.contentSize.height), width: ScreenWidth, height: ScreenHeight)
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
