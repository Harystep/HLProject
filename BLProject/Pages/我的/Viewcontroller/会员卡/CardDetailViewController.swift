//
//  CardDetailViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/19.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class CardDetailViewController: BaseViewController {
    @IBOutlet weak var moneyLb: UILabel!
    @IBOutlet weak var cardNoLb: UILabel!
    @IBOutlet weak var rateLb: UILabel!
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var cardBackScroll: UIScrollView!
    var cardData: JSON?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        getDetailList()
    }
    
    var detailList: [JSON]?
    func getDetailList() {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "cardno" : cardData!["cardNo"].stringValue
                         ] as [String : Any]
        NetworkManager.request(api: .getConsumeInfo, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.detailList = jsonObj["dataList"].arrayValue
                    self.addaCard(with: self.detailList!)
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
        let _ = self.addBackBt(with: naviBack)
        let _ = self.addTitle(title: "我的会员卡", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
        self.rateLb.text = "\(cardData!["cashPayRate"].floatValue / 10)"
        self.cardNoLb.text = "卡号：\(cardData!["cardNo"].stringValue)"
        
    }
    
    func addaCard(with list:[JSON]) {
        var lastView: UIView?
        for (i,data) in list.enumerated() {
            let cardView = CardUserDetailView.init(frame: CGRect.zero)
            cardBackScroll.addSubview(cardView)
            cardView.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalToSuperview().offset(-10)
                make.width.equalTo(ScreenWidth - 20)
                if lastView != nil {
                    make.top.equalTo(lastView!.snp.bottom).offset(8)
                }else{
                    make.top.equalToSuperview().offset(8)
                }
                if i == list.count - 1 {
                    make.bottom.lessThanOrEqualToSuperview().offset(-10)
                }
            }
            lastView = cardView
            cardView.nameLb.text = data["type"].intValue == 1 ? "消费" : "充值"
            cardView.detailLb.text = "\(data["type"].intValue == 1 ? "-" : "+")\(data["price"].stringValue)元"
            cardView.timeLb.text = data["dateStr"].stringValue
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

class CardUserDetailView: BaseView {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var timeLb: UILabel!
    @IBOutlet weak var detailLb: UILabel!
    
    func setupSubViews() {
        
    }
    
    override func layoutSubviews() {
        container.shadow(offset: CGSize.init(width: 0, height: 0), opacity: 0.3, radius: 2, cornerRadius: 6, color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
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
