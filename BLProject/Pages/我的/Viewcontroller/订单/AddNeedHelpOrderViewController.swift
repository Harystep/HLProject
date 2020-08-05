//
//  AddNeedHelpOrderViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/23.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class AddNeedHelpOrderViewController: BaseViewController {

    @IBOutlet weak var moreInfoTextView: PlaceholderTextView!
    @IBOutlet weak var showReasonPickerBt: UIButton!
    @IBOutlet weak var reasonLb: UILabel!
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    
    @IBOutlet weak var submitBt: UIButton!
    @IBOutlet weak var cameraBackView: UIView!
    
    var orderData: JSON?
    
    let cameraCatchView = AddImageView.init(frame: CGRect.zero)
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
        getSaleServiceType()
    }
    
    var saleServiceTypeList: [String]?
    func getSaleServiceType() {
//        let userId = self.userInfo!["uid"].string
//        let token = self.userInfo!["usertoken"].string
//        let parameter = ["userid" : userId ?? "",
//                         "token" : token ?? "",
//                         ] as [String : Any]
        NetworkManager.request(api: .getSaleServiceType, parameters: nil, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.saleServiceTypeList = jsonObj["dataList"].arrayObject as? [String]
                    self.reasonLb.text = self.saleServiceTypeList![0]
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
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
        let _ = self.addTitle(title: "申请售后", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
        setCameraImageView()
        showReasonPickerBt.onTap {
            let picker = UIPickerView.init()
            
            let pickerBack = UIView.init()
            
            MainWindow.addSubview(pickerBack)
            pickerBack.snp.makeConstraints({ (make) in
                make.edges.equalToSuperview()
            })
            pickerBack.addSubview(picker)
            picker.snp.makeConstraints({ (make) in
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(picker.snp.width)
                make.bottom.equalToSuperview()
            })
            picker.addStrings(self.saleServiceTypeList ?? [], didSelect: { (reasonString, cmpont, row) in
                pickerBack.removeFromSuperview()
                self.reasonLb.text = reasonString
            })
        }
        
        submitBt.onTap {
            if self.cameraCatchView.imagesArray.count > 0 {
                self.addServiceWithImage()
            }
            self.addService()
        }
    }
    
    /// 设置拍照视图
    func setCameraImageView() {
        self.cameraBackView.addSubview(cameraCatchView)
        cameraCatchView.snp.makeConstraints { (make) in
            make.edges.equalTo(cameraCatchView.superview!)
        }
        cameraCatchView.addNewImageBlack = {(tapGesture: UITapGestureRecognizer) -> Void in
            self.showCamera()
        }
    }
    
    func addServiceWithImage() {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        Alamofire.upload(
            multipartFormData: { (multipartFormData) in
                for tempImage in self.cameraCatchView.imagesArray {
                    let image = tempImage as! UIImage
                    let imageData = UIImageJPEGRepresentation(image, 0.3)!
                    multipartFormData.append(imageData, withName: "file", fileName: "icon.jpg", mimeType: "image/jpg")
                }
                
                multipartFormData.append(self.orderData!["orderno"].stringValue.data(using: .utf8)!, withName: "orderno")
                multipartFormData.append(self.orderData!["detailid"].stringValue.data(using: .utf8)!, withName: "detailid")
                multipartFormData.append((self.moreInfoTextView.text ?? "").data(using: .utf8)!, withName: "content")
                multipartFormData.append((self.reasonLb.text ?? "").data(using: .utf8)!, withName: "reason")
                multipartFormData.append((userId ?? "").data(using: .utf8)!, withName: "userid")
                multipartFormData.append((token ?? "").data(using: .utf8)!, withName: "token")
                
        },
            to: API.salesService.path,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        do {
                            let jsonObj = try JSON.init(data: response.data!)
                            if jsonObj["state"].stringValue == "SUCCESS" {
                                MainWindow.makeToast("申请成功")
                                self.popBack()
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
        })
    }
    
    func addService() {
        let userId = self.userInfo!["uid"].string
        let token = self.userInfo!["usertoken"].string
        let parameter = ["userid" : userId ?? "",
                         "token" : token ?? "",
                         "orderno" : self.orderData!["orderno"].stringValue,
                         "detailid" : self.orderData!["detailid"].stringValue,
                         "content" : self.moreInfoTextView.text ?? "",
                         "reason" : self.reasonLb.text ?? ""
            ] as [String : Any]
        NetworkManager.request(api: .salesServiceNoImg, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    MainWindow.makeToast("申请成功")
                    self.popBack()
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    func showCamera() {
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
                self.cameraCatchView.imagesArray.insert(result.originalImage!, at: 0)
                self.cameraCatchView.layoutSubviews()
            }).present(from: self)
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
