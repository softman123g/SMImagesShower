//
//  SMNetworkLoad.swift
//  TakePictureAndRecordVideo
//
//  Created by softman on 16/1/27.
//  Copyright © 2016年 softman. All rights reserved.
//
//  Contact me: softman123g@126.com
//  Or Star me: https://github.com/softman123g/SMImagesShower

import UIKit

class SMNetworkLoad: NSOperation,NSURLConnectionDelegate, NSURLConnectionDataDelegate{
    // MARK: Prepories
    var progressBlock:((Double)->Void)? //数据加载进度处理
    private var totalDataLength:Int64 = 0 //总长度
    private var connection:NSURLConnection? //连接
    private var dataSource:NSMutableData = NSMutableData() //存放数据
    private var loadedLength:Int = 0 //已载入的数据长度
    private var isSuccess = false //是否加载成功
    
    private var resultBlock:(()->Void)?
    private var error:NSError?
    
    // MARK: Super
    
    init(url:NSURL, success:(data:NSMutableData)->Void, failure:(error: NSError?)->Void){
        super.init()
        let request = NSMutableURLRequest(URL: url)
        request.networkServiceType = .NetworkServiceTypeBackground
        self.connection = NSURLConnection(request: request, delegate: self, startImmediately: false)
        self.connection?.setDelegateQueue(NSOperationQueue.currentQueue())
        
        resultBlock = { [unowned self] ()->Void in
            if self.isSuccess {
                success(data: self.dataSource)
            } else {
                failure(error: self.error)
            }
        }
        self.connection?.start()
    }
    
    override func cancel() {
        self.connection?.setDelegateQueue(nil)
        self.connection?.cancel()
    }
    
    // MARK: Delegate
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.totalDataLength = max(response.expectedContentLength,1)
    }
    
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.loadedLength += data.length
        self.dataSource.appendData(data)
        //更新进度
        if Int64(loadedLength) < totalDataLength && progressBlock != nil {
            progressBlock?(Double(loadedLength) / Double(totalDataLength))
        }
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        isSuccess = true
        self.resultBlock?()
        self.cancel()
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        self.error = error
        self.resultBlock?()
        self.cancel()
    }
}
