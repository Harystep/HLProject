
//
//  StoreListViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/9/23.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class StoreListViewController: BaseViewController {
    
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    
    var cardDataList: Array<JSON> = []
    var selectStoreCosure: ((JSON, Int) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        getStoreList()
    }
    
    func getStoreList() {
        NetworkManager.request(api: .storeList, parameters: nil, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.cardDataList = jsonObj["dataList"].arrayValue
                    self.mainTableView.reloadData()
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
        let _ = self.addTitle(title: "门店列表", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
        mainTableView.tableFooterView = UIView.init()
        mainTableView.register(UINib.init(nibName: "StoreListCell", bundle: nil), forCellReuseIdentifier: "StoreListCell")
        mainTableView.numberOfRows { (section) -> Int in
            return self.cardDataList.count
            }.cellForRow { (indexPath) -> UITableViewCell in
                let data = self.cardDataList[indexPath.row]
                let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "StoreListCell", for: indexPath) as! StoreListCell
                cell.nameLb.text = data["storename"].stringValue
                cell.addressLb.text = data["storeaddress"].stringValue
                return cell
            }.didSelectRowAt { (indexPath) in
                let data = self.cardDataList[indexPath.row]
                self.selectStoreCosure?(data, indexPath.row)
                self.popBack()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class StoreListCell: BaseTableViewCell {
    
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var addressLb: UILabel!
    @IBOutlet weak var distanceLb: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
