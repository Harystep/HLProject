//
//  MessageViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/19.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class MessageViewController: BaseViewController {
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var mainTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        getMessageList()
    }
    
    var messageList: [JSON]?
    func getMessageList() {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         ] as [String : Any]
        NetworkManager.request(api: .getMessage, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.messageList = jsonObj["dataList"].arrayValue
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
        let _ = self.addTitle(title: "消息", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
        mainTableView.tableFooterView = UIView.init()
        mainTableView.register(UINib.init(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageTableViewCell")
        mainTableView.numberOfRows { (section) -> Int in
            return self.messageList?.count ?? 0
            }.cellForRow { (indexPath) -> UITableViewCell in
                let cell = self.mainTableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
                let data = self.messageList?[indexPath.row]
                cell.titleLb.text = data?["msgtitle"].stringValue
                cell.subTitleLb.text = data?["msgcontent"].stringValue
                
                let timeStr = data!["createtime"].stringValue.substring(to: 10)
                let date = Date.init(timeIntervalSince1970: TimeInterval(timeStr.intValue))
                let dateFormatter = DateFormatter.init()
                dateFormatter.dateFormat = "yyyy/MM/dd"
                let timeString = dateFormatter.string(from: date)
                cell.dateLb.text = timeString
                return cell
            }.didSelectRowAt { (indexPath) in
                let data = self.messageList?[indexPath.row]
                self.showWebDetailView(with: 3, content: data!["msgcontent"].stringValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class MessageTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var titleLb: UILabel!
    @IBOutlet weak var subTitleLb: UILabel!
    @IBOutlet weak var dateLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
