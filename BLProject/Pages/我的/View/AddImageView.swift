//
//  AddImageView.swift
//  ScenicCheck
//
//  Created by XinLiang on 2017/11/29.
//  Copyright © 2017年 xi-anyunjingzhiwei. All rights reserved.
//

import UIKit

typealias AddNewImageActionBlock = (UITapGestureRecognizer) -> Void

class AddImageView: BaseView {
    
    var maxImagesCount = 3
    var canAddNewImage = true
    
    
    var imagesArray = Array<Any>.init(){
        didSet{
            print(imagesArray.count)
            _images.removeAll()
            if imagesArray.count >= maxImagesCount || !canAddNewImage {
                _images = imagesArray
            }else{
                _images = imagesArray+[#imageLiteral(resourceName: "tian j")]
            }
        }
    }
    
    var _images = Array<Any>.init()
    
    var selfWidth = 0.0
    var addNewImageBlack : AddNewImageActionBlock?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _images.append(#imageLiteral(resourceName: "tian j"))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        imagesArray.append(UIImage.init(named: "camera")!)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    func refreshImageList() -> Void {
        if selfWidth == 0 {
            return
        }
        self.removeAllSubviews()
        
        for imageIndex in 0..<_images.count {
            let tempImage = _images[imageIndex]
            let width = selfWidth / 3
            
            let imageBackView = UIView.init()
            self.addSubview(imageBackView)
            imageBackView.snp.makeConstraints({ (make) in
                    make.leading.equalTo(self).offset(Double.init(imageIndex % 3) * width)
                    make.top.equalTo(self).offset(Double.init(imageIndex / 3) * width)
                    make.width.height.equalTo(width)
                    if imageIndex == _images.count - 1 {
                        make.bottom.equalTo(self)
                    }
                })
            
            
            let tempImageView = UIImageView.init()
            tempImageView.backgroundColor = #colorLiteral(red: 0.9567790627, green: 0.9569163918, blue: 0.956749022, alpha: 1)
            imageBackView.addSubview(tempImageView)
            
            let imageObject = tempImage as! NSObject
            
            if imageObject.isKind(of: UIImage.self) {
                tempImageView.image = tempImage as? UIImage
            }else {
                tempImageView.kf.setImage(with: URL.init(string: tempImage as! String))
            }
            tempImageView.tag = imageIndex
            tempImageView.contentMode = .scaleAspectFill
            tempImageView.maskToBounds = true
            tempImageView.snp.makeConstraints({ (make) in
//                make.leading.top.equalTo(imageBackView)//.offset(10)
//                make.trailing.bottom.equalTo(imageBackView)//.offset(-10)
                make.centerY.equalTo(imageBackView)
                make.width.height.equalTo(imageBackView).offset(-20)
                switch imageIndex % 3 {
                case 0:
                    make.leading.equalTo(imageBackView)
                case 1:
                    make.centerX.equalTo(imageBackView)
                case 2:
                    make.trailing.equalTo(imageBackView)
                    
                default:
                    make.centerX.equalTo(imageBackView)
                }
            })
            if imageIndex == _images.count - 1 && imagesArray.count < maxImagesCount && canAddNewImage{
                tempImageView.image = #imageLiteral(resourceName: "tian j")
                tempImageView.contentMode = .center
            }
            tempImageView.isUserInteractionEnabled = true
            tempImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(addNewImage(sender:))))
            }
    }
    
    @objc func addNewImage(sender: UITapGestureRecognizer) -> Void {
        
        if (sender.view?.tag)! == _images.count - 1 && imagesArray.count < maxImagesCount  && canAddNewImage {
            self.addNewImageBlack?(sender)
        }else{
            XLPhotoBrowser.show(withImages: imagesArray, currentImageIndex: (sender.view?.tag)!)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selfWidth = Double(self.frame.size.width)
        self.refreshImageList()
    }
    
}
