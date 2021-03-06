//
//  ViewController.swift
//  Swift-Local_WebView-Sample4
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
    
    //@IBOutlet weak var viewFrame: UIWebView!    //WKWebViewとは関係がないStoryBoard上のオブジェクト
    @IBOutlet weak var viewFrame: WKWebView? = nil

    
    private var webView = WKWebView()
    
    //定数定義 @class ViewController______________________________
    let kScheme = "native://";

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

        let preLoadJSFilePath: String = "./LocalResouces/default/common/js/PreLoad"
        let preLoadJSFileExt: String = "js"
        //______________________________定数定義 @func viewDidLoad

        
        // ネイティブ(Swiftコード)から渡された値を取得するプロトコルの登録
        URLProtocol.registerClass(GetNativeValsProtocol.self)
        
        // ## ドキュメント読み込み終了時に JavaScript を実行する
        // <http://qiita.com/takecian/items/9baf7e2bd611aac4791d>
        //
        
        let preLoadJS = loadUserScriptFile(path: preLoadJSFilePath, ext: preLoadJSFileExt)
        self.excecUserScript(jsSource: preLoadJS)

        // 親ViewにWKWebViewを追加
        self.view.addSubview(webView)
        // レイアウトを設定（後述）
        self.setWebViewLayoutWithConstant(constant: 0.0)        
        
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

        self.webView.load(req)
    }
    
    
    /*
     // # JavaScriptとネイティブの連携
     // ## JavaScriptからネイティブを呼び出す
     JavaScriptからネイティブに対してなにか起動するにはURLをリクエストして、 WKNavigationDelegate#webView(_:decidePolicyFor:decisionHandler:)が呼び出されるのを利用する。
     スキーマをhttp://やhttps://じゃなくて独自のものにしておくことで判定する。 ここではnative://などとしてみる。
     
     // ### html(JavaScript)側：
     <p><a href="native://foo/bar.baz">Push me!</a></p>
     // ### ネイティブ(Swift)側：
     - 呼び出されたネイティブ側では、スキーム以外のURLの残り部分を使って自由に処理すればよい
     - 他にはMessage Handlerというものを使用する方法があるようです（WKUserContentController#add(_:name:)）
     
     */
    
    // UserScriptのjsファイルをページ読み込み時にロード・実行する場合
    // ## ドキュメント読み出し開始時、終了時に JavaScript を実行する
    // <http://qiita.com/takecian/items/9baf7e2bd611aac4791d>
    /*
     ほとんどのユースケースはこちらだと思いますがドキュメントロード時に JavaScript を実行したいです。
     その場合は WKUserScript を作って WKWebViewConfiguration を WKWebView のコンストラクタに渡す方法があります。
     こちらがシンプルでいいですね。
     */
    private func loadUserScriptFile(path: String, ext: String) -> NSString {
        var jsSource = ""
        let targetURL: URL = Bundle.main.url(forResource: path, withExtension: ext)!
        if let data = NSData(contentsOf: targetURL as URL){
            jsSource = String(NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)!)
        }
        return jsSource as NSString
    }
    
    private func excecUserScript(jsSource: NSString){
        let userScript = WKUserScript(source: jsSource as String, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        let controller = WKUserContentController()
        controller.addUserScript(userScript)
        
        // ## WKWebViewを使ってNativeとWebページで情報をやり取りする方法
        // <https://www.mitsue.co.jp/knowledge/blog/apps/201605/30_1721.html>
        // JavaScript側の実行結果などを受け取りたい場合はコールバックを設定します
        controller.add(self as WKScriptMessageHandler, name: "callbackHandler")
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        
    }

    
    // ## 戻るボタンの実装
    // TODO:調査
    //  前のページに戻るためには、goForward()ではなぜかうまく動かなかった。以下のようにするとうまく動く。
//        _ = webView?.backForwardList.forwardItem?.url
    
    

    // ## WKWebViewを使ってNativeとWebページで情報をやり取りする方法
    // <https://www.mitsue.co.jp/knowledge/blog/apps/201605/30_1721.html>
    internal func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // addScriptMessageHandlerで指定したコールバック名を判断して処理を分岐させることができます
        if(message.name == "callbackHandler") {
            print("JavaScript is sending a message \(message.body)")        }
    }
    
    
    //let kScheme = "native://";
    
    /// クリック・アクション時、Post時に呼ばれるイベント
    internal func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        var policy = WKNavigationActionPolicy.allow
        if let url = navigationAction.request.url?.absoluteString {
                                                                    print("String url=「\(String(describing: url))」\n______________________________\n")
            if url.hasPrefix(kScheme) {
                evaluateJs("addTextNode('\(url)');")
                evaluateJs("document.querySelector('h1').style.color = 'blue';")
// /*  テスト
                // ### とりあえず JavaScript を実行する
                // ただ JavaScript を実行すればいいのであれば evaluateJavaScript を使うのが簡単です。
                // でもこの方法ではドキュメントロード時に実行する、といったことができません。
                evaluateJs("document.getElementById('hogehoge').innerHTML = '';")
                
                // ### Swift3 でWKWebViewからpostしたフォームの値を取得する。入力した内容を保持するということがやりたい。
                // https://trueman-developer.blogspot.jp/2016/10/swift3-wkwebviewpost.html
                
                // テスト１ nameフィールドの値を取得
                evaluateJs("document.form1.name.value")
                // テスト２ // passwordフィールドの値を取得
                evaluateJs("document.form1.password.value")
// テスト */
                policy = WKNavigationActionPolicy.cancel  // ページ遷移を行わないようにcancelを返す
            }
        }
        decisionHandler(policy)
    }

    
    /*
     // ## ネイティブからJavaScriptを呼び出す
     - 毎回evalすることになるし全部文字列にしないといけないのがアレだけど…
     - JavaScriptの実行結果を扱いたい場合にはcompletionHandlerを指定してやる（省略可能）
     */
    
    private func evaluateJs(_ script: String) {
        webView.evaluateJavaScript(script, completionHandler: {(result: Any?, error: Error?) in
//
                                                                    print("evaluateJs\n script=「\(String(describing: script))」,\n result=「\(String(describing: result))」,\n error=「\(String(describing: error))」\n______________________________\n")
        })
    }
    

    
    /*
    // ## レイアウト設定
     http://tech.blog.surbiton.jp/wkwebview/
    WKWebViewは、StoryBoard上で割り付けることが出来ない。他のパーツをStoryBoard上でAutolayout設定している場合は、Swift上でWKWebViewにAutolayout設定を行う。ConstraintはWebViewに対して指定するのではなく、親Viewに対して指定することに注意が必要である。
    */
    private func setWebViewLayoutWithConstant(constant: CGFloat){
        // Delegateの設定
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        // WKWebViewを最背面に移動
        self.view.sendSubview(toBack: webView)
        // Autolayoutを設定
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraintsを一度削除する
        for constraint in self.view.constraints {
            let secondItem: WKWebView? = constraint.secondItem as? WKWebView
            if secondItem == self.webView {
                self.view.removeConstraint(constraint)
            }
        }
        // Constraintsを追加
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: webView, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: webView, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.topLayoutGuide, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: webView, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
        self.view.addConstraint(NSLayoutConstraint(item: self.bottomLayoutGuide, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: webView, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: constant))
        
        // ジェスチャーを許可
        self.webView.allowsBackForwardNavigationGestures = true

    }
    // 以上により、ViewController上でWKWebViewを表示させることができる。goBack()やreload()はUIWebViewと同様に使用できる。
    
    
    
    // ## 終了時
    // 親ビューから削除する。Autolayoutの値もリセットされる。
    override func viewDidDisappear(_ animated: Bool) {
        // JSからネイティブを呼び出し、結果を受け取るプロトコルを登録解除
        URLProtocol.unregisterClass(GetNativeValsProtocol.self)
        
        webView.removeFromSuperview()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
