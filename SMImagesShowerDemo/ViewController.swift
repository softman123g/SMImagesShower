//
//  ViewController.swift
//  SMImagesShowerDemo
//
//  Created by softman on 16/3/2.
//  Copyright © 2016年 softman123g. All rights reserved.
//
//  Contact me: softman123g@126.com
//  Or Star me: https://github.com/softman123g/SMImagesShower


import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func showDemoClick(sender: UIButton) {
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
    }
}