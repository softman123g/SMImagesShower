//
//  SMImageBrowerViewController.swift
//  TakePictureAndRecordVideo
//
//  Created by softman on 16/1/25.
//  Copyright © 2016年 softman. All rights reserved.
//
//  Contact me: softman123g@126.com
//  Or Star me: https://github.com/softman123g/SMImagesShower
//
//  原理：
//  在一个大ScrollView中，嵌入两个小ScrollView，以达到复用的目的。小ScrollView负责从网络加载图片。
//  并且小ScrollView负责图片的点击放大等的处理，而大ScrollView负责翻页等的效果。
//
//  优势：
//  1.支持横屏竖屏
//  2.存储空间小。使用复用ScrollView，当图片很多时，依旧不耗费存储空间
//  3.支持底部页码显示
//  4.支持双击图片放大/缩小
//  5.支持双指放大/缩小图片
//  6.支持长按保存图片到相册
//  7.支持单击隐藏图片
//  
//  使用方法：
//    let imageUrls = ["http://image.photophoto.cn/m-6/Animal/Amimal%20illustration/0180300271.jpg",
//    "http://img4.3lian.com/sucai/img6/230/29.jpg",
//    "http://img.taopic.com/uploads/allimg/130501/240451-13050106450911.jpg",
//    "http://pic1.nipic.com/2008-08-12/200881211331729_2.jpg",
//    "http://a2.att.hudong.com/38/59/300001054794129041591416974.jpg"]
//    let imagesShowViewController = SMImagesShowerViewController()
//    do {
//        try imagesShowViewController.prepareDatas(imageUrls, currentDisplayIndex: 0)
//    } catch {
//        print("图片显示出错：第一个图片指定索引错误")
//        return
//    }
//    presentViewController(imagesShowViewController, animated: true, completion: nil)



import UIKit

public class SMImagesShowerViewController: UIViewController, UIScrollViewDelegate, LongPressGestureRecognizerDelegate{
    // MARK: Properties
    private let pageScaleRadio = CGFloat(9.8/10)//页码位置垂直比例
    private let pageLabelHeight = CGFloat(15.0)//页码高度

    var currentImageIndex:Int = 0 //当前图片索引，从0开始 pre
    var currentPageNumber:Int = 0 //当前页码，从0开始，真正滑动后展现的页码 after
    var prePointX:Float = 0.0 //scrollview 滑过的上一个点x坐标
    var currentSubScrollView:SMImageScrollView?//当前滑动的子ScrollView
    
    var imageModels:[SMImageModel] = [] //所有图片信息的model数组
    var imageScrollViews:[SMImageScrollView] = [] //用于复用的子ScrollView
    var scrollView:UIScrollView!//大ScrollView
    var pageLabel:UILabel = UILabel()//页码
    
    // MARK: Super
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView = UIScrollView(frame: self.view.bounds)
        self.scrollView.backgroundColor = UIColor.blackColor()
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.alwaysBounceVertical = false
        self.scrollView.pagingEnabled = true //翻页效果，一页显示一个子内容
        self.scrollView.delegate = self
        self.addSubScrollView()//增加子ScrollView
        self.view.addSubview(self.scrollView)
        
        self.pageLabel.textAlignment = .Center
        self.pageLabel.font = UIFont.systemFontOfSize(12)
        self.pageLabel.textColor = UIColor.whiteColor()
        self.pageLabel.text = self.pageText()
        self.view.addSubview(self.pageLabel)
        
