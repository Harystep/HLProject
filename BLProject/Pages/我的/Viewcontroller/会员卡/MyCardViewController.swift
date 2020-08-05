//
//  MyCardViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/19.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class MyCardViewController: BaseViewController {

    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var cardBackScroll: UIView!
    @IBOutlet weak var inputCodeBt: UIButton!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var addCardBt: UIButton!
    var cardList: Array<AddressCardView> = []
    var cardDataList: Array<JSON> = []
    var selectCard = false
    var selectCardClosure: ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        getCardList()
    }
    
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        let _ = self.addBackBt(with: naviBack)
        let _ = self.addTitle(title: "我的会员卡", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 12)
        inputCodeBt.onTap {
            self.codeTF.becomeFirstResponder()
            self.codeTF.text = nil
        }
        codeTF.shouldEndEditing { () -> Bool in
            if self.codeTF.text?.count == 0 {
                self.codeTF.text = "请输入会员卡卡号进行绑定"
            }
            return true
        }
        addCardBt.onTap {
            if self.codeTF.text?.count == 0 && self.codeTF.text == "请输入会员卡卡号进行绑定" {
                self.view.makeToast("请输入卡号")
                return
            }
            self.bindCard(with: self.codeTF.text!)
        }
    }
    
    func bindCard(with no: String) {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "cardno" : no
                         ] as [String : Any]
        NetworkManager.request(api: .bindCard, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.view.makeToast("绑定成功")
                    self.codeTF.text = "请输入会员卡卡号进行绑定"
                    self.codeTF.resignFirstResponder()
                    self.getCardList()
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func getCardList() {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         ] as [String : Any]
        NetworkManager.request(api: .getPosCardList, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
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
    
    func addaCard(with list:[JSON]) {
        var lastView: UIView?
        for (i,data) in list.enumerated() {
            let cardView = CardView.init(frame: CGRect.zero)
            cardBackScroll.addSubview(cardView)
            cardView.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                if lastView != nil {
                    make.top.equalTo(lastView!.snp.bottom).offset(15)
                }else{
                    make.top.equalToSuperview().offset(20)
                }
                if i == list.count - 1 {
                    make.bottom.lessThanOrEqualToSuperview().offset(-20)
                }
            }
            lastView = cardView
            cardView.rateLb.text = "\(data["cashPayRate"].floatValue / 10)"
            cardView.cardNoLb.text = "卡号：\(data["cardNo"].stringValue)"
            cardView.qrCodeImage.image = data["cardNo"].stringValue.generateQRCode(logo: nil)
            if data["state"].stringValue != "正常" {
                cardView.timeOutView.isHidden = false
            }else{
                cardView.timeOutView.isHidden = true
                cardView.addTapGesture { (tap) in
                    if self.selectCard {
                        self.selectCardClosure?(i)
                        self.popBack()
                    }else{
                        self.showCardDetail(with: data)
                    }
                    
                }
            }
            
        }
    }
    
    func showCardDetail(with data: JSON) {
        let pushedVC = CardDetailViewController.init(nibName: "CardDetailViewController", bundle: nil)
        pushedVC.cardData = data
        self.navigationController?.pushViewController(pushedVC, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class CardView: BaseView {
    
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var cardNoLb: UILabel!
    @IBOutlet weak var rateLb: UILabel!
    @IBOutlet weak var timeOutView: UIView!
    
    func setupSubViews() {
        
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
