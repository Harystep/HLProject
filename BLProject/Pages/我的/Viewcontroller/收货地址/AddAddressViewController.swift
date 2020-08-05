//
//  AddAddressViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/19.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class AddAddressViewController: BaseViewController {
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    @IBOutlet weak var setDefaultSwitch: UISwitch!
    @IBOutlet weak var bottomBt: UIButton!
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var selectedAddressLb: UILabel!
    var addressInfo: JSON?
    var addressListPage: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
    }
    
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)
        let titleLb = self.addTitle(title: "新增收货地址", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 14)
        setDefaultSwitch.offImage = #imageLiteral(resourceName: "setDefaultoff")
        bottomBt.onTap {
            self.addAddressAction()
        }
        if addressInfo != nil {
            nameTF.text = addressInfo!["receivename"].stringValue
            phoneTF.text = addressInfo!["receivephone"].stringValue
            addressTF.text = addressInfo!["housenumber"].stringValue
            selectedAddressLb.text = addressInfo!["addressdetail"].stringValue
            setDefaultSwitch.isOn = addressInfo!["isdefault"].stringValue == "1"
            titleLb.text = "修改收货地址"
        }
    }
    
    func checkParameter() -> Bool {
        if !self.checkPhone(phone: self.phoneTF.text ?? "") {
            self.view.makeToast("请输入正确的手机号")
            return false
        }
        if (self.nameTF.text ?? "").length == 0 {
            self.view.makeToast("请输入收货人姓名")
            return false
        }
        if (self.selectedAddressLb.text ?? "").length == 0 {
            self.view.makeToast("请选择收货地址")
            return false
        }
        if self.selectedAddressLb.text == "请选择" {
            self.view.makeToast("请选择收货地址")
            return false
        }
        if (self.addressTF.text ?? "").length == 0 {
            self.view.makeToast("请输入详细地址")
            return false
        }
        return true
    }
    
    func addAddressAction() {
        self.view.endEditing(true)
        if !self.checkParameter() {
            return
        }
        
        let isDefault = setDefaultSwitch.isOn ? "1" : "2"
        let lat = "\(addressObj?.pt.latitude ?? 0)"
        let lng = "\(addressObj?.pt.longitude ?? 0)"
        let userId = self.userInfo!["uid"].stringValue
        let token = self.userInfo!["usertoken"].stringValue
        let parameter = ["userid" : userId,
                         "token" : token,
                         "receivephone" : self.phoneTF.text ?? "",
                         "receivename" : self.nameTF.text ?? "",
                         "housenumber" : self.addressTF.text ?? "",
                         "addressdetail" : self.selectedAddressLb.text!,
                         "isdefault" : isDefault,
                         "lat" : lat,
                         "lng" : lng,
                         "provincename" : addressObj?.province ?? "",
                         "cityname" : addressObj?.city ?? "",
                         "areaname" : addressObj?.area ?? ""]
        NetworkManager.request(api: .addAddress, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    if self.addressListPage != nil {
                        if (self.addressListPage?.isKind(of: SelectLocationViewController.self))!{
                            (self.addressListPage as! SelectLocationViewController).getAddressList()
                        }
                        if (self.addressListPage?.isKind(of: AddressViewController.self))!{
                            (self.addressListPage as! AddressViewController).getAddressList()
                        }
                        if (self.addressListPage?.isKind(of: ChangeDQGAddressViewController.self))!{
                            (self.addressListPage as! ChangeDQGAddressViewController).getAddressList()
                        }
                        if (self.addressListPage?.isKind(of: ConfirmBuyViewController.self))!{
                            (self.addressListPage as! ConfirmBuyViewController).getAddressList(showDefault: true)
                        }
                    }
                    self.popBack()
                    MainWindow.makeToast("添加成功")
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    var addressObj: BMKPoiInfo?
    @IBAction func itemClickAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            self.nameTF.becomeFirstResponder()
        case 1:
            self.phoneTF.becomeFirstResponder()
        case 2:
            self.view.endEditing(true)
            let pushedVC = SelectLocationViewController.init(nibName: "SelectLocationViewController", bundle: nil)
            pushedVC.isAddNewAddress = true
            pushedVC.selectAddressClosure = {
                (data) in
                let address = data as! BMKPoiInfo
                self.selectedAddressLb.text = address.address
                self.addressObj = address
            }
            self.navigationController?.pushViewController(pushedVC, animated: true)
        case 3:
            self.addressTF.becomeFirstResponder()
        case 4:
            self.view.endEditing(true)
            self.setDefaultSwitch.setOn(!self.setDefaultSwitch.isOn, animated: true)
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
