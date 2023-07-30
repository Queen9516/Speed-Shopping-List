//
//  MenuViewController.swift
//  Speed Shopping List
//
//  Created by Super on 9/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import GoogleMobileAds
import OneSignal

class MenuViewController: BaseViewController {
    

    var token = ""
    @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = true
        let isPremium = UserDefaults.standard.bool(forKey: UseCaseMessage.Purchase.premium)
        if !isPremium {
            bannerView.isHidden = false
            bannerView.adUnitID = "ca-app-pub-1558394739169751/4978387294"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
        } else {
            bannerView.isHidden = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        OneSignal.addTrigger("menu", withValue: "loaded")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func menuBtnTapped(_ sender: UIButton) {
        var vc = BaseViewController()
        switch (sender.tag) {
        case 6001: // My Lists
            vc = self.storyboard?.instantiateViewController(withIdentifier: "ShoppingListVC") as! ShoppingListVC
            break
        case 6002: // My Profile
            vc = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            if SharedPreference.getGuestData() == true {
                self.showAnnouncement(withMessage: "You need to login first.")
                return
            }
            break
        case 6003:  // My Wallet
            vc = self.storyboard?.instantiateViewController(withIdentifier: "MyWalletVC") as! MyWalletVC
            if SharedPreference.getGuestData() == true {
                self.showAnnouncement(withMessage: "You need to login first.")
                return
            }
            break
        case 6004:  // SSTX Market
            vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeedShopperMarketVC") as! SpeedShopperMarketVC
            if SharedPreference.getGuestData() == true {
                self.showAnnouncement(withMessage: "You need to login first.")
                return
            }
            break
        case 6005:  // Notifcations
            vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
            break
        case 6006:  // Coupon Codes
            vc = self.storyboard?.instantiateViewController(withIdentifier: "CoupanVC") as! CoupanVC
            if SharedPreference.getGuestData() == true {
                self.showAnnouncement(withMessage: "You need to login first.")
                return
            }
            break
            
        case 6007: // Help/FAQ
            vc = self.storyboard?.instantiateViewController(withIdentifier: "FAQVC") as! FAQVC
            
            break
        case 6008:  // Contact Us
            vc = self.storyboard?.instantiateViewController(withIdentifier: "ContactUSViewController") as! ContactUSViewController
            if SharedPreference.getGuestData() == true {
                self.showAnnouncement(withMessage: "You need to login first.")
                return
            }
            break            
        case 6009:  // Logout
            token = SharedPreference.getUserData().token
            print(token)
            self.callApiForLogout(token: token)
            return
        default:
            break
        }
        
        let vCount = MainClass.appDelegate.navController.viewControllers.count
        MainClass.appDelegate.navController.viewControllers.removeSubrange(Range(0..<vCount-1))
        MainClass.appDelegate.navController.pushViewController(vc, animated: true)
    }
    
    func callApiForLogout(token: String) {
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kToken] = token
        let actio_str = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kLogout
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
}

extension MenuViewController: WebServiceDelegate {
    //MARK:- Server Response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kLogout {
            guard let baseModel = Mapper<BaseModel<LoginModel>>().map(JSONObject: data) else {
                print("parsing error")
                
                self.showAnnouncement(withMessage: "Parser Error")
                return
            }
            if baseModel.isSuccess {
                self.showAnnouncement(withMessage: baseModel.msg! ,closer: {
                    SharedPreference.clearUserData()
                    SharedPreference.clearRadius()
                    self.logout()
                })
            }
            else {
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
}

struct NotificationName {
    static let userUpdateNotification = Notification.Name("ProfileUpdate")
}

extension MenuViewController: GADBannerViewDelegate {
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        self.bannerView.alpha = 0
        UIView.animate(withDuration: 1) {
            self.bannerView.alpha = 1
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        addBannerViewToView(bannerView)
    }
}
