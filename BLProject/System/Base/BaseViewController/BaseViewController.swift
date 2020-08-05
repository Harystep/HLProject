//
//  BaseViewController.swift
//  ScenicCheck
//
//  Created by XinLiang on 2017/11/6.
//  Copyright © 2017年 xi-anyunjingzhiwei. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, BMKLocationAuthDelegate {
    
    func showOrderList(with type: Int) {
        self.tabBarController?.selectedIndex = 4
        let tempBt = UIButton.init()
        tempBt.tag = type - 1
        let myInfoVC = (self.tabBarController as! CustomTabBarViewController).myInfoVC
//        if myInfoVC != nil {
            myInfoVC.clickCenterBtAction(tempBt)
//        }
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    func judgeLogin() -> Bool {
        if !UserDefaults.standard.bool(forKey: DidLogin) {
            APPDELEGATE.showLoginVC()
            return false
        }
        return true
    }
    
    func payWithAli(with orderInfo: JSON) {
        getAliPayConfig(with: orderInfo)
    }
    
    func startAliPay(with orderInfo: JSON) {
        if aliConfig == nil {
            self.view.makeToast("参数错误，支付失败")
            return
        }
        let order = APOrderInfo.init()
        
        // NOTE: app_id设置
        order.app_id = aliConfig!["ALI_APID"].stringValue
        
        // NOTE: 支付接口名称
        order.method = "alipay.trade.app.pay";
        
        // NOTE: 参数编码格式
        order.charset = "utf-8";
        
        // NOTE: 当前时间点
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        order.timestamp = formatter.string(from: Date())
        
        order.notify_url = "http://www.coding88.com/store/api/orderinfo/alipay"
        
        // NOTE: 支付版本
        order.version = "1.0";
        
        // NOTE: sign_type 根据商户设置的私钥来决定
        order.sign_type = "RSA2"
        
        order.biz_content = APBizContent.init()
        order.biz_content.body = "贝瑞博士";
        order.biz_content.subject = "贝瑞博士:\(orderInfo["orderno"].stringValue)结算";
        order.biz_content.out_trade_no = orderInfo["orderno"].stringValue //订单ID（由商家自行制定）
        order.biz_content.timeout_express = "30m"; //超时时间设置
        var price = orderInfo["orderprice"].stringValue
        if price.count == 0{
            price = orderInfo["price"].stringValue
        }
        order.biz_content.total_amount = price //商品价格
        
        //将商品信息拼接成字符串
        let orderInfo = order.orderInfoEncoded(false)
        let orderInfoEncoded = order.orderInfoEncoded(true)
        
        // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
        //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
        var signedString: String?
        let rsa2 = aliConfig!["RSA2_PRIVATE"].stringValue
        
        let rsa2PrivateKey = "MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC3f/VrcxngOZqZy74NdFUY2PnQMzW4jOnQZriQF9S61C/cEGr2WG27B2PWfi3UCo4KsBqxtAEMMeJT/nPTMBqcDu1eihNjYE8nRyfgZ/GbBYWhEVPq4RTJO4Hmop5feSkE+2DLKfadDy4r8ZQ7FdRh0LOhjiVzwfgJiB1AWlz8SKjjEsaCXzfviVzizXRkFM3DnyfjyZm2OQeiw5lKVjTTvByKEzcNxJRQnvBKY161JCmtt5Kngs+8Mj6dDtd9VCHXw7unNwXIDNqYxyKqJuwpKziEOA+b/gBWnov9/FGFFFYw7SIUAbN+ePtWDOC4efMyeRPwWPnzTyLhhRvGlos5AgMBAAECggEBAKkDT73vHxc6l14unddwneyr9LRCZqmcCMOtyTLW8FZAl/BeotZRrogEj32BbJ6QNjI77+pbPFfKHod0p6QN+4Rf71wTWzY9/8nSrTTxKES7ulAXUK7XL7kFeWk/wRV42EJBcu7NsNsKn2FUOk6NlbeebcVQ0sgjEV1eJGsgj+LBTpUQHi/laP5JJGCxYlqXaZ6NIyGHgE18X0V932PtgBxp4to1WHkRjTZc8/NB0+u3IHjmA595Ugn4WoiF/DM05GCT7OHXdMm0EfmyWejuI1xe7MUdQhpJ3Uw0AWkiCF/Z+DsX8idoeFf3cD9kzR3CF/YFvP1u+D/UPBEeTA+h0YECgYEA3DDLFK/tlOS2tKjSYtDZdDmLlrv6rQt5yXKoAjAefUHvVIqe2XuUiSTWXbgcjYklzxzArqPgRWxqjhnjAgjli6oOv4dxDabAjBpIZskAlSmD8PryoLXoRWi+hmGtZ2F1mErwFVutXivVHTlRbks4pmNrvz4BoMeZd4KEELItBdECgYEA1Ved9tK8/MMZLqrK5ioNM9QWWbfsbyMuKuM+PWJ9N/MQL8vQsHsjP1CJDbq5XJnnQaZ1xEfpQcWuwjtaDsebMxbxttKh1mI5ag6zX/4bb1pD/zBNoDtrGWW6nAAZ/1T6zzsrGyI7tgdXiGXeQl6Z/CYIPdhptGq5iI4f1zmoQOkCgYABuTwNuGbSsIuhlGS5M0tQdpbaIjSPIDTe18/q3HeQoXB/J+qgZzA9dpVa/HL0xKsQGPiFJXE++d9Hp3o4bNtnIXimFShUZAbD0fzZGR+xCzcmLsCxc1sTGAPNx3v1ADVMcOG6ORJ9Vzh+1xEFHP+fhc21HIYkvQs9fT8NZmel0QKBgEa7JcQPWljy1gaC2YI1rurgBgj40YqHP2c4sAnp/VnvXA58pFPef3EeYlIK9imdXO6HIcRRkyQbRjVfOBxuUSY/FSRn8QAC0MY42X+Z376rTp/sg8/74yYodBYEcpoUspLCKyhz0RgolvzByU53ztWqRlE6ztDiEWEUvbm9g+sBAoGAXL1hcDwV1IlbGIOwbYoUz9q1jTRzXHJYZxKGpL/77IYf5CEFGOG2mrR1V3hHmqDCKIKMx1zJMfyuFZuEeeFAY1bWhQb9H5Ll65E4+WYr2lN1U9m+ojZSd1Ihm8FRdo1CydgLZpVex59Ev13lJrIiZ4UStKa0KpOmnu0vLPgXVYE="
        let signer = APRSASigner.init(privateKey: rsa2PrivateKey)
        signedString = signer?.sign(orderInfo!, withRSA2: true)
        
        // NOTE: 如果加签成功，则继续执行支付
        if (signedString != nil) {
            //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
            // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
            let orderString = orderInfoEncoded! + "&sign=" + signedString!
            
            // NOTE: 调用支付结果开始支付
            AlipaySDK.defaultService()?.payOrder(orderString, fromScheme: "com.blproject.alipay", callback: { (result) in
                print("zhifubao+++++++++")
                print(result)
            })
        }else{
            self.view.makeToast("支付调起失败，请联系客服")
        }
    }
    
    var aliConfig: JSON?
    func getAliPayConfig(with orderInfo: JSON) {
        NetworkManager.request(api: .aliConfig, parameters: nil, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.aliConfig = jsonObj["dataList"]
                    self.startAliPay(with: orderInfo)
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func showPayWeb(with url: String) {
        let pushedVC = WebViewController.init(nibName: "WebViewController", bundle: nil)
        pushedVC.type = 2
        pushedVC.content = url
        pushedVC.titleString = "订单支付"
        pushedVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(pushedVC, animated: true)
    }
    
    //type 1:nothing 2:link 3:富文本
    func showWebDetailView(with type: Int, content: String) {
        let pushedVC = WebViewController.init(nibName: "WebViewController", bundle: nil)
        pushedVC.type = type
        pushedVC.content = content
        pushedVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(pushedVC, animated: true)
    }
    
    var configInfo: JSON?
    func getConfig() {
        
        NetworkManager.request(api: .getConfig, parameters: nil, showHudTo: nil) { (response: DataResponse<Any>) in
            
            do {
                
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.configInfo = jsonObj["dataList"]
                }else{
                    //                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                //                self.view.makeToast("网络错误")
            }
        }
    }
    
    var getLocationResult: BMKLocatingCompletionBlock?
    var locationManager: BMKLocationManager!
    func getLocation() {
        BMKLocationAuth.sharedInstance().checkPermision(withKey: "TSwjayIT74YG3sp5D2NhrQ0Eocri2MNI", authDelegate: self as BMKLocationAuthDelegate)
//        BMKLocationAuth.sharedInstance().checkPermision(withKey: "q6yZuVv5TmfwrCuqWvtHUx4aUCaBZ3xi", authDelegate: self as BMKLocationAuthDelegate)

        locationManager = BMKLocationManager.init()
        locationManager.requestLocation(withReGeocode: true, withNetworkState: false, completionBlock: getLocationResult!) 
    }
    
    var userInfo: JSON?{
        let userInfoStr = UserDefaults.standard.object(forKey: UserInfoKey) as? String
        if userInfoStr != nil {
            let userInfoJson = JSON.init(parseJSON:userInfoStr!)
            return userInfoJson
        }else{
            return nil
        }
    }
    
    func addProductToShopCar(with productId: String, successClosure: (() -> Void)? = {() in }, needToast: Bool? = true) {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "productid" : productId
            ] as [String : Any]
        NetworkManager.request(api: .addProductToShopCar, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    successClosure?()
                    if needToast! {
                        MainWindow.makeToast("加入购物车成功")
                    }
                    
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    public func setNavigationBackBt() {
        let leftBackBt = UIBarButtonItem.init(image: #imageLiteral(resourceName: "fan hui"), style: .plain, target: self, action: #selector(popBack))
        leftBackBt.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.navigationItem.leftBarButtonItem = leftBackBt
    }
    
    @objc func popBack() {
        self.popBackWith(animated: true)
    }
    
    @objc func popBackWith(animated: Bool) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = true;//解决顶部留有空白的情况
        self.edgesForExtendedLayout = .top
    }
    
    /// 发送验证码
    ///
    /// - Parameter type: 短信类型;1:注册2忘记密码3绑定账号4登录
    /// - phone: 手机号
    func getVeriCode(phone: String, type: Int, button: UIButton) {
        let parameter = ["phoneno" : phone, "action" : type] as [String : Any]
        NetworkManager.request(api: .sendSMS, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    button.startCountDown()
                    MainWindow.makeToast("短信发送成功，请注意查收")
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func checkPassConfirm(pass: String, passConfim: String) -> Bool {
        if pass == passConfim {
            return true
        }else{
            return false
        }
    }
    
    func checkPassword(pass: String) -> Bool {
        if pass.count >= 6 && pass.count <= 20 {
            return true
        }else{
            return false
        }
    }
    
    func checkPhone(phone: String) -> Bool {
        if phone.count == 11 && phone.hasPrefix("1") {
            return true
        }else{
            return false
        }
    }
    
    func checkSMSCode(code: String) -> Bool {
        if code.count != 0 {
            return true
        }else{
            return false
        }
    }
    
    let topImage = UIImageView.init()
    lazy var backView: UIView = {
        () -> UIView in
        return UIView.init()
    }()
    final var topNaviView: UIView?
    
    func addTopImage() {
        self.view.insertSubview(topImage, at: 0)
        topImage.snp.makeConstraints { (make) in
            make.leading.top.trailing.equalToSuperview()
        }
        topImage.image = #imageLiteral(resourceName: "tou b bj")
    }
    
    func addPageBack() {
        self.view.insertSubview(backView, aboveSubview: topImage)
        backView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            if topNaviView != nil {
                make.top.equalTo(topNaviView!.snp.bottom)
            }
        }
        backView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.addCustomCorner(with: backView, radius: 14)
    }
    
    func addCustomCorner(with view: UIView, radius: CGFloat) {
        view.cornerRadius(radius)
        let bottomBack = UIView.init()
        view.superview?.insertSubview(bottomBack, belowSubview: view)
        bottomBack.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(view)
            make.height.equalTo(radius)
        }
        bottomBack.backgroundColor = view.backgroundColor
    }
    
    func setNaviHeight(with naviBackView: UIView) {
        if UIDevice.current.isX() {
            naviBackView.snp.remakeConstraints { (make) in
                make.height.equalTo(88)
                make.leading.trailing.top.equalToSuperview()
            }
        }else{
            naviBackView.snp.remakeConstraints { (make) in
                make.height.equalTo(64)
                make.leading.trailing.top.equalToSuperview()
            }
        }
        topNaviView = naviBackView
        if backView.superview != nil {
            backView.snp.makeConstraints { (make) in
                make.leading.trailing.bottom.equalToSuperview()
                make.top.equalTo(topNaviView!.snp.bottom)
            }
        }
    }
    
    func addBackBt(with naviBackView: UIView) -> UIButton {
        let backBt = UIButton.init()
        backBt.setImage(#imageLiteral(resourceName: "fan hui"), for: .normal)
        naviBackView.addSubview(backBt)
        backBt.snp.makeConstraints { (make) in
            make.leading.bottom.equalToSuperview()
            make.height.width.equalTo(44)
        }
        backBt.onTap {
            self.popBack()
        }
        return backBt
    }
    
    func addTitle(title: String, naviBackView: UIView) -> UILabel{
        let titleLb = UILabel.init()
        titleLb.text = title
        naviBackView.addSubview(titleLb)
        titleLb.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        titleLb.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        titleLb.font = UIFont.systemFont(ofSize: 18)
        return titleLb
    }
    
    func addRightBt(title: String, naviBackView: UIView) -> UIButton {
        let rightBt = UIButton.init()
        rightBt.setTitle(title, for: .normal)
        rightBt.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        rightBt.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        naviBackView.addSubview(rightBt)
        rightBt.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview()
            make.height.equalTo(44)
        }
        return rightBt
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
