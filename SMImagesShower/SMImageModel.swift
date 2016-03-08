//
//  SMImageModel.swift
//  TakePictureAndRecordVideo
//
//  Created by softman on 16/1/25.
//  Copyright © 2016年 softman. All rights reserved.
//
//  Contact me: softman123g@126.com
//  Or Star me: https://github.com/softman123g/SMImagesShower

import UIKit

/**
    图片信息
 */
class SMImageModel: NSObject {
    
    // MARK: Properties
    
    private var deviceSize:CGSize {//设备屏幕的大小
        get {
            return UIScreen.mainScreen().bounds.size
        }
    }
    var image:UIImage?//图片信息
    var url:NSURL? //图片地址
    var index:Int = 0 //图片索引
    /** 
        适配后图片大小
        图片将根据屏幕的大小来调整自身的size，保证和屏幕比例适配
    */
    var adaptedImageSize:CGSize {
        if let _image = image {
            let imageWidth = _image.size.width
            let imageHeight = _image.size.height
            //原图比屏幕宽高都小，则直接返回图片原大小
            if imageWidth <= deviceSize.width && imageHeight <= deviceSize.height {
                return _image.size
            }
            let scale = (imageWidth/deviceSize.width - imageHeight/deviceSize.height)
            if scale > 0 { //宽度相对更宽，则改变宽度，压缩宽度成屏幕大小，高度适当等比例改变
                let adaptedHeight = imageHeight * (deviceSize.width / imageWidth)
                return CGSizeMake(deviceSize.width, adaptedHeight)
            } else {
                let adaptedWidth = imageWidth * (deviceSize.height / imageHeight)
                return CGSizeMake(adaptedWidth, deviceSize.height)
            }
        }
        return CGSizeZero
    }
    var hasLoadFromHttp:Bool = false //图片是否已经从网络加载
    
    // MARK: Functions -- Static
    
    /**
        根据图片URL 和 图片s 初始化
    */
    class func initImages(images:[UIImage], imageURLs:[String]) -> [SMImageModel]{
        let maxCount = max(images.count, imageURLs.count)
        var imageModels:[SMImageModel] = []
        for i in 0 ..< maxCount {
            let imageModel = SMImageModel()
            imageModel.image = i < images.count ? images[i] : nil
            imageModel.url = i < imageURLs.count ? NSURL(string: imageURLs[i]) : nil
            imageModel.index = i
            imageModel.hasLoadFromHttp = false
            imageModels.append(imageModel)
            //初始化为默认图片
            if (imageModel.image == nil) {
                imageModel.image = UIImage(named: "default_img")
            }
        }
        return imageModels
    }
}
