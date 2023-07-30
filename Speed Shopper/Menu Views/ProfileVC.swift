//
//  ProfileVC.swift
//  Speed Shopping List
//
//  Created by mac on 14/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import SDWebImage
import StoreKit
import OneSignal

class ProfileVC: BaseViewController , WebServiceDelegate , UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    @IBOutlet weak var viewRounded: RoundViewClass!
    @IBOutlet weak var vwDetail: UIView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    // @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var imgProfileBackGround: UIImageView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnUpdateProfile: UIButton!
    @IBOutlet weak var btnEditProfile: UIButton!
    
    @IBOutlet weak var view_EditProfile: UIView!
    @IBOutlet weak var view_UpdateProfile: UIView!
    
    @IBOutlet weak var btnUpgrade: UIButton!
    @IBOutlet weak var btnRestore: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var tf_UpdatedName: UITextField!
    @IBOutlet weak var tf_UpdatedEmail: UITextField!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var earnedImg: UIImageView!
    
    var products: [SKProduct] = []
    
    var imageURlProf = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Profile"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.vwDetail.setTopCurve()
            self.view.bringSubview(toFront: self.viewRounded)
            //self.vwDetail.bringSubview(toFront: self.viewRounded)
        }
        self.btnCamera.alpha = 1.0
        tfName.isUserInteractionEnabled = false
        tfEmail.isUserInteractionEnabled = false
        callApiForGetProfile()
        disablTextFields()
        if (PremiumProducts.store.isProductPurchased(PremiumProducts.monthlySub) ||
                PremiumProducts.store.isProductPurchased(PremiumProducts.threeMonthsSub) ||
                PremiumProducts.store.isProductPurchased(PremiumProducts.sixMonthsSub) ||
                PremiumProducts.store.isProductPurchased(PremiumProducts.yearlySub)) {
            UserDefaults.standard.set(true, forKey: UseCaseMessage.Purchase.premium)
            //            btnUpgrade.isEnabled = false
            btnRestore.isEnabled = true
            
        } else {
            btnUpgrade.isEnabled = true
            btnRestore.isEnabled = false
            btnRestore.alpha = 0.5
            UserDefaults.standard.set(false, forKey: UseCaseMessage.Purchase.premium)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        tfName.isUserInteractionEnabled = false
        tfEmail.isUserInteractionEnabled = false
//        prepareToUpgrade(bool: false)
        OneSignal.addTrigger("profile", withValue: "loaded")
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        earnedImg.image = UIImage.gif(name: "earned")
    }
    
    func callApiForGetProfile(){
        Apimanager.sharedManager.webServiceDelegate = self
        let token = SharedPreference.getUserData().token
        let act_str = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kGetProfile + token!
        Apimanager.sharedManager.callApiGetMethod(str_Action: act_str)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        popupView.fadeOut(0.5, onCompletion: {
            print("you have earned SSTX")
        })
    }
    
    @IBAction func btnDeleteTapped(_ sender: UIButton) {
        let refreshAlert = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete your account?", preferredStyle: UIAlertControllerStyle.alert)

        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.updateAccountApi()
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            
        }))

        present(refreshAlert, animated: true, completion: nil)
    }
    
    //MARK:- Auto-Renewable Subscription
    
    @IBAction func btnUpgradeTapped(_ sender: UIButton) {
        prepareToUpgrade(bool: true)
    }
    
    func prepareToUpgrade(bool: Bool )
    {
        PremiumProducts.store.requestProducts { [weak self] success, products in
            guard let self = self else { return }
            guard success else {
                if bool {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: Utils.AppName(),
                                                                message: "Failed to load list of products. Please try again later",
                                                                preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                return
            }
            self.products = products!
            if bool {
                if !self.products.isEmpty {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Upgrade to Premium",
                                                                message: "Remove Google Ads from your list and enjoy the advanced features and options",
                                                                preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "$1.49 / Week",
                                                                style: .default,
                                                                handler: { action in
                                                                    self.purchaseItemIndex(index: "premium_weekly")
                                                                }))
                        
                        alertController.addAction(UIAlertAction(title: "$3.49 / Month",
                                                                style: .default,
                                                                handler: { action in
                                                                    self.purchaseItemIndex(index: "premium_monthly")
                                                                }))
                        
                        alertController.addAction(UIAlertAction(title: "$7.99 / 3 Months",
                                                                style: .default,
                                                                handler: { action in
                                                                    self.purchaseItemIndex(index: "premium_3months")
                                                                }))
                        
                        alertController.addAction(UIAlertAction(title: "$10.49 / 6 Months",
                                                                style: .default,
                                                                handler: { action in
                                                                    self.purchaseItemIndex(index: "premium_6months")
                                                                }))
                        
                        alertController.addAction(UIAlertAction(title: "$14.99 / Year",
                                                                style: .default,
                                                                handler: { action in
                                                                    self.purchaseItemIndex(index: "premium_yearly")
                                                                }))
                        
                        alertController.addAction(UIAlertAction(title: "Cancel",
                                                                style: .cancel,
                                                                handler: { action in
                                                                }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: Utils.AppName(),
                                                                message: "Failed to load list of products. Please try again later",
                                                                preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            print("products---->:", products![0] as Any)
        }
    }
    
    private func purchaseItemIndex(index: String) {
        
        if (!PremiumIAPManager.canMakePayments() || self.products.count < 0) {
            let alertController = UIAlertController(title: Utils.AppName(),
                                                    message: "Failed to load list of products. Please try again later",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
            return
        } else {
            var product: SKProduct?
            for p in self.products {
                if p.productIdentifier == index {
                    product = p
                }
                print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
            }
            if product == nil {
                return
            }
            PremiumProducts.store.buy(product: product!) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(_):
                        UserDefaults.standard.set(true, forKey: UseCaseMessage.Purchase.premium)
                        var str = ""
                        if (index == "premium_3months") {
                            str = "3months"
                        } else if ( index == "premium_6months" ) {
                            str = "6months"
                        } else if ( index == "premium_monthly" ) {
                            str = "monthly"
                        } else if ( index == "premium_weekly" ) {
                            str = "weekly"
                        } else {
                            str = "yearly"
                        }
                        self.callAPIRewardMethod(str: str)
                        self.btnRestore.isEnabled = true
                        self.btnRestore.alpha = 1.0
                        
                    case .failure(let error):
                        let alertController = UIAlertController(title: "Failed to upgrade to Premium Membbership",
                                                                message: error.localizedDescription,
                                                                preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                }
            }
        }
    }
    @IBAction func btnRestoreTapped(_ sender: UIButton) {
        PremiumProducts.store.restorePurchases()
        btnRestore.isEnabled = false
        btnRestore.alpha = 0.5
    }
    
    func callAPIRewardMethod(str: String) {
        Apimanager.sharedManager.webServiceDelegate = self
        let token = SharedPreference.getUserData().token
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kToken] = token
        param[ApiConstant.ApiKey.kPremium] = str
        let act_str = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kGetReward
        
        Apimanager.sharedManager.callApiPostMethod(str_Action: act_str, param: param)
    }
    //MARK:- Server response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kGetProfile + SharedPreference.getUserData().token! {
            guard let baseModel = Mapper<BaseModel<LoginModel>>().map(JSONObject: data) else{
                return
            }
            
            if baseModel.isSuccess{
                let data = baseModel.object!
                print("API wala token \(String(describing: data.token))")
                if (data.token != nil && data.token != "") {
                    SharedPreference.saveUserData(user: data)
                    let token = SharedPreference.getUserData().token
                    print("Shareprecent token \(String(describing: token))")
                    setUserData(profileData: data)
                }else{
                    self.showAnnouncement(withMessage: UseCaseMessage.Empty.TokenMessage, closer: {
                        SharedPreference.clearUserData()
                        self.logout()
                    })
                }
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        } else if actionStr == ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kUpdateProfile{
            guard let baseModel = Mapper<BaseModel<LoginModel>>().map(JSONObject: data) else{
                return
            }
            if baseModel.isSuccess{
                let data = baseModel.object!
                if (data.token != nil && data.token != "") {
                    SharedPreference.saveUserData(user: data)
                    //self.showAnnouncement(withMessage: baseModel.msg!)
                    view_UpdateProfile.isHidden = true
                    view_EditProfile.isHidden = false
                    btnCamera.isHidden = true
                    self.disablTextFields()
                    tfName.text = data.userName
                    setUserData(profileData: data)
                    //                    NotificationCenter.default.post(name: NotificationName.userUpdateNotification, object: nil)
                }else{
                    self.showAnnouncement(withMessage: UseCaseMessage.Empty.TokenMessage)
                }
                
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        } else if actionStr == ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kDeleteAccount{
            guard let baseModel = Mapper<BaseModel<LoginModel>>().map(JSONObject: data) else{
                return
            }
            self.showAnnouncement(withMessage: baseModel.msg!)
            if baseModel.isSuccess{
                SharedPreference.clearUserData()
                SharedPreference.clearRadius()
                self.logout()
            }
        } else if actionStr == ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kGetReward {
            guard let baseModel = Mapper<BaseModel<LoginModel>>().map(JSONObject: data) else{
                return
            }
            if baseModel.isSuccess{
//                earnedImg.image = UIImage.gif(name: "earned")
//                popupView.fadeIn(0.5, onCompletion: {
//                    print("you have earned SSTX")
//                })
                //                let data = baseModel.object!
                //                if (data.token != nil && data.token != "") {
                //                    SharedPreference.saveUserData(user: data)
                //                    popupView.fadeIn(0.5, onCompletion: {
                //                        print("you have earned SSTX")
                //                    })
                //                }else{
                //                    self.showAnnouncement(withMessage: UseCaseMessage.Empty.TokenMessage)
                //                }
                
            }else{
                //                let data = baseModel.object!
                self.showAnnouncement(withMessage: baseModel.msg!)
                //                if (data.token != nil && data.token != "") {
                //                    SharedPreference.saveUserData(user: data)
                //                }
                
            }
        }
    }
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
    
    func setUserData(profileData : LoginModel){
        tfName.text = profileData.userName
        tfEmail.text = profileData.email
        // tfMobile.text = profileData.mobile
        let imagePath = profileData.path! + profileData.profile_pic!
        imgProfilePic?.sd_setImage(with: URL(string: imagePath), placeholderImage: #imageLiteral(resourceName: "bg"), options: .progressiveLoad, progress: nil, completed: nil)
        imgProfileBackGround.sd_setImage(with: URL(string: imagePath), placeholderImage: #imageLiteral(resourceName: "bg"), options: .progressiveLoad, progress: nil, completed: nil)
    }
    
    //MARK:- Delete Account Api
    func updateAccountApi() {
        var param = [String : Any]()
        param[ApiConstant.ApiKey.kToken] = SharedPreference.getUserData().token
        let act_str = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kDeleteAccount
        Apimanager.sharedManager.webServiceDelegate = self
        Apimanager.sharedManager.callAPIForUpload(dataDict: param, action: act_str)
    }
    
    //MARK:- Update Profile Api
    func updateProfileApi() {
        var param = [String : Any]()
        param[ApiConstant.ApiKey.kToken] = SharedPreference.getUserData().token
        param[ApiConstant.ApiKey.kName] = tf_UpdatedName.text
        param[ApiConstant.ApiKey.kProfilePic] = URL(string :self.imageURlProf)
        let act_str = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kUpdateProfile
        Apimanager.sharedManager.webServiceDelegate = self
        Apimanager.sharedManager.callAPIForUpload(dataDict: param, action: act_str)
    }
    
    @IBAction func updateProfileAction(_ sender: UIButton) {
        disablTextFields()
        //updateProfileApi()
    }
    
    @IBAction func editProfileAction(_ sender: UIButton) {
        view_UpdateProfile.isHidden = false
        view_EditProfile.isHidden = true
        btnCamera.isHidden = false
        self.btnCamera.alpha = 1.0
        self.tf_UpdatedName.text = tfName.text
        self.tf_UpdatedEmail.text = tfEmail.text
        self.tf_UpdatedEmail.isUserInteractionEnabled = false
        //enableTextFields()
    }
    //MARK:- View_UpadateProfile Page
    @IBAction func btn_UpdateProfile(_ sender: UIButton) {
        view_UpdateProfile.isHidden = true
        view_EditProfile.isHidden = false
        enableTextFields()
        updateProfileApi()
    }
    @IBAction func chooseImageFromCameraGaleryAction(_ sender: UIButton) {
        
        let actionShhet = UIAlertController(title: Utils.AppName(), message: "Choose profile pic from", preferredStyle: .actionSheet)
        actionShhet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alertAction) in
            self.openCamera()
        }))
        actionShhet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alertAction) in
            self.openGallery()
        }))
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            actionShhet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (alertAction) in
            }))
        }else{
            actionShhet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
            }))
        }
        
        if let popoverController = actionShhet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(actionShhet, animated: true) {
        }
        
        
        /*if UIDevice.current.userInterfaceIdiom == .pad{
         actionShhet.popoverPresentationController?.sourceView = sender
         actionShhet.popoverPresentationController?.sourceRect = sender.bounds
         actionShhet.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.right
         }else if UIDevice.current.userInterfaceIdiom == .phone{
         
         }*/
        
        
    }
    func openCamera(){
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imgPicker.sourceType = .camera
            self.present(imgPicker, animated: true, completion: nil)
        }else{
            self.showAnnouncement(withMessage: UseCaseMessage.NotAvailable.camera)
        }
    }
    func openGallery(){
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imgPicker.sourceType = .photoLibrary
            self.present(imgPicker, animated: true, completion: nil)
        }else{
            self.showAnnouncement(withMessage: UseCaseMessage.NotAvailable.gallery)
        }
    }
    //MARK:- UIImagepicker controller delegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
        }
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            let data = UIImageJPEGRepresentation(image, 0.25)
            do {
                let urlString = String(describing: Utils.getAppDocumentDirectory()) + String(Utils.getCurrentTimeInterval()) + ".jpg"
                
                if let url = URL(string: urlString){
                    try data?.write(to: url, options: .atomicWrite)
                    self.imgProfilePic.image = image
                    self.imgProfileBackGround.image = image
                    self.imageURlProf = urlString
                    
                    print("=====>>>>", self.imageURlProf)
                }
            }catch( _){
            }
        }
        
        self.dismiss(animated: true, completion: {})
    }
    
    //MARK:- Enable / Disable textField
    func disablTextFields(){
        //tfMobile.isUserInteractionEnabled = false
        tfName.isUserInteractionEnabled = false
        tfEmail.isUserInteractionEnabled = false
        btnCamera.isHidden = true
    }
    func enableTextFields(){
        //tfMobile.isUserInteractionEnabled = false
        tfName.isUserInteractionEnabled = true
        tfEmail.isUserInteractionEnabled = true
        btnCamera.isHidden = false
    }
}

//MARK: - UIView Extension
extension UIView {
    func setTopCurve(){
        let offset = CGFloat(self.frame.size.height/4)
        let bounds = self.bounds
        let rectBounds = CGRect(x: bounds.origin.x, y: bounds.origin.y + bounds.size.height/2  , width:  bounds.size.width, height: bounds.size.height / 2)
        let rectPath = UIBezierPath(rect: rectBounds)
        let ovalBounds = CGRect(x: bounds.origin.x - offset / 2, y: bounds.origin.y, width: bounds.size.width + offset, height: bounds.size.height)
        let ovalPath = UIBezierPath(ovalIn: ovalBounds)
        rectPath.append(ovalPath)
        
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = bounds
        maskLayer.path = rectPath.cgPath
        self.layer.mask = maskLayer
    }
}
