//
//  PrivacyPolicy.swift
//  Speed Shopping List
//
//  Created by info on 03/07/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import WebKit
import OneSignal

class PrivacyPolicy: BaseViewController, WKNavigationDelegate {

    @IBOutlet weak var webViewPrivacy: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showNavigationBar()
        self.setupBack()
        self.title = "Privacy Policy"
        webViewPrivacy.navigationDelegate = self
        let url = URL(string: ImportantLinks.PrivacyPolicy)
        let requestObj = URLRequest(url: url! as URL)
        webViewPrivacy.load(requestObj)
        
      /*  if let pdf = Bundle.main.url(forResource: "PrivacyP_Dummy", withExtension: "docx", subdirectory: nil, localization: nil)  {
            let req = NSURLRequest(url: pdf)
            webViewPrivacy.loadRequest(req as URLRequest)
        }*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        OneSignal.addTrigger("policy", withValue: "loaded")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- WebView delegate Methods
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        JPHUD.hide()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        JPHUD.show()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        JPHUD.hide()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        JPHUD.hide()
    }
}

struct ImportantLinks {
    static let TermsCondition = "https://www.speedshopperapp.com/app/terms-and-conditions"
    static let PrivacyPolicy = "https://www.speedshopperapp.com/app/privacy-policies"

}
