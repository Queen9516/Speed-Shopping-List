//
//  VerificationVC.swift
//  Speed Shopping List
//
//  Created by mac on 12/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import OneSignal

class VerificationVC: BaseViewController , UITextFieldDelegate , WebServiceDelegate {
    @IBOutlet weak var tfcode1: SpeedShopperTextField!
    @IBOutlet weak var tfcode2: SpeedShopperTextField!
    @IBOutlet weak var tfcode3: SpeedShopperTextField!
    @IBOutlet weak var tfcode4: SpeedShopperTextField!
    @IBOutlet weak var tfcode5: SpeedShopperTextField!
    @IBOutlet weak var tfcode6: SpeedShopperTextField!
    @IBOutlet weak var noteLabel: UILabel!
    //    var otpGet = String()
    var OTPFromAPI = ""
    var nameGet = ""
    var emailGet = ""
    var mobileGet = ""
    var tokenGet = ""
    var isFromLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (mobileGet == "") {
            noteLabel.text = "we have sent you an access code via email"
        }
        //        let array = Array(otpGet)
        //        tfcode1.text! = "\(array[0])"
        //        tfcode2.text! = "\(array[1])"
        //        tfcode3.text! = "\(array[2])"
        //        tfcode4.text! = "\(array[3])"
        //        tfcode5.text! = "\(array[4])"
        //        tfcode6.text! = "\(array[5])"
        tfcode1.addTarget(self, action: #selector(tfcode1Action),for: .editingChanged)
        tfcode2.addTarget(self, action: #selector(tfcode2Action), for: .editingChanged)
        tfcode3.addTarget(self, action: #selector(tfcode3Action), for: .editingChanged)
        tfcode4.addTarget(self, action: #selector(tfcode4Action), for: .editingChanged)
        tfcode5.addTarget(self, action: #selector(tfcode5Action), for: .editingChanged)
        tfcode6.addTarget(self, action: #selector(tfcode6Action), for: .editingChanged)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OneSignal.addTrigger("verification", withValue: "loaded")
    }
    @IBAction func resendCodeAction(_ sender: UIButton) {
        if mobileGet == "" {
            self.callResendEmailVerifyAPI(name: nameGet, email: emailGet, token: tokenGet)
        } else {
            self.callResendOtpAPI(mobile: mobileGet, token: tokenGet)
        }
        
    }
    //MARK:- API for Resend OTP
    func callResendOtpAPI(mobile: String, token: String) {
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kMobile] = mobile
        param[ApiConstant.ApiKey.kToken] = token
        let actio_str = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kPhoneVerify
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    
    // MARK:- API for Resend Email
    func callResendEmailVerifyAPI(name: String, email: String, token: String){
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kName] = name
        param[ApiConstant.ApiKey.kEmail] = email
        param[ApiConstant.ApiKey.kToken] = token
        let actio_str: String = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kEmailVerify
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    //MARK:- Server Response For Resend OTP
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kPhoneVerify {
            guard let baseModel = Mapper<BaseModel<LoginModel>>().map(JSONObject: data) else {
                print("parsing error")
                
                self.showAnnouncement(withMessage: "Parser Error")
                return
            }
            if baseModel.isSuccess {
                let userDetails: LoginModel = baseModel.object!
                print("======>>>>>",userDetails)
                self.showAnnouncement(withMessage: baseModel.msg!){
                    self.OTPFromAPI = userDetails.otp
                    print(self.OTPFromAPI)
                }
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        } else if actionStr ==  ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kEmailVerify{
            guard let baseModel = Mapper<BaseModel<LoginModel>>().map(JSONObject: data) else {
                print("parsing Error")
                self.showAnnouncement(withMessage: "Parser Error")
                return
            }
            if baseModel.isSuccess{
                let userDetails: LoginModel = baseModel.object!
                print("======>>>>>",userDetails)
                self.showAnnouncement(withMessage: baseModel.msg!){
                    self.OTPFromAPI = userDetails.otp
                }
            }
            else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        } else if  actionStr == ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kMobileVerifyOTP {
            guard let baseModel = Mapper<BaseModel<LoginModel>>().map(JSONObject: data) else {
                print("parsing error")
                
                self.showAnnouncement(withMessage: "Parser Error")
                return
            }
            if baseModel.isSuccess {
                self.showAnnouncement(withMessage: baseModel.msg!, closer: {
                    let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    self.navigationController?.pushViewController(loginVC, animated: true)
                })
            }else {
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        let num1 = tfcode1.text!
        let num2 = tfcode2.text!
        let num3 = tfcode3.text!
        let num4 = tfcode4.text!
        let num5 = tfcode5.text!
        let num6 = tfcode6.text!
        let OTPFromText = num1+num2+num3+num4+num5+num6
        if OTPFromText == OTPFromAPI {
            let token = tokenGet
            print(token)
            self.callMobileVerifyAPI(token:token)
        }
        else {
            self.showAnnouncement(withMessage: "Invalid OTP", closer: {
                self.tfcode1.text = ""
                self.tfcode2.text = ""
                self.tfcode3.text = ""
                self.tfcode4.text = ""
                self.tfcode5.text = ""
                self.tfcode6.text = ""
                self.tfcode1.becomeFirstResponder()
            })
        }
    }
    
    // API For MobileVerification
    func callMobileVerifyAPI(token:String) {
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kToken] = token
        let actio_str = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kMobileVerifyOTP
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    //MARK:- Server Response For VerifyMobileOTP
    
    
    //MARK:- OTP Text field
    @objc func tfcode1Action(){
        if tfcode1.isEmpty() {
            tfcode1.borderColor = UIColor.gray
        }else{
            tfcode1.resignFirstResponder()
            tfcode2.becomeFirstResponder()
            tfcode1.borderColor = UIColor.hexStringToUIColor(AppColor.blueColor)
            
        }
    }
    @objc func tfcode2Action(){
        if tfcode2.isEmpty() {
            tfcode2.resignFirstResponder()
            tfcode1.becomeFirstResponder()
            tfcode2.borderColor = UIColor.gray
        }else{
            tfcode2.resignFirstResponder()
            tfcode3.becomeFirstResponder()
            tfcode2.borderColor = UIColor.hexStringToUIColor(AppColor.blueColor)
        }
    }
    @objc func tfcode3Action(){
        if tfcode3.isEmpty() {
            tfcode3.resignFirstResponder()
            tfcode2.becomeFirstResponder()
            tfcode3.borderColor = UIColor.gray
        }else{
            tfcode3.resignFirstResponder()
            tfcode4.becomeFirstResponder()
            tfcode3.borderColor = UIColor.hexStringToUIColor(AppColor.blueColor)
        }
    }
    @objc func tfcode4Action(){
        if tfcode4.isEmpty() {
            tfcode4.resignFirstResponder()
            tfcode3.becomeFirstResponder()
            tfcode4.borderColor = UIColor.gray
        }else{
            tfcode4.resignFirstResponder()
            tfcode5.becomeFirstResponder()
            tfcode4.borderColor = UIColor.hexStringToUIColor(AppColor.blueColor)
        }
    }
    
    @objc func tfcode5Action(){
        if tfcode5.isEmpty(){
            tfcode5.resignFirstResponder()
            tfcode4.becomeFirstResponder()
            tfcode5.borderColor = UIColor.gray
        }
        else {
            tfcode5.resignFirstResponder()
            tfcode6.becomeFirstResponder()
            tfcode5.borderColor = UIColor.hexStringToUIColor(AppColor.blueColor)
        }
    }
    @objc func tfcode6Action(){
        if tfcode6.isEmpty(){
            tfcode6.resignFirstResponder()
            tfcode5.becomeFirstResponder()
            tfcode6.borderColor = UIColor.gray
        }
        else {
            tfcode6.resignFirstResponder()
            tfcode6.borderColor = UIColor.hexStringToUIColor(AppColor.blueColor)
        }
    }
    
    //MARK:- UITextfield delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 1
        let currentString: NSString = textField.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

