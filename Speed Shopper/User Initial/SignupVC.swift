//
//  SignupVC.swift
//  Speed Shopping List
//
//  Created by mac on 10/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import OneSignal

class SignupVC: BaseViewController , UITextFieldDelegate , WebServiceDelegate, PopUpDelegate {
    
    var name: String = ""
    var email: String = ""
    var userToken: String = ""
    var isShowPassword: Bool = false
    
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfContact: UITextField!
    @IBOutlet weak var tfName: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Apimanager.sharedManager.webServiceDelegate = self
        OneSignal.addTrigger("signup", withValue: "loaded")
    }
    //MARK:- UITextfield delegate method // for keyword
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField ==  tfName{
            tfName.resignFirstResponder()
            tfEmail.becomeFirstResponder()
        }else if textField ==  tfEmail{
            tfEmail.resignFirstResponder()
            tfContact.becomeFirstResponder()
        }
        return true
    }
    
    @IBAction func passwordButtonClicked(_ sender: UIButton) {
        isShowPassword = !isShowPassword
        if isShowPassword {
            sender.setImage(UIImage(named: "eye_view.png"), for: .normal)
            tfPassword.isSecureTextEntry = false
        } else {
            sender.setImage(UIImage(named: "eye_hide.png"), for: .normal)
            tfPassword.isSecureTextEntry = true
        }
    }
    
    @IBAction func signupAction(_ sender: UIButton) {
        self.isEditing = false
        let validity = validateData()
        if validity.isSuccess {
            let name = tfName.text!
            let email = tfEmail.text!
//            let contact = tfContact.text!

            let password = tfPassword.text!
            self.callSignUpAPI(name: name, email: email, contact: "", password: password)
        }
        else {
            showAnnouncement(withMessage: validity.msg)
        }
    }
    
    // For TextValidation
    func validateData() ->(isSuccess: Bool, msg : String){
        var success = true
        var message = ""
        if tfName.isEmpty() {
            success = false
            message = UseCaseMessage.Empty.Name
        }else if !tfEmail.isValidEmail(){
            success = false
            message = UseCaseMessage.InValid.Email
        }/*else if !tfContact.isValidCotactNumber(){
            success = false
            message = UseCaseMessage.InValid.Contact
        }*/else if !tfPassword.isValidPassword(){
            success = false
            message = UseCaseMessage.InValid.Password
        }
        
        return (isSuccess: success, msg: message)
    }
    
    // SignUp API
    func callSignUpAPI(name: String, email: String, contact: String, password: String){
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kName] = name
        param[ApiConstant.ApiKey.kEmail] = email
        param[ApiConstant.ApiKey.kContact] = contact
        param[ApiConstant.ApiKey.kPassword] = password
        let actio_str: String = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kSignup
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
        
    }
    
    // Send Email API
    func callEmailVerifyAPI(name: String, email: String, token: String){
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kName] = name
        param[ApiConstant.ApiKey.kEmail] = email
        param[ApiConstant.ApiKey.kToken] = token
        let actio_str: String = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kEmailVerify
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    
    
    @IBAction func loginAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // Server Response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kSignup  {
            guard let baseModel = Mapper<BaseModel<LoginModel>>().map(JSONObject: data) else {
                print("parsing error")
                
                self.showAnnouncement(withMessage: "Parser Error")
                return
            }
            if baseModel.isSuccess{
                let userDetails: LoginModel = baseModel.object!
                print("======>>>>>",userDetails)
                
                self.name = userDetails.userName
                self.email = userDetails.email
                self.userToken = userDetails.userToken
                VerificationDialog.showPopup(parentVC: self)
            }
            else{
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
                    let verification = self.storyboard?.instantiateViewController(withIdentifier: "VerificationVC") as! VerificationVC
                    verification.nameGet = self.name
                    verification.emailGet = self.email
                    verification.tokenGet = self.userToken
                    verification.OTPFromAPI = userDetails.otp
                    verification.mobileGet = ""
                    self.navigationController?.pushViewController(verification, animated: true)
                }
            }
            else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
    
    func handleAction(action: String) {
        print(action)
        if action == "Text" {
            let sendSmsVC = self.storyboard?.instantiateViewController(withIdentifier: "SendSmsVC") as! SendSmsVC
            sendSmsVC.userToken = userToken;
            self.navigationController?.pushViewController(sendSmsVC, animated: true)
        } else if action  == "Email" {
            callEmailVerifyAPI(name: name, email: email, token: userToken)
        }
    }
}

