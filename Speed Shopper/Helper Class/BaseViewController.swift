//
//  BaseViewController.swift
//  Speed Shopping List
//
//  Created by mac on 10/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import CoreLocation

class BaseViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
            navBarAppearance.backgroundColor = UIColor.hexStringToUIColor(AppColor.blueColor)
            navigationController?.navigationBar.standardAppearance = navBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = UIColor.hexStringToUIColor(AppColor.blueColor)
        }
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    struct menuIconSize {
        static let width = 32
        static let height = 32
    }
    
    func setupBack(){
        let menuBtn = UIButton(frame: CGRect(x: 0, y: 0, width: menuIconSize.width, height: menuIconSize.height))
        menuBtn.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        menuBtn.addTarget(self, action: #selector(goToBack), for: .touchUpInside)
        let menuBarItem = UIBarButtonItem()
        menuBarItem.customView = menuBtn
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    
    func setupTransferHistory(){
        let menuBtn = UIButton(frame: CGRect(x: 0, y: 0, width: menuIconSize.width, height: menuIconSize.height))
        //        menuBtn.setImage(#imageLiteral(resourceName: "menuBar"), for: .normal)
        menuBtn.setTitle("History", for: .normal)
        menuBtn.addTarget(self, action: #selector(openTransferHistory), for: .touchUpInside)
        let menuBarItem = UIBarButtonItem()
        menuBarItem.customView = menuBtn
        self.navigationItem.rightBarButtonItem = menuBarItem
    }
    
    @objc func openTransferHistory(){
        let history = self.storyboard?.instantiateViewController(withIdentifier: "TransferSSTXVC") as! TransferSSTXVC
        self.navigationController?.pushViewController(history, animated: true)
    }
    
    func setupSearch(){
        let searchBtn = UIButton(frame: CGRect(x: 0, y: 0, width: menuIconSize.width, height: menuIconSize.height))
        searchBtn.setImage(#imageLiteral(resourceName: "search"), for: .normal)
        searchBtn.addTarget(self, action: #selector(showSearchScreen), for: .touchUpInside)
        let searchBarItem = UIBarButtonItem()
        searchBarItem.customView = searchBtn
        self.navigationItem.rightBarButtonItem = searchBarItem
    }
    
    @objc func showSearchScreen(){
        let search = self.storyboard?.instantiateViewController(withIdentifier: "SearchStoreVC") as! SearchStoreVC
        self.navigationController?.pushViewController(search, animated: true)
    }
    
    @objc func goToBack(){
        MainClass.appDelegate.navController.popViewController(animated: false)
    }
    
    func addTransitionEffect(){
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionFade//kCATransitionPush
        transition.subtype = kCATransitionFromLeft//kCATransitionFromRight
        transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
    }
    
    func goToHomePage(){
        
        let home = self.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        MainClass.appDelegate.navController = UINavigationController(rootViewController: home)
        MainClass.appDelegate.window?.rootViewController = MainClass.appDelegate.navController
        
    }
    
    func loginAsGuest() -> Bool{
        return true
    }
    
    func logout() {
        //var control = UIViewController()
        let topViewController = MainClass.appDelegate.window?.rootViewController?.childViewControllers
        for controller in topViewController! {
            _ = self.navigationController?.popToViewController(controller, animated: false)
        }
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        MainClass.appDelegate.navController = UINavigationController(rootViewController: loginVC)
        MainClass.appDelegate.window?.rootViewController = MainClass.appDelegate.navController
    }
    
    func showAnnouncement(withMessage msg: String, closer: (()-> Void)? = nil){
        let alertController =   UIAlertController(title: Utils.AppName() , message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (action:UIAlertAction!) in
            closer?()
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- Left side menu delegate method
    func hideMenuWith(controller: BaseViewController) {
        self.dismiss(animated: false, completion: nil)
    }
    
    //MARK:- Show & HIde navigation bar
    func showNavigationBar(){
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func hideNavigationBar(){
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func showAnnouncementYesAndNoOption(withMessage msg: String,yesTitle yTitle: String,noTitle nTitle: String, closer: (()-> Void)? = nil, closer1: (()-> Void)? = nil){
        let alertController =   UIAlertController(title: Utils.AppName() , message: msg, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: yTitle, style: .default) { (action:UIAlertAction!) in
            closer?()
        }
        
        let noAction = UIAlertAction(title: nTitle, style: .default) { (action:UIAlertAction!) in
            closer1?()
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func getCurrentLocationEnabledCondition() -> Bool{
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                print("No access")
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                return true
            }
        } else {
            print("Location services are not enabled")
            return false
        }
    }
}
extension UINavigationController{
    func setupNavgationPrefrence(){
        UINavigationBar.appearance().barTintColor = UIColor.hexStringToUIColor(AppColor.blueColor)
        UINavigationBar.appearance().backgroundColor = UIColor.hexStringToUIColor(AppColor.blueColor)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
            navBarAppearance.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
            navBarAppearance.backgroundColor = UIColor.hexStringToUIColor(AppColor.blueColor)
            navigationBar.standardAppearance = navBarAppearance
            navigationBar.scrollEdgeAppearance = navBarAppearance
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = UIColor.hexStringToUIColor(AppColor.blueColor)
        }
    }
}

extension UIView {

    func fadeIn(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 1 },
                       completion: { (value: Bool) in
                          if let complete = onCompletion { complete() }
                       }
        )
    }

    func fadeOut(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 0 },
                       completion: { (value: Bool) in
                           self.isHidden = true
                           if let complete = onCompletion { complete() }
                       }
        )
    }

}
