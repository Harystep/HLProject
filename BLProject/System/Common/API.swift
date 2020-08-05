//
//  API.swift
//  ScenicCheck
//
//  Created by XinLiang on 2017/11/7.
//  Copyright © 2017年 xi-anyunjingzhiwei. All rights reserved.
//
//线上管理后台地址 admin
//http://www.coding88.com/auth/login.html
//swagger
//http://www.coding88.com/store/swagger-ui.html#/%E8%8E%B7%E5%8F%96POS%E7%9A%84%E6%95%B0%E6%8D%AE/getCardListUsingGET


import UIKit
import Alamofire

public enum API {
    case otherURL(otherPath: String)
    case sendSMS
    case register
    case login
    case loginByThird
    case editUser
    case forgetPass
    case bindUser
    case homePage
    case addAddress
    case addressList
    case setAddressDefault
    case editAddress
    case deleteAddress
    case changePass
    case changeInfo
    case cancleOrder
    case createOrderByProduct
    case createOrderByShopcar
    case getOrderDetail
    case getOrderList
    case addProductToShopCar
    case deleteProduct
    case getEvalByProduct
    case getProduct
    case getProductById
    case getShopCarByUser
    case getTypeList
    case subProductToShopCar
    case buyRegular
    case cancelRegularOrder
    case editRegularOrderInfo
    case getRegularDetail
    case getRegularOrder
    case getRegularOrderList
    case createOrderByRegular
    case getConfig
    case addSuborder
    case storeList
    case getDistance
    case getSaleCardList
    case getStoreWidthDistance
    case changePhone
    case evalOrder
    case getEatingCode
    case getMessage
    case getSiteInfomation
    case getSaleServiceType
    case getSalesServiceList
    case bindCard
    case getPosCardList
    case getConsumeInfo
    case getTypeLoop
    case consumeCard
    case salesService
    case getProductByPosNo
    case salesServiceNoImg
    case aliConfig
    case wechatPayResult
}

extension API {
    public var baseURL: String{
        #if DEBUG
            var hostURL = "http://whj503.xicp.net:41895"//测试环境
            hostURL = "https://www.coding88.com/store"//正式环境
            return hostURL
        #else
            let hostURL = "https://www.coding88.com/store"//正式环境
            return hostURL
        #endif
    }
    
