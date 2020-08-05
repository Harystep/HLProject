//
//  AppDelegate.swift
//  HProject
//
//  Created by XinLiang on 2018/7/5.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, BMKGeneralDelegate, WXApiDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        
        self.setRootVC(isLogin: false)
        self.window?.makeKeyAndVisible()
        self.setupOtherPackage(launchoptions: launchOptions)
        return true
    }
    
    func showLoginVC() {
        let rootPage = LoginViewController.init(nibName: "LoginViewController", bundle: nil)
        let navi = UINavigationController.init(rootViewController: rootPage)
        navi.isNavigationBarHidden = true
        self.window?.rootViewController?.present(navi, animated: true, completion: nil)
    }
    
    func setRootVC(isLogin: Bool) {
        if isLogin {
            let rootPage = LoginViewController.init(nibName: "LoginViewController", bundle: nil)
            let navi = UINavigationController.init(rootViewController: rootPage)
            navi.isNavigationBarHidden = true
            self.window?.rootViewController = navi
        }else{
            let rootPage = CustomTabBarViewController.init(nibName: nil, bundle: nil)
            self.window?.rootViewController = rootPage
        }
        
    }
    
    var _mapManager: BMKMapManager = BMKMapManager()
    func setupOtherPackage(launchoptions: [UIApplicationLaunchOptionsKey: Any]?) {
        //load injection
        Bundle.init(path: "/Applications/InjectionIII.app/Contents/Resources/iOSInjection.bundle")?.load()
        
        PgyManager.shared().start(withAppId: "69c5784601ae0b9af0c2619f23bb60b8")
        PgyUpdateManager.sharedPgy().start(withAppId: "69c5784601ae0b9af0c2619f23bb60b8")
        
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.enable = true
        
        ToastManager.shared.position = ToastPosition.center
        ToastManager.shared.isQueueEnabled = false
        
        let ret = _mapManager.start("TSwjayIT74YG3sp5D2NhrQ0Eocri2MNI", generalDelegate: nil)
//        let ret = _mapManager.start("q6yZuVv5TmfwrCuqWvtHUx4aUCaBZ3xi", generalDelegate: nil)
        
        if ret == false {
            NSLog("manager start failed!")
        }
        WXApi.registerApp("wxdeec2e2e6144242f")
        
    }
    
    var wechatLoginResult: ((String) -> Void)?
    func onReq(_ req: BaseReq!) {
        print(req)
    }
    
    func onResp(_ resp: BaseResp!) {
        let authResq = resp as! SendAuthResp
        self.wechatLoginResult?(authResq.code)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        if (url.host ?? "") == "safepay" {
            AlipaySDK.defaultService()?.processOrder(withPaymentResult: url, standbyCallback: { (resualt) in
                let jsonObj = JSON.init(rawValue: resualt as Any)!
                if (jsonObj["resultStatus"].stringValue == "9000") {
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "alipaysuccess"), object: nil)
                }
            })
            return true
        }
        return WXApi.handleOpen(url, delegate: self)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        if (url.host ?? "") == "safepay" {
            AlipaySDK.defaultService()?.processOrder(withPaymentResult: url, standbyCallback: { (resualt) in
                let jsonObj = JSON.init(rawValue: resualt as Any)!
                if (jsonObj["resultStatus"].stringValue == "9000") {
                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "alipaysuccess"), object: nil)
                }
            })
            return true
        }
        return WXApi.handleOpen(url, delegate: self)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

