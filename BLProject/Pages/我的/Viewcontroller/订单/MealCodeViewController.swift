//
//  MealCodeViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/23.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class MealCodeViewController: BaseViewController {
    
    @IBOutlet weak var phoneLb: UILabel!
    @IBOutlet weak var addressLb: UILabel!
    @IBOutlet weak var timeLb: UILabel!
    @IBOutlet weak var codeLb: UILabel!
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    var orderData: JSON?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        getEatCode(with: orderData!["orderno"].stringValue)
    }
    
    func getEatCode(with orderNo: String) {
        timeLb.text = "时间：\(orderData!["tradetime"].stringValue)"
        addressLb.text = "地址：\(orderData!["storeaddress"].stringValue)"
        phoneLb.text = orderData!["storephone"].stringValue
        
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "orderno" : orderNo
            ] as [String : Any]
        NetworkManager.request(api: .getEatingCode, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.codeLb.text = jsonObj["dataObj"]["code"].stringValue
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
        let _ = self.addTitle(title: "取餐码", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
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
