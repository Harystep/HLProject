//
//  ChangePhoneViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/19.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class ChangePhoneViewController: BaseViewController {
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var topLb: UILabel!
    @IBOutlet weak var codeInputodeBack: UIView!
    @IBOutlet weak var phoneInputBack: UIView!
    @IBOutlet weak var getCodeBt: UIButton!
    @IBOutlet weak var bottomBt: UIButton!
    
    @IBOutlet weak var bottomTF: UITextField!
    @IBOutlet weak var topTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        setPhoneInput(show: false)
        bottomBt.onTap {
            if self.bottomBt.title(for: .normal) == "确认" {
                if !self.checkPhone(phone: self.bottomTF.text ?? "") {
                    self.view.makeToast("请输入正确的手机号")
                    return
                }
                self.setPhoneInput(show: true)
                self.topTF.text = nil
                self.bottomTF.text = nil
            }else{
                self.popBack()
                self.bindNewPhone()
            }
        }
    }
    
    func bindNewPhone() {
        if !self.checkPhone(phone: self.topTF.text ?? "") {
            self.view.makeToast("请输入正确的手机号")
            return
        }
        if !self.checkSMSCode(code: self.bottomTF.text ?? "") {
            self.view.makeToast("请输入正确的验证码")
            return
        }
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "phoneno" : self.topTF.text ?? "",
                         "verifycode" : self.bottomTF.text ?? ""] as [String : Any]
        NetworkManager.request(api: .changePhone, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.present(title: "提示", message: "密码修改成功，请重新登录", actions: [UIAlertAction.init(title: "确定", style: .default, handler: { (action) in
                        APPDELEGATE.showLoginVC()
                    })])
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func setPhoneInput(show: Bool) {
        if show {
            topLb.text = "新手机号码"
            phoneInputBack.isHidden = false
            codeInputodeBack.snp.remakeConstraints { (make) in
                make.leading.trailing.equalTo(phoneInputBack)
                make.top.equalTo(phoneInputBack.snp.bottom).offset(30)
                
            }
            bottomBt.setTitle("完成绑定", for: .normal)
        }else{
            topLb.text = "短信验证码"
            phoneInputBack.isHidden = true
            codeInputodeBack.snp.remakeConstraints { (make) in
                make.leading.trailing.equalTo(phoneInputBack)
                make.top.equalTo(phoneInputBack.snp.top)
                
            }
            bottomBt.setTitle("确认", for: .normal)
        }
    }
    
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)
        let _ = self.addTitle(title: "更改绑定手机号", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
        getCodeBt.onTap {
            if self.bottomBt.title(for: .normal) == "确认" {
                if !self.checkPhone(phone: self.bottomTF.text ?? "") {
                    self.view.makeToast("请输入正确的手机号")
                    return
                }
                self.getVeriCode(phone: self.bottomTF.text ?? "", type: 5, button: self.getCodeBt)
            }
            
        }
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
