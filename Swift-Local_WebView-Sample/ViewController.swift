//
//  ViewController.swift
//  Swift-Local_WebView-Sample4 Improved Ver.0.0.0
//
//  Created by 竹内健 on 2017/08/15.
//  Copyright © 2017年 竹内健. All rights reserved.
//
// #iOSでガワネイティブ    Nov 3, 2014
// <https://tyfkda.github.io/blog/2014/11/03/ios-gawa-native.html>
// ## ドキュメント読み出し開始時、終了時に JavaScript を実行する
// <http://qiita.com/takecian/items/9baf7e2bd611aac4791d>
// ## WKWebViewを使ってNativeとWebページで情報をやり取りする方法
// <https://www.mitsue.co.jp/knowledge/blog/apps/201605/30_1721.html>
// ### Swift3 でWKWebViewからpostしたフォームの値を取得する。入力した内容を保持するということがやりたい。
// https://trueman-developer.blogspot.jp/2016/10/swift3-wkwebviewpost.html
// ## レイアウト設定
// <http://tech.blog.surbiton.jp/wkwebview/>
/*
 // # htmlの表示
 // - htmlは外部httpサーバから取ってくることもできるが、ここではリソースとしてアプリ内部に持ち、 それをWebViewで表示することにする。
 // - プロジェクトにResourcesとかいうグループを作り、その中にhtmlファイルを追加する （ここではindex.htmlにした）
 // - プロジェクトの設定のBuild Phases > Copy Bundle Resourcesで追加する （ドラッグドロップでプロジェクトにファイルを追加した場合には自動的に登録される？ので別途行う必要はないみたい）
 // - Bundle#url(forResource:withExtension)でリソースのパスを取得
 // - WKWebView#loadでWebViewに読み込む
 // - 外部のURLを読み込む場合（httpの場合Info.plistにNSAppTransportSecurityの指定が必要）
 */


import UIKit
//WebKit Frameworkをimportする
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    @IBOutlet weak var viewFrame: WKWebView? = nil
    
    
    private var webView = WKWebView()
    
    //定数定義 @class ViewController______________________________

    
    //______________________________定数定義 @class ViewController
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //定数定義 @func viewDidLoad______________________________
        // 外部URLを読み込む場合 #func loadAddressURL
        //let targetURL = "http://www.yahoo.co.jp"  //使わないのでコメントアウト
        // ローカルリソースを読み込む場合  #func loadLocalFileURL
        let localPath: String = "./LocalResouces/default/index"
        let fileExt: String = ".html"
        
        //______________________________定数定義 @func viewDidLoad
        
        // 画面表示
        // WebViewを全画面の大きさで追加
        self.webView.frame = view.bounds
        // 親ViewにWKWebViewを追加
        self.view.addSubview(self.webView)
        // WKWebViewを最背面に移動
        self.view.sendSubview(toBack: self.webView)
        // Autolayoutを設定
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        print("\n初期化終了______________________________>>>\n")

        // ページのロード
        // 外部URLにアクセス→停止中
        //loadAddressURL(siteUrl: targetURL)
        // ローカルのindex.htmlを読み込む
        self.loadLocalFileURL(path: localPath, ext: fileExt)
        
    }
    
    
    
    // 外部URLを読み込む場合
    private func loadAddressURL(siteUrl: String) {
        let requestURL: URL = NSURL(string: siteUrl)! as URL
        let req = URLRequest(url: requestURL as URL)   // 外部のURLを読み込む場合（httpの場合Info.plistにNSAppTransportSecurityの指定が必要）
        self.webView.load(req)
    }
    
    // ローカルリソースを読み込む場合
    private func loadLocalFileURL(path: String, ext: String) {
        let targetURL: URL = Bundle.main.url(forResource: path, withExtension: ext)!
        let req = URLRequest(url: targetURL as URL)
        print("String path=「\(String(describing: path))」\n______________________________\n")
        self.webView.load(req)
    }
    
    
     // # JavaScriptとネイティブの連携
     // ## JavaScriptからネイティブを呼び出す
    private func loadUserScriptFile(path: String, ext: String) -> NSString {
        var jsSource = ""
        let targetURL: URL = Bundle.main.url(forResource: path, withExtension: ext)!
        if let data = NSData(contentsOf: targetURL as URL){
            jsSource = String(NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)!)
        }
        return jsSource as NSString
    }
    
    
    /// クリック・アクション時、Post時に呼ばれるイベント
    internal func webView(_ webView: WKWebView,
                          decidePolicyFor navigationAction: WKNavigationAction,
                          decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url?.absoluteString {
            print("String url=「\(String(describing: url))」\n______________________________\n")
        }
    }
    
    
    

    // ## 戻るボタンの実装
    // TODO:調査
    //  前のページに戻るためには、goForward()ではなぜかうまく動かなかった。以下のようにするとうまく動く。
    //        _ = webView?.backForwardList.forwardItem?.url
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
