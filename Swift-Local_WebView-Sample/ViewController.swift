//
//  ViewController.swift
//  Swift-Local_WebView-Sample4 Basic Ver.0.0.0
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

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    //定数定義 @class ViewController______________________________
    
    @IBOutlet weak var viewFrame: WKWebView? = nil
    var webView = WKWebView()
    let kScheme = "native://";
    
    //______________________________ 定数定義 @class ViewController

    override func loadView() {
        super.loadView()
        
        //定数定義 @func loadView ______________________________
        
        var configuration: WKWebViewConfiguration
        let preLoadJSFilePath: String = "./LocalResouces/default/common/js/PreLoad"
        let preLoadJSFileExt: String = "js"
        
        //______________________________ 定数定義 @func loadView
        
        
        // ネイティブ(Swiftコード)から渡された値を取得するプロトコルの登録
        URLProtocol.registerClass(GetNativeValsProtocol.self)
        
        // ## ドキュメント読み込み開始時に JavaScript を実行する
        let preLoadJS = loadUserScriptFile(path: preLoadJSFilePath, ext: preLoadJSFileExt)
        configuration = setUserScript(jsSource: preLoadJS as String)
        
//        let preLoadJSFunction: String = "redHeader()"
//        configuration = setUserScript(jsSource: preLoadJSFunction)
        
        webView.uiDelegate = self
        //webView.navigationDelegate = self
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        //self.view = self.webView

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //定数定義 @func viewDidLoad ______________________________
        // 外部URLを読み込む場合 #func loadAddressURL
        //let targetURL = "http://www.yahoo.co.jp"  //使わないのでコメントアウト
        // ローカルリソースを読み込む場合  #func loadLocalFileURL
        let localPath: String = "./LocalResouces/default/index"
        let fileExt: String = ".html"
        //______________________________ 定数定義 @func viewDidLoad
        
        // 画面表示
        // 親ViewにWKWebViewを追加
        view.addSubview(webView)
        // WKWebViewを最背面に移動・・・無くすとStoryBoard上のオブジェクトが表示されなくなる
        view.sendSubview(toBack: webView)
        
        print("\n初期化終了______________________________>>>\n")
        
        // ページのロード
        // 外部URLにアクセス→停止中
        //loadWebURL(WebURL: targetURL)
        // ローカルのindex.htmlを読み込む
        loadLocalURL(path: localPath, ext: fileExt)
        
    }
    
    
    // 外部URLを読み込む場合
    private func loadWebURL(webURL: String) {
        let requestURL: URL = NSURL(string: webURL)! as URL
        let req = URLRequest(url: requestURL as URL)   // 外部のURLを読み込む場合（httpの場合Info.plistにNSAppTransportSecurityの指定が必要）
        webView.load(req)
    }
    
    // ローカルリソースを読み込む場合
    private func loadLocalURL(path: String, ext: String) {
        let targetURL: URL = Bundle.main.url(forResource: path, withExtension: ext)!
        let req = URLRequest(url: targetURL as URL)
        print("String index.html path=「\(String(describing: path))」\n______________________________\n")
        webView.load(req)
    }
    
    
     // # JavaScriptとネイティブの連携
     // jsファイルのUserScriptをロードする
    //
    private func loadUserScriptFile(path: String, ext: String) -> NSString {
        var jsSource = ""
        let targetURL: URL = Bundle.main.url(forResource: path, withExtension: ext)!
        if let data = NSData(contentsOf: targetURL as URL){
            jsSource = String(NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)!)
        }
        return jsSource as NSString
    }
    
     // ## JavaScriptからネイティブを呼び出す
     //
     private func setUserScript(jsSource: String)-> WKWebViewConfiguration {
        let userScript = WKUserScript(source: jsSource as String, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let controller = WKUserContentController()
        controller.addUserScript(userScript)
     
        // JavaScript側の実行結果などを受け取りたい場合はコールバックを設定します
        controller.add(self as WKScriptMessageHandler, name: "callbackHandler")
    
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        
        return configuration
     }
     
     // ## ネイティブからJavaScriptを呼び出す
     // - 毎回evalすることになるし全部文字列にしないといけないのがアレだけど…
     // - JavaScriptの実行結果を扱いたい場合にはcompletionHandlerを指定してやる（省略可能）
    //
     private func evaluateJs(_ script: String) {
     webView.evaluateJavaScript(script, completionHandler: {(result: Any?, error: Error?) in
     //
     print("evaluateJs\n script=「\(String(describing: script))」,\n result=「\(String(describing: result))」,\n error=「\(String(describing: error))」\n______________________________\n")
     })
     }
    
    
    // WKScriptMessageHandlerに必須の関数
    internal func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // addScriptMessageHandlerで指定したコールバック名を判断して処理を分岐させることができます
        if(message.name == "callbackHandler") {
            print("JavaScript is sending a message \(message.body)")        }
    }
    
    // WKWebViewのロード
    //
    func webView(_ webView: WKWebView,
                          decidePolicyFor navigationAction: WKNavigationAction,
                          decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        print("「＠func webView」\n______________________________\n")
        var policy = WKNavigationActionPolicy.allow
        if let url = navigationAction.request.url?.absoluteString {
            print("String url=「\(String(describing: url))」\n______________________________\n")
            if url.hasPrefix(kScheme) {
                // ### とりあえず JavaScript を実行する
                // ただ JavaScript を実行すればいいのであれば evaluateJavaScript を使うのが簡単です。でもこの方法ではドキュメントロード時に実行する、といったことができません。
                evaluateJs("addTextNode('\(url)');")
                evaluateJs("document.querySelector('h1').style.color = 'blue';")
                evaluateJs("document.getElementById('hogehoge').innerHTML = '';")
                
                /* テスト
                // ### Swift3 でWKWebViewからpostしたフォームの値を取得する。入力した内容を保持するということがやりたい。
                // https://trueman-developer.blogspot.jp/2016/10/swift3-wkwebviewpost.html
                
                // テスト１ nameフィールドの値を取得
                evaluateJs("document.form1.name.value")
                // テスト２ // passwordフィールドの値を取得
                evaluateJs("document.form1.password.value")
                */
                
                policy = WKNavigationActionPolicy.cancel  // ページ遷移を行わないようにcancelを返す
            }
        }
        decisionHandler(policy)
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
