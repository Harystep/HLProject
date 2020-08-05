//
//  NetworkManager.swift
//  ScenicCheck
//
//  Created by XinLiang on 2017/11/6.
//  Copyright © 2017年 xi-anyunjingzhiwei. All rights reserved.
//

import UIKit

class NetworkManager: NSObject {
    
    /// 网络请求
    ///
    /// - Parameters:
    ///   - api: 请求API枚举
    ///   - parameters: 参数
    ///   - response: 返回数据或错误
    public class func request(api: API, parameters: Dictionary<String, Any>?, encoding: ParameterEncoding? = URLEncoding.default,showHudTo view: UIView?, response: @escaping (DataResponse<Any>) -> Void) {
        debugPrint(api, parameters as Any)
        if view != nil {
            SwiftProgressHUD.hudBackgroundColor = UIColor.black.withAlphaComponent(0.2)
            SwiftProgressHUD.showWait()
        }
        
        Alamofire.request(api.path, method: api.method, parameters: parameters, encoding: encoding ?? api.encoding)
            .responseJSON { (originResponse) in
            debugPrint(originResponse)
                if view != nil {
                    SwiftProgressHUD.hideAllHUD()
                }
            if originResponse.result.isSuccess {
                response(originResponse)
//                do {
//                    let model = try JSONDecoder.init().decode(BaseModel.self, from: originResponse.data!)
//                    if model.errcode == 1001 {
//                        MainWindow.makeToast("您已下线，请重新登录")
//                        
//                    }else{
//                        response(originResponse)
//                    }
//                } catch {
//                    response(originResponse)
//                    MainWindow.makeToast("网络错误")
//                }
                
            }else{
                response(originResponse)
//                MainWindow.makeToast("网络错误")
            }
            
        }
    }
}
