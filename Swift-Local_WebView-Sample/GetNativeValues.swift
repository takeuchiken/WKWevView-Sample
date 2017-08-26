//
//  GetNativeValues.swift
//  Swift-Local_WebView-Sample
//
//  Created by 竹内健 on 2017/08/15.
//  Copyright © 2017年 竹内健. All rights reserved.
//
// GetNativeValues.swift
// ネイティブ(Swiftコード)から渡された値を取得する
import UIKit


private let HOOK_HOST = "native";


class GetPostDataProtocol: URLProtocol {
    // 以下のメソッドで所定のURLをフック
    override class func canInit(with request: URLRequest) -> Bool {
    //override class func canonicalRequestForRequest(request: URLRequest) -> URLRequest
        
        // "http://native/..."のリクエストをフック
        if request.url?.scheme == "http" && request.url?.host == HOOK_HOST {
            return true
        }
        return false
        
    }
    
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request;
    }
    
    override func startLoading() {
        // POSTデータを受け取る
        let _: Data? = request.httpBody
        //...
    }
}


class GetNativeValsProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        // "http://native/..."のリクエストをフック
        if request.url?.scheme == "http" && request.url?.host == HOOK_HOST {
            return true
        }
        return false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request;
    }
    

    override func startLoading() {
        _ = request.url
        // URLによってなにかレスポンスを返す（後述）
    }
    
    override func stopLoading() {
        // 特に何もしない
    }
    
// /*
    // ダミーを返す場合
    private func sendBackEmpty(str: String) {
        if let data: Data = str.data(using: String.Encoding.utf8) {
//            _ = [
//            "Content-Type": "text/plain",
//            "ContentLength": "\(data.count)",
//            ]
        let response = HTTPURLResponse(url: self.request.url!,
                                   mimeType: nil,
                                   expectedContentLength: 0,
                                   textEncodingName: nil)
        self.client?.urlProtocol(self,
                                 didReceive: response,
                                 cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
        self.client?.urlProtocol(self, didLoad: data)
        self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    // プレーンテキストを返す場合
    private func sendBackPlainText(str: String) {
        if let data: Data = str.data(using: String.Encoding.utf8) {
            _ = [
                "Content-Type": "text/plain",
                "ContentLength": "\(data.count)",
            ]
            let headers = [String:String]()
            let response = HTTPURLResponse(url : self.request.url!,
                                           statusCode: 200,
                                           httpVersion: "1.1",
                                           headerFields: headers)
            self.client?.urlProtocol(self,
                                     didReceive: response!,
                                     cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    
// */
    
}
