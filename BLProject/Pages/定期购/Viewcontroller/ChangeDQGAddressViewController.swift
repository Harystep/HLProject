    //
//  ChangeDQGAddressViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/22.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class ChangeDQGAddressViewController: BaseViewController {
    
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var cardBackScroll: UIScrollView!
    
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var phoneLb: UILabel!
    @IBOutlet weak var addressLb: UILabel!
    
    var cardList: Array<AddressCardView> = []
    var cardDataList: Array<Any> = []
    var selectAddressCosure: ((JSON) -> Void)?
    var defaultAddressid: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        getAddressList()
    }
    
    func getAddressList() {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         ] as [String : Any]
        NetworkManager.request(api: .addressList, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.cardDataList = jsonObj["dataList"].arrayValue
                    self.addaCard(with: self.cardDataList)
                    for data in self.cardDataList {
                        let addressData = data as! JSON
                        if addressData["addressid"].stringValue == self.defaultAddressid! {
                            self.nameLb.text = addressData["receivename"].stringValue
                            self.phoneLb.text = addressData["receivephone"].stringValue
                            self.addressLb.text = addressData["fullAddress"].stringValue
                        }
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
        let _ = self.addTitle(title: "修改配送地址", naviBackView: naviBack)
        let rightBt = self.addRightBt(title: "新增", naviBackView: naviBack)
        rightBt.onTap {
            let pushedVC = AddAddressViewController.init(nibName: "AddAddressViewController", bundle: nil)
            pushedVC.addressListPage = self
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        self.addCustomCorner(with: mainBackView, radius: 14)
//        cardDataList = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
//        addaCard(with: cardDataList)
    }
    
    func addaCard(with list:[Any]) {
        var lastView: UIView?
        cardList.removeAll()
        cardBackScroll.removeAllSubviews()
        for (i,data) in list.enumerated() {
            let cardView = AddressCardView.init(frame: CGRect.zero)
            cardBackScroll.addSubview(cardView)
            cardView.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalToSuperview().offset(-10)
                make.height.equalTo(150)
                make.width.equalTo(ScreenWidth - 20)
                if lastView != nil {
                    make.top.equalTo(lastView!.snp.bottom).offset(10)
                }else{
                    make.top.equalToSuperview().offset(20)
                }
                if i == list.count - 1 {
                    make.bottom.lessThanOrEqualToSuperview().offset(-20)
                }
            }
            lastView = cardView
            cardView.tag = i
            let addressData = data as! JSON
            cardView.nameLb.text = addressData["receivename"].stringValue
            cardView.phoneLb.text = addressData["receivephone"].stringValue
            cardView.detailLb.text = addressData["fullAddress"].stringValue
            cardView.setDefaultBt.isSelected = addressData["isdefault"].stringValue == "1"
            cardView.setDefaultBt.onTap {
                self.setAddressDefault(with: addressData["addressid"].stringValue)
            }
            cardView.deleteBt.onTap {
                self.deleteAddress(with: addressData["addressid"].stringValue)
            }
            
            cardView.editBt.onTap {
                let pushedVC = AddAddressViewController.init(nibName: "AddAddressViewController", bundle: nil)
                pushedVC.addressInfo = addressData
                self.navigationController?.pushViewController(pushedVC, animated: true)
            }
            cardView.addTapGesture { (tap) in
                self.selectAddressCosure?(addressData)
                self.popBack()
            }
            cardList.append(cardView)
        }
    }
    
    func deleteAddress(with addressID: String) {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "addressid" : addressID
            ] as [String : Any]
        NetworkManager.request(api: .deleteAddress, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.removeAddressCard(with: addressID)
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func removeAddressCard(with addressID: String) {
        var cardIndex = 0
        for (i,data) in self.cardDataList.enumerated() {
            let addressData = data as! JSON
            if addressData["addressid"].stringValue == addressID {
                cardIndex = i
                break
            }
        }
        let cardView = cardList[cardIndex]
        UIView.animate(withDuration: 0.3, animations: {
            cardView.transform = CGAffineTransform.init(translationX: CGFloat(-ScreenWidth), y: 0)
        }, completion: { (finish) in
            self.cardDataList.remove(at: cardIndex)
            self.addaCard(with: self.cardDataList)
        })
    }
    
    func setAddressDefault(with addressID: String) {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "addressid" : addressID
            ] as [String : Any]
        NetworkManager.request(api: .setAddressDefault, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.refreshAddressList(with: addressID)
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func refreshAddressList(with defaultAddressId: String) {
        var newCardList: Array<Any> = []
        for data in self.cardDataList {
            var addressData = data as! JSON
            if addressData["addressid"].stringValue == defaultAddressId {
                addressData["isdefault"] = "1"
            }else{
                addressData["isdefault"] = "2"
            }
            newCardList.append(addressData)
        }
        self.cardDataList = newCardList
        self.addaCard(with: self.cardDataList)
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
