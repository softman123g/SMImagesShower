//
//  SMImageScrollView.swift
//  TakePictureAndRecordVideo
//
//  Created by softman on 16/1/25.
//  Copyright © 2016年 softman. All rights reserved.
//
//  Contact me: softman123g@126.com
//  Or Star me: https://github.com/softman123g/SMImagesShower

import UIKit

protocol LongPressGestureRecognizerDelegate {//用于响应长按手势时展现UIAlertController
    func longPressPresentAlertController(alertController:UIAlertController)
}
/**
子ScrollView，存放单个图片，用于放大Zoom,下载图片等
*/
class SMImageScrollView: UIScrollView, UIScrollViewDelegate, MBProgressHUDDelegate {

    // MARK: Properties
    var longpressGrstureRecorgnizerDelegate:LongPressGestureRecognizerDelegate?
    
    //图片最大最小放大倍数
    private let minZoomScale = CGFloat(1.0)
    private let maxZoomScale = CGFloat(2.5)
    private var HUD:MBProgressHUD?
    private var needHUDAnimal:Bool = false
    // ScrollView要显示的图片View
    private var _imageView:UIImageView?
    var imageView:UIImageView {
        if _imageView == nil {
            _imageView = UIImageView()
            _imageView!.userInteractionEnabled = true
            _imageView!.contentMode = .ScaleAspectFit
            _imageView!.clipsToBounds = true
            self.addSubview(_imageView!)
            //初始化手势
            self.addGestureRecognizers()
            self.addHUD()
        }
        return _imageView!
    }
    //存储的图片显示的信息
    private var _imageModel:SMImageModel?
    var imageModel:SMImageModel?{
        get {
            return _imageModel
        }
        set {
            if let _newValue = newValue {
                _imageModel = _newValue
                self.imageView.image = _newValue.image
                var frame = self.bounds
                frame.size = _newValue.adaptedImageSize
                if _newValue.hasLoadFromHttp && needHUDAnimal == true{
                    needHUDAnimal = false
                    UIView.animateWithDuration(0.3, animations: {
                        self.imageView.frame = frame
                        self.scrollViewDidZoom(self)
                    })
                } else {//从网络加载图片
                    needHUDAnimal = false
                    self.imageView.frame = frame
                    self.scrollViewDidZoom(self)
                    self.loadImageFromHttp()
                }
            }
        }
    }
    //图片载入
    private var imageLoadNetwork:SMNetworkLoad?
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.alwaysBounceVertical = false
        self.maximumZoomScale = self.maxZoomScale
        self.minimumZoomScale = self.minZoomScale
        self.contentSize = self.bounds.size
        self.tag = -1 //用tag存放当前的页的页码
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Self Functions
    
    func addHUD(){
        HUD = MBProgressHUD(view: self)
        HUD!.mode = .Indeterminate
        HUD!.color = UIColor.clearColor()
        HUD!.delegate = self
        self.addSubview(HUD!)
    }
    func addGestureRecognizers() {
        //长按保存图片手势
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "longPressAction:"))
    }
    //长按Action
    func longPressAction(longPress:UILongPressGestureRecognizer){
        if longPress.state == .Began {
            if let _imageModel = self.imageModel {
                if !_imageModel.hasLoadFromHttp {//没有从网络加载，则直接返回
                    return
                }
            } else { return }
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let savaPictureAction = UIAlertAction(title: "保存图片", style: .Default, handler: { (action) -> Void in
                if let _image = self.imageView.image {
                    UIImageWriteToSavedPhotosAlbum(_image, self, "image:didFinishSavingWithError:contextInfo:", nil)
                }
            })
            let cancelAction = UIAlertAction(title: "取消", style: .Default, handler: { (action) -> Void in
                alertController.dismissViewControllerAnimated(false, completion: nil)
            })
            alertController.addAction(savaPictureAction)
            alertController.addAction(cancelAction)
            self.longpressGrstureRecorgnizerDelegate?.longPressPresentAlertController(alertController)
        }
    }
    //保存到相册的回调
    func image(image:UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject){
        if let _ = error {
            print("保存图片失败")
        } else {
            print("保存图片成功")
            SMToast.showText("图片已保存")
        }
    }
    /**从网络加载图片*/
    func loadImageFromHttp(){
        if let _imageModel = imageModel {
            if _imageModel.url != nil && !_imageModel.hasLoadFromHttp {
                //从网络加载图片
                HUD?.show(true)
                imageLoadNetwork?.cancel()
                imageLoadNetwork = SMNetworkLoad(url: _imageModel.url!,
                    success: { [unowned self] (data) -> Void in
                        self.requestResult(UIImage(data: data))
                    },
                    failure: {[unowned self] (error) -> Void in
                        self.requestResult(nil)
                })
            } else {
                HUD?.hide(true)
            }
        }
    }
    //请求结果处理
    func requestResult(image:UIImage?){
        if let _HUD = HUD {
            if _HUD.hidden {
                return
            }
        }
        if let _image = image {
            needHUDAnimal = true
            let _imageModel = imageModel
            _imageModel?.image = _image
            _imageModel?.hasLoadFromHttp = true
            self.imageModel = _imageModel  //需要检查下是否会进入死循环，若会，则需要使用copy()
        }
        HUD?.hide(true)
    }
    /** 恢复图片原始大小 */
    func resetScale(animated:Bool){
        self.setZoomScale(1.0, animated: animated)
    }
    //响应双击事件
    func responseDoubleTapAction(){
        //图片双击变大，或变小
        if self.minimumZoomScale <= self.zoomScale && self.zoomScale < self.maximumZoomScale {
            self.setZoomScale(self.maximumZoomScale, animated: true)
        } else {
            self.setZoomScale(self.minimumZoomScale, animated: true)
        }
    }
    //在横竖屏切换的时候，重新布局子ScrollView
    func refleshSubview() {
//        imageModel?.image = imageModel?.image
        let _imageModel = imageModel
        imageModel = _imageModel //为了触发set调用，重新布局ScrollView
    }
    
    // MARK: Delegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView //返回要放大的为图片
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        //图片缩放或放大时的位置的调整，确保居中
        let w = self.frame.size.width - self.contentInset.left - self.contentInset.right - imageView.frame.size.width
        let h = self.frame.size.height - self.contentInset.top - self.contentInset.bottom - imageView.frame.size.height
        var copyFrame = imageView.frame
        copyFrame.origin.x = max(w*0.5, 0)
        copyFrame.origin.y = max(h*0.5, 0)
        imageView.frame = copyFrame
    }
    
    func hudWasHidden(hud: MBProgressHUD!) {
        HUD?.progress = 0.0
    }
}
