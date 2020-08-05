//
//  LoginViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/12.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController {

    @IBOutlet weak var wechatLoginBt: UIButton!
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var smsLoginBt: UIButton!
    @IBOutlet weak var passLoginBt: UIButton!
    @IBOutlet weak var stateView: UIView!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var getCodeBt: UIButton!
    @IBOutlet weak var codeStateIcon: UIImageView!
    var thirdId : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        self.view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        if !WXApi.isWXAppInstalled() {
            wechatLoginBt.isHidden = true
        }
    }
    
    func setUpSubviews() {
        self.setNaviHeight(with: naviBack)
        let backBt = self.addBackBt(with: naviBack)
        backBt.onTap {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        loginTypeChangeAction(smsLoginBt)
        getCodeBt.onTap {
            self.view.endEditing(true)
            if !self.checkPhone(phone: self.phoneTF.text ?? "") {
                self.view.makeToast("请输入正确的手机号")
                return
            }
            self.getVeriCode(phone: self.phoneTF.text!, type: 4, button: self.getCodeBt)
        }
    }
    
    @IBAction func loginTypeChangeAction(_ sender: UIButton) {
        stateView.snp.remakeConstraints { (make) in
            make.centerX.equalTo(sender)
        }
//        UIView.animate(withDuration: 0.3) {
//            self.stateView.superview?.layoutIfNeeded()
//        }
        if sender.tag == 1 {
            //passLogin
            codeTF.placeholder = "请输入密码"
            codeTF.keyboardType = .default
            getCodeBt.superview?.isHidden = true
            getCodeBt.superview?.snp.remakeConstraints({ (make) in
                make.width.equalTo(0)
            })
            codeStateIcon.image = #imageLiteral(resourceName: "loginicon3")
            codeTF.isSecureTextEntry = true
        }else{
            //smsLogin
            codeTF.placeholder = "请输入验证码"
            codeTF.keyboardType = .numberPad
            getCodeBt.superview?.isHidden = false
            getCodeBt.superview?.snp.remakeConstraints({ (make) in
                
            })
            codeStateIcon.image = #imageLiteral(resourceName: "loginicon2")
            codeTF.isSecureTextEntry = false
        }
        codeTF.endEditing(true)
        codeTF.text = nil
    }
    
    @IBAction func registAction(_ sender: UIButton) {
        let easyVC = RegisterViewController.init(nibName: "RegisterViewController", bundle: nil)
        easyVC.pageType = .registe
        self.navigationController?.pushViewController(easyVC, animated: true)
    }
    
    @IBAction func forgetPassAction(_ sender: UIButton) {
        let easyVC = RegisterViewController.init(nibName: "RegisterViewController", bundle: nil)
        easyVC.pageType = .forgetPass
        self.navigationController?.pushViewController(easyVC, animated: true)
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        self.view.endEditing(true)
        pressLoginBt()
    }
    
    func pressLoginBt() {
        if !self.checkPhone(phone: self.phoneTF.text ?? "") {
            self.view.makeToast("请输入正确的手机号")
            return
        }
        var type = 0
        if getCodeBt.superview!.isHidden {
            type = 1
            if !self.checkPassword(pass: self.codeTF.text ?? ""){
                self.view.makeToast("请输入正确格式的密码")
                return
            }
        }else{
            type = 2
            if !self.checkSMSCode(code: self.codeTF.text ?? "") {
                self.view.makeToast("请输入正确的验证码")
                return
            }
        }
        self.loginWithNetwork(type: type)
    }
    
    func loginWithNetwork(type: Int) {
        let parameter = ["phoneno" : self.phoneTF.text ?? "", "password" : self.codeTF.text ?? "", "verifycode" : self.codeTF.text ?? "", "thridid" : self.thirdId ?? "", "logintype" : type, "clienttype" : "ios"] as [String : Any]
        NetworkManager.request(api: .login, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    let jsonStr = try! jsonObj["dataObj"].dictionaryObject?.json()
                    UserDefaults.standard.set(jsonStr, forKey: UserInfoKey)
                    UserDefaults.standard.set(true, forKey: DidLogin)
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    @IBAction func wxLoginAction(_ sender: UIButton) {
        let req = SendAuthReq.init()
        req.scope = "snsapi_userinfo"
        req.state = "app"
        WXApi.send(req)
        APPDELEGATE.wechatLoginResult = {
            (code) in
            self.getAccessToken(with: code)
        }
    }
    
    func login(wiht thirdID: String, token: String) {
        let parameter = ["thridid" : thirdID,
                         "bindtype" : "wx"] as [String : Any]
        NetworkManager.request(api: .loginByThird, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    
                    if jsonObj["dataList"]["phoneno"].string != nil && jsonObj["dataList"]["phoneno"].string!.count > 0 {
                        let jsonStr = try! jsonObj["dataList"].dictionaryObject?.json()
                        UserDefaults.standard.set(jsonStr, forKey: UserInfoKey)
                        UserDefaults.standard.set(true, forKey: DidLogin)
                        self.navigationController?.dismiss(animated: true, completion: nil)
                    }else{
                        let easyVC = ConfirmPhoneWIthWeChatViewController.init(nibName: "ConfirmPhoneWIthWeChatViewController", bundle: nil)
                        self.thirdId = thirdID
                        easyVC.thirdId = thirdID
                        easyVC.token = token
                        
                        self.navigationController?.pushViewController(easyVC, animated: true)
                    }
                    
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func getAccessToken(with code: String) {
        NetworkManager.request(api: .otherURL(otherPath: "https://api.weixin.qq.com/sns/oauth2/access_token?appid=wxdeec2e2e6144242f&secret=be9378013979e89e1c8eba8ceb90411e&code=\(code)&grant_type=authorization_code"), parameters: nil, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                //                if jsonObj["state"].stringValue == "SUCCESS" {
                
                self.login(wiht: jsonObj["openid"].stringValue, token: jsonObj["access_token"].stringValue)
                
                //                }else{
                //                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                //                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
