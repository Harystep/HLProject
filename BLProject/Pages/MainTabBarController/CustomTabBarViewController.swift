//
//  CustomTabBarViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/12.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

class CustomTabBarViewController: UITabBarController, UITabBarControllerDelegate {

    let myInfoVC = MyInfoViewController.init(nibName: "MyInfoViewController", bundle: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        let normalImagesList = [#imageLiteral(resourceName: "shou  ye"), #imageLiteral(resourceName: "cai dan"), #imageLiteral(resourceName: "ding qi gou"), #imageLiteral(resourceName: "gou wu c"), #imageLiteral(resourceName: "wo de")]
        let selectImagesList = [#imageLiteral(resourceName: "shou  ye2"), #imageLiteral(resourceName: "cai dan2"), #imageLiteral(resourceName: "ding qi gou2"), #imageLiteral(resourceName: "gou wu c2"), #imageLiteral(resourceName: "wo de2")]
        let titleList = ["首页", "菜单", "定期购", "购物车", "我的"]
        let controllers = [
            HomePageViewController.init(nibName: "HomePageViewController", bundle: nil),
            MenuViewController.init(nibName: "MenuViewController", bundle: nil),
            DingQiGouViewController.init(nibName: "DingQiGouViewController", bundle: nil),
            ShoppingCarViewController.init(nibName: "ShoppingCarViewController", bundle: nil),
            myInfoVC]
        
        var viewControllers = Array<UIViewController>.init()
        for (i, tempController) in controllers.enumerated() {
            tempController.tabBarItem.image = normalImagesList[i].withRenderingMode(.alwaysOriginal)
            tempController.tabBarItem.selectedImage = selectImagesList[i].withRenderingMode(.alwaysOriginal)
            tempController.tabBarItem.title = titleList[i]
            tempController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1), NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10)], for: .normal)
            tempController.tabBarItem.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: #colorLiteral(red: 0.8235294118, green: 0.5764705882, blue: 0.2549019608, alpha: 1), NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10)], for: .selected)
            let naviVC = UINavigationController.init(rootViewController: tempController)
            naviVC.isNavigationBarHidden = true
            viewControllers.append(naviVC)
        }
        self.viewControllers = viewControllers
        self.tabBar.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.delegate = self
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if (viewControllers?.contains(viewController))!{
            let rootVC = (viewController as! UINavigationController).viewControllers.first!
            
            if !rootVC.isKind(of: HomePageViewController.self) && !rootVC.isKind(of: MenuViewController.self) && !UserDefaults.standard.bool(forKey: DidLogin) {
                APPDELEGATE.showLoginVC()
                return false
            }
        }
        return true
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
