//
//  HomePageViewController.swift
//  ScenicCheck
//
//  Created by XinLiang on 2017/12/4.
//  Copyright © 2017年 xi-anyunjingzhiwei. All rights reserved.
//

import UIKit

class HomePageViewController: BaseViewController {
    
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var topBanner: UIImageView!
    @IBOutlet weak var centerButtonBack: UIView!
    @IBOutlet weak var dingqigouBack: UIView!
    @IBOutlet weak var shangpinBack: UIView!
    @IBOutlet weak var mainScroll: UIScrollView!
    @IBOutlet weak var naviCoverView: UIView!
    @IBOutlet weak var centerStateView: UIView!
    @IBOutlet weak var firstCenterBt: UIButton!
    @IBOutlet weak var topColorCleanView: UIView!
    @IBOutlet weak var topColorCelanViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scanBt: UIButton!
    @IBOutlet weak var showQRCodeBt: UIButton!
    @IBOutlet weak var searchBt: UIButton!
    @IBOutlet weak var topTitleLb: UILabel!
    
    @IBOutlet weak var bottomBack: UIView!
    @IBOutlet weak var topLocationImgageView: UIImageView!
    
    var lastSelectBt: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubViews()
        self.centerBtAction(firstCenterBt)
        getHomePageData()
        self.getLocationResult = { (location, state, error) in
            if error == nil {
//                print(location?.rgcData?.city ?? "未定位出城市")
                self.locationLb.text = "送至：" + ((location?.rgcData?.poiList ?? []).first?.name)!
//                self.topTitleLb.isUserInteractionEnabled = false
                
            }else{
//                self.topTitleLb.text = "定位失败"
//                self.topTitleLb.addTapGesture(handler: { (tap) in
//                    self.getLocation()
//                })
//                self.topTitleLb.isUserInteractionEnabled = true
            }
        }
        getLocation()
    }
    
    var homePageData: JSON!
    func getHomePageData() {
        NetworkManager.request(api: .homePage, parameters: nil, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.resetHome(with: jsonObj)
                    
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    var topLoop: SDCycleScrollView!
    var currentLoopIndex: Int!
    func resetHome(with data: JSON) {
        self.homePageData = data
        let loopList = self.homePageData["dataObj"]["loopList"].arrayValue
        var imageList = Array<String>.init()
        for tempLoop in loopList {
            imageList.append(tempLoop["src"].stringValue)
        }
        let topLoopView = SDCycleScrollView.init(frame: topBanner.bounds, imageURLStringsGroup: imageList)
        topBanner.addSubview(topLoopView!)
        topLoopView?.itemDidScrollOperationBlock = {
            currentIndex in
            self.currentLoopIndex = currentIndex
        }
        self.topLoop = topLoopView
        addProductList()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        centerButtonBack.shadow(offset: CGSize.init(width: 0, height: 1), opacity: 0.3, radius: 2, cornerRadius: 10, color: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
        dingqigouBack.shadow(offset: CGSize.init(width: 0, height: 1), opacity: 0.3, radius: 2, cornerRadius: 10, color: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
        shangpinBack.shadow(offset: CGSize.init(width: 0, height: 1), opacity: 0.3, radius: 2, cornerRadius: 10, color: #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
    }
    
    let locationLbBack = UIView.init()
    let locationLb = UILabel.init()
    func setUpSubViews() {
        self.setNaviHeight(with: naviBack)
        if UIDevice.current.isX() {
            topColorCelanViewHeight.constant = 108;
        }
        
        locationLb.textColor = UIColor.white
        locationLb.font = UIFont.systemFont(ofSize: 12)
        let shadowImage = UIImageView.init()
        shadowImage.image = UIImage.init(named: "合并形状")
        self.view.addSubview(locationLbBack)
        locationLbBack.addSubview(shadowImage)
        let textShadow = UIView.init()
        locationLbBack.addSubview(textShadow)
        locationLbBack.addSubview(locationLb)
        locationLbBack.snp.makeConstraints { (make) in
            make.leading.equalTo(self.topLocationImgageView.snp.leading).offset(-14)
            make.top.equalTo(self.topLocationImgageView.snp.bottom).offset(7)
            make.height.equalTo(26)
        }
        shadowImage.contentMode = .topLeft
        shadowImage.clipsToBounds = true
        shadowImage.snp.makeConstraints { (make) in
            make.leading.top.equalToSuperview()
            make.height.equalTo(5)
            make.width.equalTo(26)
        }
        locationLb.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(11)
            make.bottom.equalToSuperview().offset(-2)
            make.trailing.equalToSuperview().offset(-11)
        }
        textShadow.snp.makeConstraints { (make) in
            make.leading.equalTo(shadowImage).offset(-1)
            make.trailing.equalTo(locationLb).offset(11)
            make.bottom.equalToSuperview()
            make.top.equalTo(locationLb).offset(-4.3)
        }
        textShadow.cornerRadius = 3
        textShadow.maskToBounds = true
        textShadow.backgroundColor = UIColor.black
        textShadow.alpha = 0.3
        locationLb.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        shadowImage.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        mainScroll.didScroll { (scroll) in
            if scroll.contentOffset.y < 100 {
                self.naviCoverView.alpha = scroll.contentOffset.y / 100
            }else{
                self.naviCoverView.alpha = 1
            }
        }
        topColorCleanView.addTapGesture { (tap) in
            let loopList = self.homePageData["dataObj"]["loopList"].arrayValue
            let tempData = loopList[self.currentLoopIndex]
            if tempData["looptype"].intValue == 1 {
                return
            }
            self.showWebDetailView(with: tempData["looptype"].intValue, content: tempData["loopcontent"].stringValue)
        }
        dingqigouBack.addTapGesture { (tap) in
            let pushedVC = AddDingQiGouViewController.init(nibName: "AddDingQiGouViewController", bundle: nil)
           pushedVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        shangpinBack.addTapGesture { (tap) in
            self.showCaiDan(with: 4)
        }
        scanBt.onTap {
            let scanVC = ZFScanViewController.init()
            scanVC.returnScanBarCodeValue = {
                (barCode: String?) in
                print(barCode as Any)
                let scanObj = JSON.init(parseJSON: barCode ?? "")
                let posNo = scanObj["posno"].string
                if posNo != nil{
                    let pushedVC = ProductDetailViewController.init(nibName: "ProductDetailViewController", bundle: nil)
                    pushedVC.posNo = posNo
                    pushedVC.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(pushedVC, animated: true)
                }
                
                }
            self.present(scanVC, animated: true, completion: nil)
        }
        showQRCodeBt.onTap {
            if !self.judgeLogin() {
                return
            }
            let pushedVC = MyCardViewController.init(nibName: "MyCardViewController", bundle: nil)
            pushedVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        
        searchBt.onTap {
            let pushedVC = SearchViewController.init(nibName: "SearchViewController", bundle: nil)
            pushedVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        
    }
    
    @IBAction func centerBtAction(_ sender: UIButton) {
        if lastSelectBt != nil {
            
            if lastSelectBt! == sender {
                return
            }
            lastSelectBt!.isSelected = false
            self.showCaiDan(with: sender.tag)
        }
        sender.isSelected = true
        centerStateView.snp.remakeConstraints { (make) in
            make.centerX.equalTo(sender)
            make.bottom.equalToSuperview().offset(-5)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.centerStateView.layoutIfNeeded()
        }) { (finish) in
            
        }
        lastSelectBt = sender
    }
    
    func showCaiDan(with type: Int) {
        self.tabBarController?.selectedIndex = 1
        if (self.tabBarController?.viewControllers?.count ?? 0) > 2 {
            let caidanVC = (self.tabBarController?.viewControllers?[1] as! UINavigationController).viewControllers.first as! MenuViewController
            caidanVC.resetList(with: type)
        }
        
    }
    
    func addProductList() {
        let typeList = self.homePageData["dataObj"]["typeList"].arrayValue
        var lastView: UIView?
        for (i, data) in typeList.enumerated() {
            if i > 4 {
                return
            }
            if i == 4 {
                let image = shangpinBack.subviews.first?.viewWithTag(999) as? UIImageView
                let label = shangpinBack.subviews.first?.viewWithTag(998) as? UILabel
                
                image?.kf.setImage(with: URL.init(string: data["typesrc"].stringValue))
                label?.text = data["vtname"].stringValue
            }else{
//                let tempBt = centerButtonBack.subviews.first?.subviews[i].subviews.first as? UIButton
                let image = centerButtonBack.subviews.first?.subviews[i].subviews.first?.viewWithTag(999) as? UIImageView
                let label = centerButtonBack.subviews.first?.subviews[i].subviews.first?.viewWithTag(998) as? UILabel
                image?.kf.setImage(with: URL.init(string: data["typesrc"].stringValue))
                label?.text = data["vtname"].stringValue
            }
            
            let bottomList = HomeBottomListView.init(frame: CGRect.zero)
            bottomBack.addSubview(bottomList)
            bottomList.topBannerBack.addTapGesture { (tap) in
                self.showCaiDan(with: i)
            }
            bottomList.snp.makeConstraints { (make) in
                if i == 0 {
                    make.top.equalToSuperview()
                }else{
                    make.top.equalTo(lastView!.snp.bottom).offset(5)
                }
                make.leading.trailing.equalToSuperview()
                if i == typeList.count - 1{
                    make.bottom.equalToSuperview()
                }
            }
            bottomList.topBannerBack.kf.setImage(with: URL.init(string: data["bannersrc"].stringValue))
            addCell(with: bottomList.cellBack, dataList: data["productList"].arrayValue)
            lastView = bottomList
        }
        bottomBack.layoutIfNeeded()
    }
    
    func addCell(with view: UIView, dataList: [JSON]) {
        let width = (UIScreen.screenWidth - 16 * 3) / 2
        var cellArray = Array<HomeCellView>.init()
        let cellDataList = dataList
        for (i, data) in cellDataList.enumerated() {
            let cellView = HomeCellView.init(frame: CGRect.zero)
            view.addSubview(cellView)
            cellView.snp.makeConstraints { (make) in
                
                if i % 2 == 0{
                    make.leading.equalToSuperview()
                }else{
                    make.leading.equalTo(cellArray.last!.snp.trailing).offset(16)
                    make.trailing.equalToSuperview()
                    
                }
                if i / 2 ==  0 {
                    make.top.equalToSuperview()
                }else{
                    make.top.equalTo(cellArray[i - 2].snp.bottom).offset(11)

                }
                if i == cellDataList.count - 1 {
                    make.bottom.equalToSuperview().offset(-11)
                }
                if i != 0 {
                    make.width.equalTo(cellArray.last!)
                }else{
                    make.width.equalTo(width)
                }
            }
            cellArray.append(cellView)
            cellView.addTapGesture { (tap) in
                let pushedVC = ProductDetailViewController.init(nibName: "ProductDetailViewController", bundle: nil)
                pushedVC.productInfo = data
                pushedVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(pushedVC, animated: true)
            }
            cellView.mainImage.kf.setImage(with: URL.init(string: data["imageList"][0]["href"].stringValue))
            cellView.nameLb.text = data["vegetablename"].stringValue
            cellView.priceLb.text = data["price"].stringValue
            cellView.productData = data
            cellView.addToCarBt.onTap {
                if !self.judgeLogin() {
                    return
                }
                self.addProductToShopCar(with: data["vid"].stringValue, successClosure: {
                    cellView.addToCarBt.isSelected = true
                })
            }
        }
    }
    
    
    
    @objc func injected() {
        self.view.backgroundColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let viewController = segue.destination
//        if viewController.isKind(of: TaskListViewController.self) {
//            let identify = Int(segue.identifier!)
//
//            let mapViewController = viewController as! TaskListViewController
//            mapViewController.taskType =
//        }
    }
    

}
