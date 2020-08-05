
//
//  AddressViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/19.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class AddressViewController: BaseViewController {

    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var cardBackScroll: UIScrollView!
    var cardList: Array<AddressCardView> = []
    var cardDataList: Array<Any> = []
    var selectAddressCosure: ((JSON) -> Void)?
    
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
        let _ = self.addTitle(title: "收货地址", naviBackView: naviBack)
        let rightBt = self.addRightBt(title: "新增", naviBackView: naviBack)
        rightBt.onTap {
            let pushedVC = AddAddressViewController.init(nibName: "AddAddressViewController", bundle: nil)
            pushedVC.addressListPage = self
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        self.addCustomCorner(with: mainBackView, radius: 14)
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

class AddressCardView: BaseView {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var phoneLb: UILabel!
    @IBOutlet weak var detailLb: UILabel!
    @IBOutlet weak var editBt: UIButton!
    @IBOutlet weak var deleteBt: UIButton!
    @IBOutlet weak var setDefaultBt: UIButton!
    
    func setupSubViews() {
        self.backgroundColor = Color.clear
        
    }
    
    override func layoutSubviews() {
        self.shadow(offset: CGSize.init(width: 0, height: 0), opacity: 0.3, radius: 2, cornerRadius: 6, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
//        self.shadowColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
//        self.shadow(offset: CGSize.init(width: 1, height: 2), opacity: 0.3, radius: 2)
    }
    
    //初始化时将xib中的view添加进来
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.customLoadNibView()
        setupSubViews()
    }
    
    //初始化时将xib中的view添加进来
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.customLoadNibView()
        setupSubViews()
    }
    
    @objc func injected() {
        //        setupSubViews()
        
    }
}
