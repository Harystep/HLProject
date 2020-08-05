//
//  ChangeUserInfoViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/19.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit
import Alamofire

class ChangeUserInfoViewController: BaseViewController {
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var userIDLb: UILabel!
    @IBOutlet weak var phoneLb: UILabel!
    @IBOutlet weak var saveBt: UIButton!
    
    @IBOutlet weak var nickNameTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
    }
    
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)
        let _ = self.addTitle(title: "个人信息", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
        saveBt.onTap {
            self.uploadInfo()
        }
        if self.userInfo != nil {
            let userInfo = self.userInfo!
            userIcon.kf.setImage(with: URL.init(string: userInfo["icon"].string ?? ""))
            userIDLb.text = userInfo["userid"].string ?? ""
            nickNameTF.text = userInfo["nickname"].string ?? ""
            phoneLb.text = userInfo["phoneno"].string ?? ""
        }
        
        
    }
    
    func uploadInfo() {
        if userIcon.image == nil {
            self.view.makeToast("请设置头像")
            return
        }
        if nickNameTF.text?.count == 0 {
            self.view.makeToast("请设置昵称")
            return
        }
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let imageData = UIImageJPEGRepresentation(self.userIcon.image!, 0.3)!
        let nickName = self.nickNameTF.text ?? ""
        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                if self.didChangeIcon {
                    multipartFormData.append(imageData, withName: "files", fileName: "icon.jpg", mimeType: "image/jpg")
                }
                multipartFormData.append(nickName.data(using: .utf8)!, withName: "nickname")
                multipartFormData.append((userId ?? "").data(using: .utf8)!, withName: "userid")
                multipartFormData.append((token ?? "").data(using: .utf8)!, withName: "token")
                
        },
            to: API.editUser.path,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        do {
                            let jsonObj = try JSON.init(data: response.data!)
                            if jsonObj["state"].stringValue == "SUCCESS" {
                                let jsonStr = try! jsonObj["dataObj"].dictionaryObject?.json()
                                UserDefaults.standard.set(jsonStr, forKey: UserInfoKey)
                                self.view.makeToast("保存成功")
                            }else{
                                self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                            }
                        } catch {
                            self.view.makeToast("网络错误")
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
    }
    var didChangeIcon = false
    @IBAction func itemClickAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            let alertSheet = CustomAlertSheet.init(frame: CGRect.zero)
            MainWindow.addSubview(alertSheet)
            alertSheet.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            alertSheet.showAlertSheet()
            let imagePickType : [UIImagePickerControllerSourceType] = [.photoLibrary, .camera]
            alertSheet.clickBtClosure = {
                (index: Int) in
                UIImagePickerController.init(source: imagePickType[index], allow: [.image], cameraOverlay: nil, showsCameraControls: true, didCancel: { (picker) in
                    debugPrint("cancle pick")
                }, didPick: { (result, picker) in
                    self.didChangeIcon = true
                    self.userIcon.image = result.originalImage
                }).present(from: self)
            }
        case 2:
            self.nickNameTF.becomeFirstResponder()
        case 3:
            let pushedVC = ChangePhoneViewController.init(nibName: "ChangePhoneViewController", bundle: nil)
            self.navigationController?.pushViewController(pushedVC, animated: true)
        case 4:
            let pushedVC = ChangePassViewController.init(nibName: "ChangePassViewController", bundle: nil)
            self.navigationController?.pushViewController(pushedVC, animated: true)
        default:
            print(sender.tag)
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