        self.addGesture()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override public func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All //支持横竖屏
    }
    //第一次调用，以及横竖屏切换的时候，将重新布局
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.scrollView.frame = self.view.bounds
        var size = self.scrollView.bounds.size
        size.width *= CGFloat(self.imageModels.count)
        self.scrollView.contentSize = size
        var frame = self.view.bounds
        frame.origin.y = frame.size.height * pageScaleRadio - pageLabelHeight
        frame.size.height = pageLabelHeight
        self.pageLabel.frame = frame
        
        //布局scrollview内部的控件
        for imageScrollView in self.imageScrollViews {
            if let _imageModel = imageScrollView.imageModel {
                var frame = self.scrollView.bounds
                frame.origin.x = CGFloat(_imageModel.index) * frame.size.width
                imageScrollView.frame = frame
                imageScrollView.refleshSubview()
            }
        }
        
        currentSubScrollView?.resetScale(true)
        self.scrollView.setContentOffset((currentSubScrollView?.frame.origin)!, animated: true)
    }
    // MARK: Self Functions
    
    //准备数据相关，应该在展现前调用  currentDisplayIndex,从0开始
    public func prepareDatas(imageUrls:[String], currentDisplayIndex:Int) throws {
        guard currentDisplayIndex >= 0 && currentDisplayIndex < imageUrls.count else {
            throw SMImageShowerError.ArrayOutOfBounds
        }
        imageModels.appendContentsOf(SMImageModel.initImages([], imageURLs: imageUrls))
        currentPageNumber = currentDisplayIndex
        currentImageIndex = -1 //表示之前还没有显示
    }
    
    func addSubScrollView(){
        //当图片数大于2张时，使用2个UIScrollView重用。之所以用2个，因为翻页的时候用页面上只会存在2个页面
        for  _ in 0 ..< min(2, self.imageModels.count) {
            let imageScrollView = SMImageScrollView(frame: self.scrollView.bounds)
            imageScrollView.longpressGrstureRecorgnizerDelegate = self
            self.scrollView.addSubview(imageScrollView)
            self.imageScrollViews.append(imageScrollView)
        }
        self.setCurrentPage(currentPageNumber)
    }
    
    func pageText()->String{
        return String(format: "%d/%d", currentPageNumber+1, self.imageModels.count)
    }
    
    //设置指定索引位置的图片页
    func setCurrentPage(index:Int){
        if currentImageIndex == index || index >= self.imageModels.count || index < 0{
            return
        }
        //重置某一页，实现翻页后的效果
        currentImageIndex = index
        let imageScrollView = dequeueScrollViewForResuable()
        if let _imageScrollView = imageScrollView {
            currentSubScrollView = _imageScrollView
            if _imageScrollView.tag == index {
                return
            }
            currentSubScrollView?.resetScale(true)
            var frame = self.scrollView.bounds
            frame.origin.x = CGFloat(index) * (frame.size.width)//frame的x坐标为当前scrollview的index倍，此时刚好是每一张图对应的在父ScrollView中的位置
            currentSubScrollView?.frame = frame
            currentSubScrollView?.tag = index
            currentSubScrollView?.imageModel = self.imageModels[index]
        }
    }
    
    //重用SMImageScrollView。当前界面显示页为第1个ScrollView，下1个页面(左滑或者右滑产生的下一个页面)则始终是第2个Scrollview
    func dequeueScrollViewForResuable() -> SMImageScrollView?{
        let imageScrollView = self.imageScrollViews.last
        if let _imageScrollView = imageScrollView {
            self.imageScrollViews.removeLast()
            self.imageScrollViews.insert(_imageScrollView, atIndex: 0)
        }
        return imageScrollView
    }
    
    func addGesture(){
        //添加单击返回手势
        let tap = UITapGestureRecognizer(target: self, action: "tapAction:")
        self.view.addGestureRecognizer(tap)
        //添加双击缩放手势
        let doubleTap = UITapGestureRecognizer(target: self, action: "doubleTapAction:")
        doubleTap.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap)
        
        //双击优先级比单击高
        tap.requireGestureRecognizerToFail(doubleTap)
    }
    //单击
    func tapAction(tap:UITapGestureRecognizer){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    //双击
    func doubleTapAction(doubleTap:UITapGestureRecognizer){
        self.currentSubScrollView?.responseDoubleTapAction()
    }
    
    //该方法在滑动结束时(或滑动减速结束)调用，触发重置当前应该显示哪个子ScrollView。参数scrollView是父ScrollView
    func pageDragOperate(scrollView:UIScrollView){
        let pointX = scrollView.contentOffset.x / scrollView.bounds.width
        //通过向上或向下取整，使得在滑动相对距离 超过一半 时才可以滑向下一页。也就是说什么时候滑动到下一页，是由自己决定的，而不是由别人决定的。
        if Float(scrollView.contentOffset.x) > prePointX {//手向左滑
            self.setCurrentPage(Int(ceil(pointX)))//取上整，取到下一个要显示的index值
        } else {//手向右滑
            self.setCurrentPage(Int(floor(pointX)))//取下整,取到上一个已显示的index值
        }
        
        prePointX = Float(scrollView.contentOffset.x)
        
        //显示图片的页码，这里实时显示，是用于在用户滑动的时候，能够实时的展现，而不像用户翻页图片的时候只有超过0.5的大小才翻页
        let int = Int(Float(pointX) + 0.5)
        if int != currentPageNumber {
            currentPageNumber = int
            self.pageLabel.text = self.pageText()
        }
    }
    
    // MARK: Delegate
    //会调用多次
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        if !self.scrollView.dragging {
            return
        }
        pageDragOperate(scrollView)
    }
    //会调用多次
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        pageDragOperate(scrollView)
        //将所有的子ScrollView都全部设置成原始的大小。因为可能用户当前界面中的子ScrollView放大了，所以滑动结束后，需要设置回原来的大小。也可以不设置，就看是不是需要这样的设置回原来大小的需求了。
        for imgsc in self.imageScrollViews{
            if imgsc != currentSubScrollView {
                imgsc.resetScale(true)
            }
        }
    }
    
    func longPressPresentAlertController(alertController: UIAlertController) {
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
}
enum SMImageShowerError:ErrorType {
    case ArrayOutOfBounds
}
