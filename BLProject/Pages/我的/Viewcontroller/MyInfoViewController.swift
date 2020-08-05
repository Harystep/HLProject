//
//  MyInfoViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/14.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class MyInfoViewController: BaseViewController {

    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var centerBtBack: UIView!
    @IBOutlet weak var userInfoBack: UIView!
    @IBOutlet weak var myInfoImage: UIImageView!
    @IBOutlet weak var logoutBt: UIButton!
    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var idLb: UILabel!
    
    @IBOutlet weak var phoneLb: UILabel!
    @IBOutlet weak var showAllOrderBt: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.userInfo != nil {
            let userInfo = self.userInfo!
            userIcon.kf.setImage(with: URL.init(string: userInfo["icon"].string ?? ""))
            idLb.text = "ID:" + (userInfo["userid"].string ?? "")
            nameLb.text = userInfo["nickname"].string ?? ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSubviews()
    }
    
    func setUpSubviews() {
        self.setNaviHeight(with: naviBack)
        let _ = self.addTitle(title: "个人中心", naviBackView: naviBack)
        self.addCustomCorner(with: centerBtBack, radius: 12)
        userInfoBack.addTapGesture { (tap) in
            if !UserDefaults.standard.bool(forKey: DidLogin) {
                APPDELEGATE.showLoginVC()
                return
            }
            let pushedVC = ChangeUserInfoViewController.init(nibName: "ChangeUserInfoViewController", bundle: nil)
            pushedVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(pushedVC, animated: true)
        }
        myInfoImage.image = #imageLiteral(resourceName: "mymore").withRenderingMode(.alwaysTemplate)
        logoutBt.onTap {
            UserDefaults.standard.removeObject(forKey: UserInfoKey)
            UserDefaults.standard.set(false, forKey: DidLogin)
            MainWindow.makeToast("您已退出登录")
            self.userIcon.image = UIImage.init(named: "tou xiang")
            self.nameLb.text = "请登录"
            self.idLb.text = "ID"
            
        }
        
        showAllOrderBt.onTap {
            self.clickCenterBtAction(self.showAllOrderBt)
        }
        
        phoneLb.isUserInteractionEnabled = true
        phoneLb.addTapGesture { (tap) in
            UIApplication.shared.openURL(URL.init(string: "tel://400-960-8880")!)
        }
    }
    
    @IBAction func clickCenterBtAction(_ sender: UIButton) {
        if !self.judgeLogin() {
            return
        }
        if sender.tag == 4 {
            let pushedVC = NeedHelpListViewController.init(nibName: "NeedHelpListViewController", bundle: nil)
            pushedVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(pushedVC, animated: true)
            return
        }
        let pushedVC = MyOrderViewController.init(nibName: "MyOrderViewController", bundle: nil)
        pushedVC.orderType = sender.tag + 1
        if sender.tag == 3 {
            pushedVC.orderType = sender.tag + 2
        }
        pushedVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(pushedVC, animated: true)
    
    }
    
    
    @IBAction func clickItemAction(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if !self.judgeLogin() {
                return
            }
            let pushedVC = MyCardViewController.init(nibName: "MyCardViewController", bundle: nil)
            pushedVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(pushedVC, animated: true)
        case 1:
            if !self.judgeLogin() {
                return
            }
            let pushedVC = AddressViewController.init(nibName: "AddressViewController", bundle: nil)
            pushedVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(pushedVC, animated: true)
        case 2:
            if !self.judgeLogin() {
                return
            }
            let pushedVC = MessageViewController.init(nibName: "MessageViewController", bundle: nil)
            pushedVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(pushedVC, animated: true)
        case 3, 4:
            let pushedVC = WebViewController.init(nibName: "WebViewController", bundle: nil)
            pushedVC.type = sender.tag + 1
            pushedVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(pushedVC, animated: true)
        case 5:
            let pushedVC = CurrentVersionViewController.init(nibName: "CurrentVersionViewController", bundle: nil)
            pushedVC.hidesBottomBarWhenPushed = true
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
