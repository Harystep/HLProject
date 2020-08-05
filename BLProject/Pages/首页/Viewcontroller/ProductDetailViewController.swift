//
//  ProductDetailViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/21.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit
import WebKit

class ProductDetailViewController: BaseViewController {
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var horizontalScroll: UIScrollView!
    @IBOutlet weak var horizontalMainBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var topSelectBack: UIView!
    @IBOutlet weak var topImageBack: UIView!
    @IBOutlet weak var topNumLb: UILabel!
    @IBOutlet weak var commentBack: UIView!
    @IBOutlet weak var carCountLb: UILabel!
    @IBOutlet weak var carBt: UIButton!
    @IBOutlet weak var buyNowBt: UIButton!
    @IBOutlet weak var addToCarBt: UIButton!
    let webView = WKWebView.init()
    var productInfo: JSON?
    var commentInfo: JSON?
    var posNo: String?
    @IBOutlet weak var leftScroll: UIScrollView!
    
    @IBOutlet weak var shopCarImage: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var descLb: UILabel!
    @IBOutlet weak var priceLb: UILabel!
    @IBOutlet weak var saleCountLb: UILabel!
    @IBOutlet weak var commentCountLb: UILabel!
    @IBOutlet weak var scoreLb: UILabel!
    
    @IBOutlet weak var moreCommentBt: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        if self.posNo != nil {
            getProductDetailByPosno(with: self.posNo!)
        }else{
            let productID = productInfo!["vid"].stringValue
            getProductDetail(with: productID)
        }
        getShopCarList()
    }
    
    func getShopCarList() {
        if self.userInfo == nil {
            return
        }
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         ] as [String : Any]
        NetworkManager.request(api: .getShopCarByUser, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.carCountLb.isHidden = false
                    var count = 0
                    for enableProduct in jsonObj["dataObj"]["enableList"].array ?? [] {
                        count += enableProduct["productcount"].intValue
                    }
                    self.carCountLb.text = "\(count)"
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func getProductDetailByPosno(with posno: String) {
        let parameter = ["posNo" : posno]
        NetworkManager.request(api: .getProductByPosNo, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.resetPage(with: jsonObj)
                    
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func getProductDetail(with id: String) {
        let parameter = ["vid" : id]
        NetworkManager.request(api: .getProductById, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.resetPage(with: jsonObj)
                    
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func getComment(with id: String) {
        let parameter = ["productid" : id]
        NetworkManager.request(api: .getEvalByProduct, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    print("评价数量\(jsonObj["dataList"].arrayValue.count)")
                    self.commentInfo = jsonObj
                    self.resetCommentList(with: jsonObj)
                    
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func resetCommentList(with data: JSON) {
        scoreLb.text = (data["dataObj"]["avgscore"].stringValue) + "分"
        commentCountLb.text = "用户评价(\(data["dataCount"].stringValue))"
        addCommentList(with: data["dataList"].arrayValue)
    }
    
    var detailObj: JSON?
    func resetPage(with data: JSON) {
        detailObj = data
        let productID = data["dataObj"]["vid"].stringValue
        getComment(with: productID)
        let loopList = data["dataObj"]["imageList"].arrayValue
        var imageList = Array<String>.init()
        for tempLoop in loopList {
            imageList.append(tempLoop["href"].stringValue)
        }
        let topLoopView = SDCycleScrollView.init(frame: topImageBack.bounds, imageURLStringsGroup: imageList)
        topImageBack.insertSubview(topLoopView!, at: 0)
        topLoopView?.itemDidScrollOperationBlock = {
            currentIndex in
            self.topNumLb.text = "\(currentIndex + 1)/\(imageList.count)"
        }
        topLoopView?.showPageControl = false
        self.topNumLb.text = "1/\(imageList.count)"
        
        nameLb.text = data["dataObj"]["vegetablename"].stringValue
        descLb.text = data["dataObj"]["content"].stringValue
        priceLb.text = data["dataObj"]["price"].stringValue
        saleCountLb.text = "已售：\(data["dataObj"]["salecount"].stringValue)份"
        webView.loadHTMLString(data["dataObj"]["detailcontent"].stringValue, baseURL: nil)
    }
    
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)
        addRightWeb()
        self.addCustomCorner(with: mainBackView, radius: 14)
        topSelectBack.subviews.forEach { (tempView) in
            if tempView.isKind(of: UILabel.self) {
                let tempLb = tempView as! UILabel
                tempLb.isUserInteractionEnabled = true
                tempLb.addTapGesture(handler: { (tap) in
                    self.tapTopBtAction(view: tempLb)
                })
            }
        }
        self.tapTopBtAction(view: self.topSelectBack.viewWithTag(1001)!)
        addToCarBt.onTap {
            if !self.judgeLogin() {
                return
            }
            self.addProductToShopCar(with: self.detailObj!["dataObj"]["vid"].stringValue, successClosure: {
                self.carCountLb.text = "\(self.carCountLb.text!.intValue + 1)"
                self.shopCarImage.image = UIImage.init(named: "购物车")
            }, needToast: true)
        }
        buyNowBt.onTap {
            if !self.judgeLogin() {
                return
            }
            let pushedVC = ConfirmBuyViewController.init(nibName: "ConfirmBuyViewController", bundle: nil)
            pushedVC.carIds = [self.detailObj!["dataObj"]["vid"].stringValue]
            pushedVC.isFromShopCar = false
            pushedVC.priceText = self.priceLb.text
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        moreCommentBt.onTap {
            let pushedVC = CommentViewController.init(nibName: "CommentViewController", bundle: nil)
            pushedVC.commentInfo = self.commentInfo
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        horizontalScroll.didEndDragging { (scroll, finish) in
            scroll.tag = 999
        }
        horizontalScroll.didEndDecelerating { (scroll) in
            if scroll.tag != 999 {
                return
            }
            let index = scroll.contentOffset.y / CGFloat(ScreenWidth)
            var currentTag = 1001
            if index == 1 {
                currentTag = 1002
            }
            self.tapTopBtAction(view: self.topSelectBack.viewWithTag(currentTag)!)
            scroll.tag = 0
        }
        carBt.onTap {
            if !self.judgeLogin() {
                return
            }
            self.tabBarController?.selectedIndex = 3
            self.navigationController?.popToRootViewController(animated: false)
        }
        leftScroll.alwaysBounceVertical = true
        leftScroll.didScroll { (scroll) in
            
        }
        leftScroll.didEndDragging { (scroll, _) in
            if scroll.contentOffset.y + scroll.bounds.size.height > scroll.contentSize.height + 80 && scroll.contentOffset.y > 80 {
                self.tapTopBtAction(view: self.topSelectBack.viewWithTag(1002)!)
            }
        }
    }
    
    func addRightWeb() {
        horizontalMainBack.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(ScreenWidth)
        }
//        webView.load(URLRequest.init(url: URL.init(string: "https://www.baidu.com")!))
//        webView.loadFileURL(URL.init(fileURLWithPath: Bundle.main.path(forResource: "webview", ofType: "html")!), allowingReadAccessTo: URL.init(fileURLWithPath: Bundle.main.path(forResource: "webview", ofType: "html")!))
    }
    
    func addCommentList(with data: [JSON]) {
        let commentList = data
        var lastView: UIView?
        for (i,data) in commentList.enumerated() {
            let commentView = CommentView.init()
            commentBack.addSubview(commentView)
            commentView.snp.makeConstraints { (make) in
                make.leading.trailing.equalToSuperview()
                if lastView != nil {
                    make.top.equalTo(lastView!.snp.bottom).offset(20)
                }else{
                    make.top.equalToSuperview().offset(10)
                }
                if i == commentList.count - 1 {
                    make.bottom.equalToSuperview().offset(-10)
                }
            }
            commentView.userIcon.kf.setImage(with: URL.init(string: data["icon"].string ?? ""))
            commentView.nameLb.text = data["nickname"].stringValue
            commentView.timeLb.text = data["evaltime"].stringValue
            commentView.contentLb.text = data["evalcontent"].stringValue
            commentView.starRatingView.value = CGFloat((data["score"].string ?? "0").floatValue)
            commentView.starRatingView.isUserInteractionEnabled = false
            lastView = commentView
        }
    }
    
    func tapTopBtAction(view: UIView) {
        let stateView = self.topSelectBack.viewWithTag(1003)
        stateView?.snp.remakeConstraints({ (make) in
            make.centerX.equalTo(view)
        })
        stateView?.layoutIfNeeded()
        var currentTag = 1001
        var otherTag = 1002
        var index = 0
        if view.tag == 1002 {
            currentTag = 1002
            otherTag = 1001
            index = 1
        }
        (self.topSelectBack.viewWithTag(currentTag) as? UILabel)?.font = UIFont.systemFont(ofSize: 18)
        (self.topSelectBack.viewWithTag(otherTag) as? UILabel)?.font = UIFont.systemFont(ofSize: 16)
        horizontalScroll.setContentOffset(CGPoint.init(x: ScreenWidth * Double(index), y: 0), animated: true)
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
