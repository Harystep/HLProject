//
//  RegisterViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/12.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

enum PageType {
    case registe
    case forgetPass
}

class RegisterViewController: BaseViewController {

    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var confirmPassTF: UITextField!
    @IBOutlet weak var getCodeBt: UIButton!
    @IBOutlet weak var protocolView: UIView!
    
    var pageType: PageType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
    }
    
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)
        var type = 0
        if pageType == .registe {
            type = 1
            let _ = self.addTitle(title: "注册", naviBackView: naviBack)
            protocolView.isHidden = false
        }
        if pageType == .forgetPass {
            type = 2
            let _ = self.addTitle(title: "忘记密码", naviBackView: naviBack)
            protocolView.isHidden = true
            confirmPassTF.placeholder = "请再次输入新密码"
        }
        
        getCodeBt.onTap {
            self.view.endEditing(true)
            if !self.checkPhone(phone: self.phoneTF.text ?? "") {
                self.view.makeToast("请输入正确的手机号")
                return
            }
            self.getVeriCode(phone: self.phoneTF.text!, type: type, button: self.getCodeBt)
        }
    }
    
    @IBAction func completeAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if pageType == .registe {
            registerAction()
        }
        if pageType == .forgetPass {
            forgetPassAction()
        }
    }
    
    func forgetPassAction() {
        if !self.checkParameter() {
            return
        }
        let parameter = ["phoneno" : self.phoneTF.text ?? "", "password" : self.passTF.text ?? "", "verifycode" : self.codeTF.text ?? ""] as [String : Any]
        NetworkManager.request(api: .forgetPass, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.present(title: "提示", message: "密码重置成功，请重新登录", actions: [UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                        self.popBack()
                    })])
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func checkParameter() -> Bool {
        if !self.checkPhone(phone: self.phoneTF.text ?? "") {
            self.view.makeToast("请输入正确的手机号")
            return false
        }
        if !self.checkSMSCode(code: self.codeTF.text ?? "") {
            self.view.makeToast("请输入正确的验证码")
            return false
        }
        if !self.checkPassword(pass: self.passTF.text ?? ""){
            self.view.makeToast("请输入正确格式的密码")
            return false
        }
        if !self.checkPassConfirm(pass: self.passTF.text ?? "", passConfim: self.confirmPassTF.text ?? ""){
            self.view.makeToast("两次密码输入不一致，请重新输入")
            return false
        }
        return true
    }
    
    
    func registerAction() {
        if !self.checkParameter() {
            return
        }
        let parameter = ["phoneno" : self.phoneTF.text ?? "", "password" : self.passTF.text ?? "", "verifycode" : self.codeTF.text ?? ""] as [String : Any]
        NetworkManager.request(api: .register, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.popBack()
                    MainWindow.makeToast("注册成功，请登录")
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    @IBAction func showProtocolAction(_ sender: UIButton) {
        let pushedVC = WebViewController.init(nibName: "WebViewController", bundle: nil)
        pushedVC.type = 6
        self.navigationController?.pushViewController(pushedVC, animated: true)
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
