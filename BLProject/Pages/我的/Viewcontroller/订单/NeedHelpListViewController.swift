//
//  NeedHelpListViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/23.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class NeedHelpListViewController: BaseViewController {

    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    var dataSource = Array<JSON>.init()
    
    @IBOutlet weak var mainTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        setupTableView()
        getServiceOrderList()
    }
    
    func getServiceOrderList() {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         ] as [String : Any]
        NetworkManager.request(api: .getSalesServiceList, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.dataSource = jsonObj["dataList"].arrayValue
                    self.addOrderList()
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
        let _ = self.addTitle(title: "售后订单", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
    }
    
    func setupTableView() {
        mainTableView.tableFooterView = UIView.init()
    }
    
    func addOrderList() {
        mainTableView.addElements(dataSource, cell: NeedHelpCell.self, cellNibName: "NeedHelpCell") { (data, cell, index) in
            cell.selectionStyle = .none
            cell.stateLb.text = data["orderstatus"].stringValue
            cell.backNo.text = data["backpayno"].stringValue
            cell.titleLb.text = data["vegetablename"].stringValue
            cell.subTitleLb.text = data["vegetablecontent"].stringValue
            cell.descLb.text = data["content"].stringValue
            cell.mainImage.kf.setImage(with: URL.init(string: data["vegetableimg"].stringValue))
            cell.timeLb.text = "下单时间：" + data["tradetime"].stringValue
        }
        mainTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class NeedHelpCell: BaseTableViewCell {
    
    @IBOutlet weak var backNo: UILabel!
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var subTitleLb: UILabel!
    
    @IBOutlet weak var timeLb: UILabel!
    @IBOutlet weak var stateLb: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var descLb: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
