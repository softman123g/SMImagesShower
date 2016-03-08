# SMImagesShower
一个简单的图片显示预览器，图片浏览器，图片显示器，图片预览器。使用Swift实现。

A simple images shower. Images shower, pictures shower, image brower, pictures brower ...
Used Swift.

##Features
1. Support screen Portrait/Landscape.  支持横屏竖屏
2. Use a little storage.  存储空间小。复用ScrollView，当图片很多时，依旧不耗费存储空间
3. Display page number at the bottom.  底部页码显示
4. Double click to zoom in/out image.  双击图片放大/缩小
5. Pinch to zoom in/out image.  双指放大/缩小图片
6. Long press to save the image to photo album.  长按保存图片到相册
7. Click to hide the image.  单击隐藏图片

See like 效果图：

![ImagesShower](/ImagesShower.gif)

##How to use?
1. Copy 'SMImagesShower/' to your projects.拷贝'SMImagesShower/'到你的项目中。
2. Then add 'SMImagesShower-Bridging-Header.h' to your 'Objective-C Bridging Header' (click TARGETS, then 'Building Settings' --> 'Swift Compiler-Code Generation'--> 'Object-C Bridging Header')。

	Or, import 'SMImagesShower-Bridging-Header.h' to your project header file.
	
		#import "SupportLib/HUD/MBProgressHUD.h"

	将'SMImagesShower-Bridging-Header.h'添加到你项目的'Objective-C Bridging Header'中（单击项目的TATGETS，选择'Building Settings' --> 'Swift Compiler-Code Generation'--> 'Object-C Bridging Header'）
	
	或者，直接将'SMImagesShower-Bridging-Header.h'引入到你自己的头文件中。即在你自己的头文件中，添加如下代码：
		
		#import "SupportLib/HUD/MBProgressHUD.h"
3. Finally, present the view controller. 使用下面的代码直接调用。

		let imagesShowerViewController = new SMImagesShowerViewController()
		imagesShowerViewController.prepareDatas(imageUrls, currentDisplayIndex: 0)
		presentViewController(imagesShowerViewController, animated:true, completion:nil)
		
	eg:
	
		let imageUrls = ["http://image.photophoto.cn/m-6/Animal/Amimal%20illustration/0180300271.jpg",
            "http://img4.3lian.com/sucai/img6/230/29.jpg",
            "http://img.taopic.com/uploads/allimg/130501/240451-13050106450911.jpg",
            "http://pic1.nipic.com/2008-08-12/200881211331729_2.jpg",
            "http://a2.att.hudong.com/38/59/300001054794129041591416974.jpg"]
        let imageShowViewController = SMImageShowerViewController()
        do {
            try imageShowViewController.prepareDatas(imageUrls, currentDisplayIndex: 0)
        } catch {
            print("图片显示出错：第一个图片指定索引错误")
            return
        }
        presentViewController(imageShowViewController, animated: true, completion: nil)

##About Me
Contact me: softman123g@126.com

or Star me: https://github.com/softman123g/SMImagesShower


