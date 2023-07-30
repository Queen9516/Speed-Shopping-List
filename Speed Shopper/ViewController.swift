//
//  ViewController.swift
//  Speed Shopping List
//
//  Created by mac on 10/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
class ViewController: BaseViewController, WebServiceDelegate {
    
    var isDeepLink: Bool = false
    var shareToken: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        MainClass.appDelegate.navController = self.navigationController!
        self.hideNavigationBar()
        if isDeepLink {
            SharedPreference.saveSharetoken(shareToken)
            if SharedPreference.getUserData().userID == nil {
                goToLogin()
            }else if SharedPreference.getUserData().emailVerify == "0"  {
                goToLogin()
            } else {
                self.CallAPIForSharingUpdate(token: shareToken)
            }
        } else {
            if SharedPreference.getUserData().userID == nil {
                goToLogin()
            }else if SharedPreference.getUserData().emailVerify == "0"  {
                goToLogin()
            } else {
                self.goToHomePage()
            }
        }
        
    }
    
    func goToLogin(){
        
        let login = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        login.isDeepLink = isDeepLink
        self.navigationController?.pushViewController(login, animated: true)
        
    }
    
    func CallAPIForSharingUpdate(token: String)
    {
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        
        param[ApiConstant.ApiKey.kSharingToken] = token
        let act_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kshareShoppingListUdate + SharedPreference.getUserData().token
        
        Apimanager.sharedManager.callApiPostMethod(str_Action: act_str, param: param)
    }
    
    func createGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.yellow.cgColor,  UIColor.gray.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK:- Server Response
    
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kshareShoppingListUdate + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseListModel<ShoppingListModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "parser error")
                return
            }
            if baseModel.isSuccess {
                self.showAnnouncement(withMessage: baseModel.msg!) {
                    self.goToHomePage()
                }
            } else {
                self.showAnnouncement(withMessage: baseModel.msg!) {
                    self.goToHomePage()
                }
                
            }
        }
    }
    
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage:  String(describing: (data as AnyObject).userInfo[NSLocalizedDescriptionKey]!).replacingOccurrences(of: "}", with: "").components(separatedBy: "=").last! )
    }
}

