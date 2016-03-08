# SMImagesShower
一个简单的图片显示预览器，图片浏览器，图片显示器，图片预览器。使用Swift实现。

A simple images shower。Images shower, pictures shower, image brower, pictures brower ...
Used Swift.

##Features
1. 支持横屏竖屏
2. 存储空间小。复用ScrollView，当图片很多时，依旧不耗费存储空间
3. 支持底部页码显示
4. 支持双击图片放大/缩小
5. 支持双指放大/缩小图片
6. 支持长按保存图片到相册
7. 支持单击隐藏图片

效果图：
![ImagesShower](/ImagesShower.gif)

##How to use?
1. Copy 'SMImagesShower/' to your projects.拷贝'SMImagesShower/'到你的项目中。
2. Then add 'SMImagesShower-Bridging-Header.h' to your 'Objective-C Bridging Header' (click TARGETS, then 'Building Settings' --> 'Swift Compiler-Code Generation'--> 'Object-C Bridging Header')。

	Or, import 'SMImagesShower-Bridging-Header.h' to your project header file.
	
		#import "SupportLib/HUD/MBProgressHUD.h"

	将'SMImagesShower-Bridging-Header.h'添加到你项目的'Objective-C Bridging Header'中（单击项目的TATGETS，选择'Building Settings' --> 'Swift Compiler-Code Generation'--> 'Object-C Bridging Header'）
	
	或者，直接将'SMImagesShower-Bridging-Header.h'引入到你自己的头文件中。即在你自己的头文件中，添加如下代码：
		
		#import "SupportLib/HUD/MBProgressHUD.h"
3. Finally.

		let imagesShowerViewController = new SMImagesShowerViewController()
		imagesShowerViewController.prepare(imageUrls, currentDisplayIndex: 0)
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


