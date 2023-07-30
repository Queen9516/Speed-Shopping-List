//
//  TermsAndConditionVC.swift
//  Speed Shopping List
//
//  Created by info on 03/07/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import WebKit
import OneSignal
class TermsAndConditionVC: BaseViewController {

    @IBOutlet weak var webViewTerms: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showNavigationBar()
        self.setupBack()
        self.title = "Terms and Condition"
        webViewTerms.navigationDelegate = self
        let url = URL(string: ImportantLinks.TermsCondition)
        let requestObj = URLRequest(url: url! as URL)
        webViewTerms.load(requestObj)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        OneSignal.addTrigger("terms", withValue: "loaded")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TermsAndConditionVC: WKNavigationDelegate{
    
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
