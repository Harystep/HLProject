//
//  ChangePassViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/19.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class ChangePassViewController: BaseViewController {

    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    
    @IBOutlet weak var getCodeBt: UIButton!
    @IBOutlet weak var saveBt: UIButton!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var passConfirmTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSubviews()
    }
    
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)
        let _ = self.addTitle(title: "更改密码", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
        getCodeBt.onTap {
            let phone = self.userInfo?["phoneno"].stringValue
            self.getVeriCode(phone: phone!, type: 2, button: self.getCodeBt)
        }
        saveBt.onTap {
            self.changePassAction()
        }
    }
    
    func checkParameter() -> Bool {
        if !self.checkSMSCode(code: self.codeTF.text ?? "") {
            self.view.makeToast("请输入正确的验证码")
            return false
        }
        if !self.checkPassword(pass: self.passTF.text ?? ""){
            self.view.makeToast("请输入正确格式的密码")
            return false
        }
        if !self.checkPassConfirm(pass: self.passTF.text ?? "", passConfim: self.passConfirmTF.text ?? ""){
            self.view.makeToast("两次密码输入不一致，请重新输入")
            return false
        }
        return true
    }
    
    func changePassAction() {
        if !self.checkParameter() {
            return
        }
        let parameter = ["password" : self.passTF.text ?? "", "verifycode" : self.codeTF.text ?? ""] as [String : Any]
        NetworkManager.request(api: .forgetPass, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
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