    public var path: String {
        var tempPath : String
        switch self {
        case let .otherURL(newPath):
            return newPath
        case .sendSMS:
            tempPath = "/api/login/sendSms"
        case .register:
            tempPath = "/api/login/register"
        case .editUser:
            tempPath = "/api/user/address/editUser"
        case .login:
            tempPath = "/api/login/login"
        case .loginByThird:
            tempPath = "/api/login/loginByThird"
        case .forgetPass:
            tempPath = "/api/login/forgetPwd"
        case .bindUser:
            tempPath = "/api/login/bindUser"
        case .homePage:
            tempPath = "/api/product/getIndex"
        case .addAddress:
            tempPath = "/api/user/address/add"
        case .addressList:
            tempPath = "/api/user/address/find"
        case .setAddressDefault:
            tempPath = "/api/user/address/setIsDefault"
        case .editAddress:
            tempPath = "/api/user/address/addressEdit"
        case .deleteAddress:
            tempPath = "/api/user/address/del"
        case .changePass:
            tempPath = "/api/user/address/editPassword"
        case .changeInfo:
            tempPath = "/api/user/address/editUser"
        case .cancleOrder:
            tempPath = "/api/orderinfo/cancelOrder"
        case .createOrderByProduct:
            tempPath = "/api/orderinfo/createOrderByProduct"
        case .createOrderByShopcar:
            tempPath = "/api/orderinfo/createOrderByShopcar"
        case .getOrderDetail:
            tempPath = "/api/orderinfo/getOrderDetail"
        case .getOrderList:
            tempPath = "/api/orderinfo/getOrderList"
        case .addProductToShopCar:
            tempPath = "/api/product/addProductToShopCar"
        case .deleteProduct:
            tempPath = "/api/product/deleteProduct"
        case .getEvalByProduct:
            tempPath = "/api/product/getEvalByProduct"
        case .getProduct:
            tempPath = "/api/product/getProduct"
        case .getProductById:
            tempPath = "/api/product/getProductById"
        case .getShopCarByUser:
            tempPath = "/api/product/getShopCarByUser"
        case .getTypeList:
            tempPath = "/api/product/getTypeList"
        case .subProductToShopCar:
            tempPath = "/api/product/subProductToShopCar"
        case .buyRegular:
            tempPath = "/api/regular/buyRegular"
        case .cancelRegularOrder:
            tempPath = "/api/regular/cancelRegularOrder"
        case .editRegularOrderInfo:
            tempPath = "/api/regular/editRegularOrderInfo"
        case .getRegularDetail:
            tempPath = "/api/regular/getRegularDetail"
        case .getRegularOrder:
            tempPath = "/api/regular/getRegularOrder"
        case .getRegularOrderList:
            tempPath = "/api/regular/getRegularOrderList"
        case .createOrderByRegular:
            tempPath = "/api/regular/createOrderByRegular"
        case .getConfig:
            tempPath = "/api/index/getConfig"
        case .addSuborder:
            tempPath = "/api/regular/addSuborder"
        case .storeList:
            tempPath = "/api/index/getStore"
        case .getDistance:
            tempPath = "/api/index/getDistance"
        case .getSaleCardList:
            tempPath = "/api/user/getSaleCardList"
        case .getPosCardList:
            tempPath = "/api/pos/getCardList"
        case .getStoreWidthDistance:
            tempPath = "/api/index/getStoreWidthDistance"
        case .changePhone:
            tempPath = "api/login/changeBindUser"
        case .evalOrder:
            tempPath = "/api/orderinfo/evalOrder"
        case .getEatingCode:
            tempPath = "/api/orderinfo/getEatingCode"
        case .getMessage:
            tempPath = "/api/index/getMessage"
        case .getSiteInfomation:
            tempPath = "/api/index/getSiteInfomation"
        case .getSaleServiceType:
            tempPath = "/api/index/getSaleServiceType"
        case .getSalesServiceList:
            tempPath = "/api/orderinfo/getSalesServiceList"
        case .bindCard:
            tempPath = "/api/pos/bindCard"
        case .getTypeLoop:
            tempPath = "/api/product/getTypeLoop"
        case .getConsumeInfo:
            tempPath = "/api/pos/getTypeLoop"
        case .consumeCard:
            tempPath = "/api/pos/consumeCard"
        case .salesService:
            tempPath = "/api/orderinfo/salesService"
        case .getProductByPosNo:
            tempPath = "/api/product/getProductByPosNo"
        case .salesServiceNoImg:
            tempPath = "/api/orderinfo/salesServiceNoImg"
        case .aliConfig:
            tempPath = "/api/index/alipayConfig"
        case .wechatPayResult:
            tempPath = "/api/orderinfo/getPosPay"
            
            
        default:
            tempPath = ""
        }
        
        return baseURL + tempPath
    }
    
    public var method: HTTPMethod {
        switch self {
        case  .sendSMS, .register, .editUser, .login, .loginByThird, .forgetPass, .bindUser, .addAddress, .setAddressDefault, .editAddress, .changePass, .changeInfo, .createOrderByShopcar, .createOrderByProduct, .addProductToShopCar, .deleteProduct, .getEvalByProduct, .getProduct, .getProductById, .getShopCarByUser, .subProductToShopCar, .buyRegular, .createOrderByRegular, .deleteAddress, .getSaleCardList, .changePhone, .evalOrder, .bindCard, .salesService, .consumeCard:
            return .post
        default:
            return .get
        }
    }
    
    public var encoding : ParameterEncoding {
//        switch self.method {
//        case .post:
//           return JSONEncoding.default
//        default:
           return URLEncoding.httpBody
//        }
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
   
        
}
