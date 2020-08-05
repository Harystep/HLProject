//
//  Extension.swift
//  ScenicCheck
//
//  Created by XinLiang on 2017/11/9.
//  Copyright © 2017年 xi-anyunjingzhiwei. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    
    //获取渐变层
    func gradientLayer(leftTopColor: UIColor, rightBottomColor: UIColor) -> CAGradientLayer {
        //定义渐变的颜色
        let gradientColors = [
            leftTopColor.cgColor,
            rightBottomColor.cgColor
        ]
        
        //定义每种颜色所在的位置
        let gradientLocations:[NSNumber] = [0.0, 1.0]
        
        //创建CAGradientLayer对象并设置参数
        self.colors = gradientColors
        self.locations = gradientLocations
        
        //设置渲染的起始结束位置（横向渐变）
        self.startPoint = CGPoint(x: 0, y: 0)
        self.endPoint = CGPoint(x: 1, y: 0)
        
        return self
    }
}

extension UIViewController {
    class func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return currentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return currentViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        return base
    }
}

extension UIDevice {
    public func isX() -> Bool {
        if UIScreen.main.bounds.size == CGSize.init(width: 375, height: 812) {
            return true
        }
        if UIScreen.main.bounds.size == CGSize.init(width: 414, height: 896) {
            return true
        }
        if UIScreen.main.bounds.size == CGSize.init(width: 414, height: 896) {
            return true
        }
        
        return false
    }
}

extension UIButton {
    
    func startCountDown() {
        self.isUserInteractionEnabled = false
        self.isEnabled = false
        
        var time = 60
//        let globalQueue = DispatchQueue.global()
        let timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags.init(rawValue: 0), queue: DispatchQueue.global())
        timer.schedule(deadline: .now(), repeating: .seconds(1))
        timer.setEventHandler { [weak self] in
            time -= 1
            if self == nil {
                timer.cancel()
                return
            }
            if time <= 0 {
                DispatchQueue.main.async {
                    self!.isUserInteractionEnabled = true
                    self!.isEnabled = true
                    self!.setTitle("获取验证码", for: UIControlState.normal)
                }
                timer.cancel()
            }else{
                DispatchQueue.main.async {
                    self!.setTitle("\(time)s", for: UIControlState.normal)
                }
                
            }
            
            
        }
        timer.resume()
    }
}

extension String {
    func transformToPinYin() -> String {
        
        let mutableString = NSMutableString(string: self)
        //把汉字转为拼音
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        //去掉拼音的音标
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        
        let string = String(mutableString)
        //去掉空格
        return string.replacingOccurrences(of: " ", with: "")
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func generateQRCode(imageWidth: CGFloat? = 300, logo: UIImage?) -> UIImage {
        //创建一个二维码的滤镜
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        
        // 恢复滤镜的默认属性
        qrFilter?.setDefaults()
        
        // 将字符串转换成
        let infoData =  self.data(using: .utf8)
        
        // 通过KVC设置滤镜inputMessage数据
        qrFilter?.setValue(infoData, forKey: "inputMessage")
        
        // 获得滤镜输出的图像
        let  outputImage = qrFilter?.outputImage
        
        // 设置缩放比例
        let scale = imageWidth! / outputImage!.extent.size.width;
        let transform = CGAffineTransform(scaleX: scale, y: scale)
        let transformImage = qrFilter!.outputImage!.transformed(by: transform)
        
        // 获取Image
        let image = UIImage(ciImage: transformImage)
        
        // 无logo时  返回普通二维码image
        guard let QRCodeLogo = logo else { return image }
        
        // logo尺寸与frame
        let logoWidth = image.size.width/4
        let logoFrame = CGRect(x: (image.size.width - logoWidth) /  2, y: (image.size.width - logoWidth) / 2, width: logoWidth, height: logoWidth)
        
        // 绘制二维码
        UIGraphicsBeginImageContextWithOptions(image.size, false, UIScreen.main.scale)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        // 绘制中间logo
        QRCodeLogo.draw(in: logoFrame)
        
        //返回带有logo的二维码
        let QRCodeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return QRCodeImage!
    }
}

