//
//  SearchViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/22.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var cleanHistoryBt: UIButton!
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var topSearchBt: UIButton!
    
    
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var historyBack: UIView!
    @IBOutlet weak var historyKeyBack: UIView!
    
    @IBOutlet weak var historyResult: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    var dataSource = Array<JSON>.init()
    let waterLabelsView = WaterFlowLabelsView.init(frame: CGRect.zero)
    let SearchHistoryListKey = "SearchHistoryListKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        historyResult.isHidden = true
    }
    var searchHistoryKeyList: [String]?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshHistory()
    }
    
    func refreshHistory() {
        searchHistoryKeyList = UserDefaults.standard.array(forKey: SearchHistoryListKey) as? Array<String>
        waterLabelsView.labelNames = searchHistoryKeyList
    }
    
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)

        self.addCustomCorner(with: mainBackView, radius: 14)
        
        cleanHistoryBt.onTap {
            UserDefaults.standard.set(nil, forKey: self.SearchHistoryListKey)
            self.refreshHistory()
        }
        
        waterLabelsView.clickSearchLabelBlock = {[weak self] (data: String) in
            self?.setHistoryResult(hidden: false)
            self?.getSearchList(with: data)
        }
        
        historyKeyBack.addSubview(waterLabelsView)
        waterLabelsView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        setupTableView()
        topSearchBt.onTap {
            self.searchTF.becomeFirstResponder()
        }
        searchTF.didEndEditing {
            if (self.searchTF.text ?? "").count > 0 {
                self.setHistoryResult(hidden: false)
            }else{
                self.setHistoryResult(hidden: true)
                self.searchTF.text = "输入你想要的宝贝"
            }
        }
        searchTF.shouldBeginEditing { () -> Bool in
            if self.searchTF.text == "输入你想要的宝贝"{
                self.searchTF.text = nil
            }
            return true
        }
        searchTF.shouldReturn { () -> Bool in
            self.searchTF.resignFirstResponder()
            if self.searchTF.text?.count ?? 0 > 0 && self.searchTF.text != "输入你想要的宝贝" {
                if self.searchHistoryKeyList == nil {
                    self.searchHistoryKeyList = []
                }
                self.searchHistoryKeyList?.append(self.searchTF.text!)
                UserDefaults.standard.set(self.searchHistoryKeyList, forKey: self.SearchHistoryListKey)
                //请求搜索接口
                self.getSearchList(with: self.searchTF.text!)
            }
            return true
        }
        
    }
    
    func getSearchList(with searchText: String) {
        let parameter = ["vegetablename" : searchText]
        NetworkManager.request(api: .getProduct, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.dataSource = jsonObj["dataList"].arrayValue
                    self.mainTableView.reloadData()
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func setHistoryResult(hidden: Bool) {
        self.historyResult.isHidden = hidden
        self.historyKeyBack.isHidden = !hidden
    }
    
    func setupTableView() {
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.register(UINib.init(nibName: "ProductTableViewCell", bundle: nil), forCellReuseIdentifier: "ProductTableViewCell")
        mainTableView.tableFooterView = UIView.init()
        mainTableView.estimatedRowHeight = 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as! ProductTableViewCell
        let data = self.dataSource[indexPath.row]
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
                self.dataSource[indexPath.row]["select"] = 1
            })
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pushedVC = ProductDetailViewController.init(nibName: "ProductDetailViewController", bundle: nil)
        let data = self.dataSource[indexPath.row]
        pushedVC.productInfo = data
//        pushedVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(pushedVC, animated: true)
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
