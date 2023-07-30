//
//  AppDelegate.swift
//  Speed Shopping List
//
//  Created by mac on 10/04/18.
//  Copyright © 2018 mac. All rights reserved.
//
import UIKit
import GoogleMaps
import CoreLocation
import UserNotifications
import FacebookCore
import FacebookLogin
import GooglePlaces
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleMobileAds
import OneSignal


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, OSSubscriptionObserver {

     var window: UIWindow?
     var navController = UINavigationController()
     static let google_map_key = "AIzaSyDvU85IMI4MDHseW_6yR7qhNpweoyuAcdk"
     static let OneSignal_APP_ID = "88eea516-8527-4bf9-a5a3-717221327c0b"
     var locManager = CLLocationManager()
     var currentLocation = CLLocation()
     // var isShoppingList = Bool()

     let notificationBlock: OSHandleNotificationActionBlock = { result in
         let notificationVC = MainClass.mainStoryboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
         MainClass.appDelegate.navController.pushViewController(notificationVC, animated: true)
     }
    
     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(AppDelegate.google_map_key)
        UINavigationController().setupNavgationPrefrence()
        
        // Initialize the Google Mobile Ads SDK.
        // Production AdMob app ID: ca-app-pub-1558394739169751
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        
        //google signIn
        assignGoogleSignInKeys()
        
        //START OneSignal initialization code
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]

        OneSignal.initWithLaunchOptions(launchOptions,
            appId: AppDelegate.OneSignal_APP_ID,
            handleNotificationAction: notificationBlock,
            settings: onesignalInitSettings)
        OneSignal.add(self as OSSubscriptionObserver)

        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification

        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        //bluedev
        let handler: OSHandleInAppMessageActionClickBlock = { action in
            var actionName = ""
            if let clickName = action?.clickName {
                print("~~~clickName string: ", clickName)
                actionName = clickName
            }
//            if let clickUrl = action?.clickUrl {
//                print ("~~~clickUrl string: ", clickUrl)
//            }
//            if let firstClick = action?.firstClick {
//                print("~~~firstClick bool: ", firstClick)
//            }
//            if let closesMessage = action?.closesMessage {
//                print("~~~closesMessage bool: ", closesMessage)
//            }
//            OneSignal.getTags({ tags in
//                var menu_name = "\(tags?["flag"] as? String ?? "")"
//                if (menu_name == "") {
//                    menu_name = actionName
//                }
//                print("~~~Tag User: " + menu_name)
//            }, onFailure: { error in
//                print("Error getting tags - \(error?.localizedDescription ?? "Error occured")")
//            })
            print("~~~Action Name: " + actionName)
            self.clearCaches()
            DispatchQueue.main.async {
                let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                var vc = BaseViewController()
                var flag = true
                switch (actionName) {
                case "my_list": // My Lists
                    vc = mainStoryboardIpad.instantiateViewController(withIdentifier: "ShoppingListVC") as! ShoppingListVC
                    break
                case "my_profile": // My Profile
                    vc = mainStoryboardIpad.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                    flag = self.checklogin()
                    break
                case "my_wallet":  // My Wallet
                    vc = mainStoryboardIpad.instantiateViewController(withIdentifier: "MyWalletVC") as! MyWalletVC
                    flag = self.checklogin()
                    break
                case "sstx_market":  // SSTX Market
                    vc = mainStoryboardIpad.instantiateViewController(withIdentifier: "SpeedShopperMarketVC") as! SpeedShopperMarketVC
                    flag = self.checklogin()
                    break
                case "notifications":  // Notifcations
                    vc = mainStoryboardIpad.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
                    break
                case "coupon_code":  // Coupon Codes
                    vc = mainStoryboardIpad.instantiateViewController(withIdentifier: "CoupanVC") as! CoupanVC
                    flag = self.checklogin()
                    break
                case "help": // Help/FAQ
                    vc = mainStoryboardIpad.instantiateViewController(withIdentifier: "FAQVC") as! FAQVC
                    break
                case "contact_us":  // Contact Us
                    vc = mainStoryboardIpad.instantiateViewController(withIdentifier: "ContactUSViewController") as! ContactUSViewController
                    flag = self.checklogin()
                    break
                case "login":
                    vc = mainStoryboardIpad.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    break
                default:
                    flag = false
                    break
                }
                if (flag) {
                    MainClass.appDelegate.navController.pushViewController(vc, animated: true)
                }
            }
        }
        OneSignal.setInAppMessageClickHandler(handler)
        //bluedev
        //END OneSignal initializataion code

        
        //Get Current lat long
        locManager.delegate = self
        locManager.requestWhenInUseAuthorization()
        locManager.desiredAccuracy =  kCLLocationAccuracyBest
        locManager.startUpdatingLocation()

        self.registerPushNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        GMSPlacesClient.provideAPIKey("AIzaSyBnOua9C7UhWtkhfJOK_ZAsj_4XPsXyYj8")
        GMSServices.provideAPIKey("AIzaSyBnOua9C7UhWtkhfJOK_ZAsj_4XPsXyYj8")
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        if let _ = launchOptions?[.remoteNotification] as? [String: AnyObject] {
            handleNotification()
        }
        
        IAPManager.shared.startObserving()
        return true
    }
    
    //bluedev
    func checklogin() -> Bool {
        var flag = false;
        if (SharedPreference.getUserData().userID != nil && SharedPreference.getUserData().emailVerify != "0" ) {
            flag = true;
        }
        return flag
    }
    
    // Clear Library / Caches
     func clearCaches(){
         do {
             try deleteLibraryFolderContents(folder: "Caches")
             print("~~~clear done")
         } catch {
             print("~~~clear Caches Error")
         }
     }
     
     
     
     //
     private func deleteLibraryFolderContents(folder: String) throws {
         let manager = FileManager.default
         let library = manager.urls(for: FileManager.SearchPathDirectory.libraryDirectory, in: .userDomainMask)[0]
         let dir = library.appendingPathComponent(folder)
         let contents = try manager.contentsOfDirectory(atPath: dir.path)
         for content in contents {
                          //If it is a snapshot, continue
             if(content == "Snapshots"){continue;}
             do {
                 try manager.removeItem(at: dir.appendingPathComponent(content))
                 print("~~~remove cache success:"+content)
             } catch where ((error as NSError).userInfo[NSUnderlyingErrorKey] as? NSError)?.code == Int(EPERM) {
                 print("~~~remove cache error:"+content)
                 // "EPERM: operation is not permitted". We ignore this.
                 #if DEBUG
                     //print("Couldn't delete some library contents.")
                 #endif
             }
         }
     }
    //bluedev
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("URL-2--->:", url.scheme as Any)
        var handled = Bool()
        if url.scheme == "share-speed-shopper" {
            handleDeepLink(with: url)
        } else {
            if (GIDSignIn.sharedInstance()?.handle(url) ?? true)
            {
                handled = GIDSignIn.sharedInstance().handle(url)
            }else if (FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: UIApplicationOpenURLOptionsKey.annotation))
            {
                handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: UIApplicationOpenURLOptionsKey.annotation)
            }
        }
        return handled
    }
    
    func handleNotification() {
        let notificationVC = MainClass.mainStoryboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        MainClass.appDelegate.navController.pushViewController(notificationVC, animated: true)
    }
    
    func handleDeepLink(with: URL) {
        let tokenString = with.host! as String
        print("DEEP LINK-->1:", with.path)
        print("DEEP LINK-->2:", with.lastPathComponent)
        let VC = MainClass.mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        VC.isDeepLink = true
        VC.shareToken = tokenString
        MainClass.appDelegate.navController.pushViewController(VC, animated: true)
    }

    
    //MARK: - CLLocation manager delegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //locManager.stopUpdatingLocation()
        self.currentLocation = locations.last!
        SharedPreference.sharedInstance.setCurrentLocation(lat: currentLocation.coordinate.latitude, long: currentLocation.coordinate.longitude)
        
        //print("Latitude = \(currentLocation.coordinate.latitude) And Longitude = \(currentLocation.coordinate.longitude)")
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error occur \n")
        print(error)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        self.locManager.requestAlwaysAuthorization()
        locManager.delegate = self
        //locManager.allowsBackgroundLocationUpdates = true
        if CLLocationManager.locationServicesEnabled() {

            switch CLLocationManager.authorizationStatus() {
            case .denied:
                print("Not enabled")
            case .notDetermined, .restricted:
                print("No access")
            case .authorizedAlways, .authorizedWhenInUse:
                print("Access")
                locManager.startUpdatingLocation()
                NotificationCenter.default.post(name: LocationNotificationName.userUpdateLocation, object: nil)
            }
        }else{
           // self.showAnnouncement(withMessage: "Location service not enable")
        }
    }
    func registerPushNotifications() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, error) in
                print("Permission granted: \(granted)")
                
                guard granted else { return }
                self.getNotificationSettings()
            }
        }
    }
    
    func getNotificationSettings() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                print("Notification settings: \(settings)")
                guard settings.authorizationStatus == .authorized else { return }
                
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
                // UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = Utils.tokenString(fromData: deviceToken)
        SharedPreference.storeDeviceToken(token)
        print("Device Token",token)
    }
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed!")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
//        let notiData = notification.request.content.userInfo["sstx"] as? NSDictionary
        let dic = userInfo["sstx"] as! NSDictionary
        if "\(String(describing: dic["notitype"]).replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: ")", with: ""))" == "buy" {
            let couponVc = MainClass.mainStoryboard.instantiateViewController(withIdentifier: "CoupanVC") as! CoupanVC
            MainClass.appDelegate.navController.pushViewController(couponVc, animated: true)
            return
        }
        if application.applicationState == .background {
            UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
            print("background")
        } else if application.applicationState == .active{
            print("active")
            print("========>>>>>>>>\n",userInfo)
        } else if application.applicationState == .inactive {
            print("inactive")
            print("========>>>>>>>>\n",userInfo)
        }
        let notificationVC = MainClass.mainStoryboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        MainClass.appDelegate.navController.pushViewController(notificationVC, animated: true)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, userInfo: [AnyHashable : Any], withCompletionHandler completionHandler: @escaping () -> Void)
    {
        UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1
        print("Notification in background \(response.notification.request.content.userInfo)")
        print("User information in Notification",userInfo)
        let notificationVC = MainClass.mainStoryboard.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
        MainClass.appDelegate.navController.pushViewController(notificationVC, animated: true)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        IAPManager.shared.stopObserving()
    }
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
          if !stateChanges.from.subscribed && stateChanges.to.subscribed {
             print("Subscribed for OneSignal push notifications!")
          }
        print("SubscriptionStateChange: \n\(String(describing: stateChanges))")

          //The player id is inside stateChanges. But be careful, this value can be nil if the user has not granted you permission to send notifications.
          if let playerId = stateChanges.to.userId {
            SharedPreference.savePushId(playerId)
          }
       }
}

@available(iOS 10.0, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(notification)
        
        
        completionHandler([.alert,.badge,.sound])
    }
}
func assignGoogleSignInKeys(){
    
    GIDSignIn.sharedInstance()
    GIDSignIn.sharedInstance().clientID = "28140651852-f4adfls8eelakkvsiesmc8gqnht33s9t.apps.googleusercontent.com"
    
}
