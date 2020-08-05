//
//  AddCommentViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/23.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class AddCommentViewController: BaseViewController {
    
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var cardBackView: UIView!
    @IBOutlet weak var submitBt: UIButton!
    var orderData: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
    }
    
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)
        let _ = self.addTitle(title: "商品评价", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
        addCard()
        submitBt.onTap {
            self.addComment()
        }
    }
    
    func addComment() {
        let list = self.orderData!["detailList"].arrayValue
        var commentDataList = Array<[String : String]>.init()
        for (i, data) in list.enumerated() {
            let tempCard = self.cardList[i]
            let tempComment = [
                "vid": data["vegetable"].stringValue,
                "evalscore" : "\(tempCard.starRateView.value)",
                "evalcontent" : "\(tempCard.commentTextView.text!)"
            ]
            commentDataList.append(tempComment)
        }
        self.makeComment(with: self.orderData!["orderno"].stringValue, evalInfo: try! commentDataList.json())
    }
    
    func makeComment(with orderID: String, evalInfo: String) {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "orderno" : orderID,
                         "evalinfo" : evalInfo
            ] as [String : Any]
        NetworkManager.request(api: .evalOrder, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    MainWindow.makeToast("评价成功")
                    for tempVC in self.navigationController!.viewControllers {
                        if tempVC.isKind(of: MyOrderViewController.self) {
                            self.navigationController?.popToViewController(tempVC, animated: true)
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
    
    var cardList = Array<AddCommentView>.init()
    func addCard() {
        let list = self.orderData!["detailList"].arrayValue
        var lastView: UIView?
        for (i, data) in list.enumerated() {
            let commentCard = AddCommentView.init(frame: CGRect.zero)
            cardBackView.addSubview(commentCard)
            commentCard.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                if lastView != nil {
                    make.top.equalTo(lastView!.snp.bottom).offset(10)
                }else{
                    make.top.equalToSuperview()
                }
                if i == list.count - 1 {
                    make.bottom.lessThanOrEqualToSuperview()
                }
            }
            lastView = commentCard
            commentCard.mainImage.kf.setImage(with: URL.init(string: data["imagesrc"].stringValue))
            commentCard.titlelb.text = data["vegetablename"].stringValue
            commentCard.descLb.text = data["producecontent"].stringValue
            commentCard.infoLb.text = data["vegetablename"].stringValue
            cardList.append(commentCard)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

import SwiftyStarRatingView
class AddCommentView: BaseView {
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var titlelb: UILabel!
    @IBOutlet weak var commentTextView: PlaceholderTextView!
    @IBOutlet weak var starRateView: SwiftyStarRatingView!
    @IBOutlet weak var infoLb: UILabel!
    @IBOutlet weak var descLb: UILabel!
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
}
