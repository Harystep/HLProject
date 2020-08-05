//
//  ConfirmPhoneWIthWeChatViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/12.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class ConfirmPhoneWIthWeChatViewController: BaseViewController {

    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var codeTF: UITextField!
    @IBOutlet weak var getCodeBt: UIButton!
    var thirdId: String?
    var token: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSubviews()
        self.getUserInfo(openid: thirdId!, token: token!)
    }
    
    func getUserInfo(openid: String, token: String) {
        
        NetworkManager.request(api: .otherURL(otherPath: "https://api.weixin.qq.com/sns/userinfo?access_token=\(token)&openid=\(openid)"), parameters: nil, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
//                if jsonObj["state"].stringValue == "SUCCESS" {
                self.iconImage.kf.setImage(with: URL.init(string: jsonObj["headimgurl"].stringValue), placeholder: #imageLiteral(resourceName: "toux"))
                self.nameLb.text = jsonObj["nickname"].stringValue
//                }else{
//                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
//                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)
        let _ = self.addTitle(title: "账号绑定", naviBackView: naviBack)
        getCodeBt.onTap {
            self.view.endEditing(true)
            if !self.checkPhone(phone: self.phoneTF.text ?? "") {
                self.view.makeToast("请输入正确的手机号")
                return
            }
            self.getVeriCode(phone: self.phoneTF.text!, type: 3, button: self.getCodeBt)
        }
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        if !self.checkPhone(phone: self.phoneTF.text ?? "") {
            self.view.makeToast("请输入正确的手机号")
            return
        }
        if !self.checkSMSCode(code: self.codeTF.text ?? "") {
            self.view.makeToast("请输入正确的验证码")
            return
        }
        self.bindWithNetwork()
    }
    
    func bindWithNetwork() {
        let parameter = ["phoneno" : self.phoneTF.text ?? "", "bindtype" : "wx", "verifycode" : self.codeTF.text ?? "", "thirdid" : self.thirdId ?? ""] as [String : Any]
        NetworkManager.request(api: .bindUser, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    let jsonStr = try! jsonObj["dataList"].dictionaryObject?.json()
                    UserDefaults.standard.set(jsonStr, forKey: UserInfoKey)
                    UserDefaults.standard.set(true, forKey: DidLogin)
                    self.navigationController?.dismiss(animated: true, completion: nil)
                    MainWindow.makeToast("绑定成功")
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
