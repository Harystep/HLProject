//
//  WebViewController.swift
//  BLProject
//
//  Created by XinLiang on 2018/8/19.
//  Copyright © 2018年 xinliang. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: BaseViewController, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var naviBack: UIView!
    @IBOutlet weak var mainBackView: UIView!
    var type: Int?//2:link 3:富文本 4：帮助中心 5:关于 6：注册协议
    var content: String?
    var titleString: String?
    
    var mainWebView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSubviews()
        switch type {
        case 2:
            let url = URL.init(string: content ?? "")
            if url != nil {
                mainWebView.load(URLRequest.init(url: url!))
            }
        case 3:
            mainWebView.loadHTMLString(content ?? "", baseURL: nil)
        case 4, 5, 6:
            self.getData(with: self.type!)
            
        default:
            print("default")
        }
        
    }
    
    func getData(with type: Int) {
        var parameterType = 0
        switch type {
        case 4 :
            parameterType = 3
            self.titleLb?.text = "帮助中心"
        case 5 :
            parameterType = 1
            self.titleLb?.text = "关于我们"
        case 6 :
            parameterType = 2
            self.titleLb?.text = "注册协议"
        default:
            print(type)
        }
        let parameter = ["type" : parameterType] as [String : Any]
        NetworkManager.request(api: .getSiteInfomation, parameters: parameter, showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.mainWebView.loadHTMLString(jsonObj["dataList"]["infocontent"].stringValue, baseURL: nil)
                }else{
                    self.view.makeToast(jsonObj["msg"].string ?? "网络错误")
                }
            } catch {
                self.view.makeToast("网络错误")
            }
        }
    }
    
    var titleLb: UILabel?
    func setUpSubviews() {
        self.addTopImage()
        self.setNaviHeight(with: naviBack)
        self.addPageBack()
        let _ = self.addBackBt(with: naviBack)
        titleLb = self.addTitle(title: titleString ?? "内容详情", naviBackView: naviBack)
        self.addCustomCorner(with: mainBackView, radius: 12)
        mainWebView = WKWebView.init()
        mainWebView.uiDelegate = self
        mainWebView.navigationDelegate = self
        mainBackView.addSubview(mainWebView)
        mainWebView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alert = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "确定", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        self.present(alert, animated: true) {
            print("弹窗")
        }
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("webview url:" + navigationAction.request.url!.absoluteString)
        let header = navigationAction.request.allHTTPHeaderFields
        if header != nil && header!["Referer"] != nil && header!["Referer"] != "pay.jiakevip.com://" {
            decisionHandler(WKNavigationActionPolicy.cancel)
            var newRequest = URLRequest.init(url: navigationAction.request.url!)
            newRequest.setValue("pay.jiakevip.com://", forHTTPHeaderField: "Referer")
            webView.load(newRequest)
            return
        }
        if (navigationAction.request.url?.scheme?.contains("weixin"))! {
            if UIApplication.shared.canOpenURL(navigationAction.request.url!) {
                UIApplication.shared.openURL(navigationAction.request.url!)
                decisionHandler(WKNavigationActionPolicy.cancel)
                let confirmAction = UIAlertAction.init(title: "已支付", style: .default) { (action) in
                    self.searchFromServer()
                }
                let cancleAction = UIAlertAction.init(title: "取消", style: .default) { (action) in
                    self.showOrderList(with: 0)
                }
                self.present(title: "提示", message: "如果您已完成支付，请点击已支付，取消支付请点击取消", actions: [cancleAction, confirmAction])
            }else{
                decisionHandler(WKNavigationActionPolicy.allow)
            }
        }else{
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
    
    func searchFromServer() {
        //查询接口
        let orderNo = self.content?.components(separatedBy: "&").first?.components(separatedBy: "=").last
        NetworkManager.request(api: .wechatPayResult, parameters: ["orderNo" : orderNo ?? ""], showHudTo: self.view) { (response: DataResponse<Any>) in
            do {
                let jsonObj = try JSON.init(data: response.data!)
                if jsonObj["state"].stringValue == "SUCCESS" {
                    self.showOrderList(with: 0)
                }else{
                    self.showDidnotPayAlert()
                }
            } catch {
                self.view.makeToast("网络错误")
                self.showDidnotPayAlert()
            }
        }
    }
    
    func showDidnotPayAlert() {
        let confirmAction = UIAlertAction.init(title: "重试", style: .default) { (action) in
            self.searchFromServer()
        }
        let cancleAction = UIAlertAction.init(title: "取消", style: .default) { (action) in
            self.showOrderList(with: 0)
        }
        self.present(title: "提示", message: "未支付成功，若已付款，可能是银行反应延迟，请重新检测", actions: [cancleAction, confirmAction])
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
