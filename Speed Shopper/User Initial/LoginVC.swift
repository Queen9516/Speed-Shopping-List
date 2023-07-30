//
//  LoginVC.swift
//  Speed Shopping List
//
//  Created by mac on 10/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import FacebookLogin
import FacebookCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import OneSignal

class LoginVC: BaseViewController, WebServiceDelegate, PopUpDelegate {
    
    var name: String = ""
    var email: String = ""
    var userToken: String = ""
    var isShowPassword: Bool = false

    @IBOutlet var btnGuest: UIButton!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnForgotPass: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var lblNewUser: UILabel!
    @IBOutlet weak var btnTermsCondition: UIButton!
    @IBOutlet weak var btnPrivacyPolicy: UIButton!
    @IBOutlet weak var socialSigninView: UIStackView!
    fileprivate var currentNonce: String?
    @IBOutlet var consGuestHeight: NSLayoutConstraint!
    
    var isDeepLink: Bool = false
    
    
    @IBAction func btn_termsAndCondition(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TermsAndConditionVC") as! TermsAndConditionVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_PrivacyPolicy(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicy") as! PrivacyPolicy
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func guestTapped(_ sender: Any) {
       
        self.callApiForGuestLogin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupButton()
        setupSignInWithAppleButton()
        self.btnGuest.cornerRadius = self.consGuestHeight.constant/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Apimanager.sharedManager.webServiceDelegate = self
        self.hideNavigationBar()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        OneSignal.addTrigger("login", withValue: "loaded")
    }

    func setupSignInWithAppleButton() {
        if #available(iOS 13.0, *) {
            let buttonStyle: ASAuthorizationAppleIDButton.Style = .black
            let button = ASAuthorizationAppleIDButton(type: .signIn, style: buttonStyle)
            
            button.addTarget(self, action: #selector(self.appleIDButtonTapped), for: .touchUpInside)
            socialSigninView.insertArrangedSubview(button, at: 0)
        } else {
            print("Sign in with apple not supported below iOS 13")
        }
        
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
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }

    @available(iOS 13.0, *)
    
    @objc func appleIDButtonTapped() {
        let nonce = RANDOM_NONCE_STRING()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func setupButton(){
        self.setAttributedString(btn: btnTermsCondition)
        self.setAttributedString(btn: btnPrivacyPolicy)
        
        btnSignUp.layer.cornerRadius = 0.5 * btnSignUp.bounds.size.height
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func forgotAction(_ sender: UIButton) {
        let forgot = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(forgot, animated: true)
    }
    
    @IBAction func signupAction(_ sender: UIButton) {
        let signup = self.storyboard?.instantiateViewController(withIdentifier: "SignupVC") as! SignupVC
        self.navigationController?.pushViewController(signup, animated: true)
    }
    
    @IBAction func btn_LoginWithFacebook(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logOut()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { result in
            switch result {
            case.failed(let error):
                print(error.localizedDescription)
            case.cancelled:
                print("User cancelled")
            case.success(_,_,_):
                self.getUserInfo { userInfo, error in
                    if let error = error {
                        print(error.localizedDescription)
                    self.showAnnouncement(withMessage:error.localizedDescription)
                    }else{
                        if let userInfo = userInfo, let id = userInfo["id"], let name = userInfo["name"], let email = userInfo["email"] {
                            print("Id :\(id)","name: \(name)","email: \(email)")
                            self.callAPIForSocialLogin(id: id as! String, name: name as! String, email: email as! String, loginType: SocialType.Kfacebook)
                        }else if "\(userInfo!["email"] ?? "")".isValidEmail {
                            self.showAnnouncement(withMessage: "Please put this message for email check while login with facebook ")
                        }
                    }
                }
            }
        }
    }
    
    func getUserInfo(completion: @escaping (_: [String: Any]?, _: Error?) -> Void){
        let request = GraphRequest(graphPath: "me", parameters: ["fields": "id,email,name"])
        request.start { response, result in
            switch result {
            case.failed(let error):
                completion(nil,error)
            case.success(let graphResponse):
                completion(graphResponse.dictionaryValue,nil)
            }
        }
    }
    
    func callAPIForSocialLogin(id: String,name: String, email: String, loginType: String) {
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kfacebook_id] = id
        param[ApiConstant.ApiKey.kEmail] = email
        param[ApiConstant.ApiKey.kName] = name
        param[ApiConstant.ApiKey.KloginType] = loginType
        param[ApiConstant.ApiKey.kDeviceId] = SharedPreference.deviceToken()
        param[ApiConstant.ApiKey.kDeviceType] = ApiConstant.kDeviceType
        param[ApiConstant.ApiKey.kPush_id] = SharedPreference.PushId()
        print("push_id--->", SharedPreference.PushId())
        let actio_str = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kfacebookLogin
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
        
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        if tfEmail.isEmpty(){
            self.showAnnouncement(withMessage: UseCaseMessage.Empty.Email)
        }else if tfPassword.isEmpty(){
            self.showAnnouncement(withMessage: UseCaseMessage.Empty.Password)
        }else{
            self.callApiForLogin()
        }
    }
    
    @IBAction func GoogleLogin(_ sender: UIButton) {
      //  self.showAnnouncement(withMessage: "Comming soon..")
        self.googleLogin()
    }
    
    func callApiForLogin(){
        Apimanager.sharedManager.webServiceDelegate = self
        let act_str = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kLogin
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kEmail] = tfEmail.text!
        param[ApiConstant.ApiKey.kPassword] = tfPassword.text!
        param[ApiConstant.ApiKey.kDeviceId] = SharedPreference.deviceToken()
        param[ApiConstant.ApiKey.kDeviceType] = ApiConstant.kDeviceType
        param[ApiConstant.ApiKey.kPush_id] = SharedPreference.PushId()
        Apimanager.sharedManager.callApiPostMethod(str_Action: act_str, param: param)
    }
    
    func callApiForGuestLogin(){
        Apimanager.sharedManager.webServiceDelegate = self
        let act_str = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kGuestLogin
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kDeviceId] = SharedPreference.deviceToken()
        param[ApiConstant.ApiKey.kDeviceType] = ApiConstant.kDeviceType
        param[ApiConstant.ApiKey.kPush_id] = SharedPreference.PushId()
        Apimanager.sharedManager.callApiPostMethod(str_Action: act_str, param: param)
    }
    
    func CallAPIForSharingUpdate(token: String)
    {
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        
        param[ApiConstant.ApiKey.kSharingToken] = token
        let act_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kshareShoppingListUdate + SharedPreference.getUserData().token
        
        Apimanager.sharedManager.callApiPostMethod(str_Action: act_str, param: param)
    }
    
    func processAfterlogin()
    {
        if isDeepLink {
            let shareToken = SharedPreference.shareToken()
            self.CallAPIForSharingUpdate(token: shareToken)
        } else {
            self.goToHomePage()
        }
    }
    
    //MARK:- Server response
    func success_serverResponse(data: Any, actionStr: String) {
       
        if actionStr == ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kLogin {
            guard let baseModel = Mapper<BaseModel<LoginModel>>().map(JSONObject: data) else{
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            
            if baseModel.isSuccess{
                let userDetails: LoginModel = baseModel.object!
                print("======>>>>>",userDetails)
                
                if (userDetails.token != nil && userDetails.token != "") {
                    SharedPreference.saveUserData(user: userDetails)
                      SharedPreference.saveGuestLogin(isguest: false)
                    if userDetails.emailVerify == "0"  {
                        self.name = userDetails.userName
                        self.email = userDetails.email
                        self.userToken = userDetails.userToken
                        VerificationDialog.showPopup(parentVC: self)
                    }else {
                        self.processAfterlogin()
                    }
                }else{
                    self.showAnnouncement(withMessage: UseCaseMessage.Empty.TokenMessage)
                }
                
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
            
        }else if actionStr == ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kGuestLogin {
            guard let baseModel = Mapper<BaseModel<LoginModel>>().map(JSONObject: data) else{
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            
            if baseModel.isSuccess{
                let userDetails: LoginModel = baseModel.object!
                print("======>>>>>",userDetails)
                
                if (userDetails.token != nil && userDetails.token != "") {
                    SharedPreference.saveUserData(user: userDetails)
                      SharedPreference.saveGuestLogin(isguest: true)
                    if userDetails.emailVerify == "0"  {
                        self.showAnnouncement(withMessage: "Please verify your email")
                    }else {
                        self.processAfterlogin()
                        
                    }
                }else{
                    self.showAnnouncement(withMessage: UseCaseMessage.Empty.TokenMessage)
                }
                
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
            
        } else if actionStr == ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kfacebookLogin {
            guard let baseModel = Mapper<BaseModel<LoginModel>>().map(JSONObject: data) else{
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            if baseModel.isSuccess {
                let userDetails: LoginModel = baseModel.object!
                print("======>>>>>",userDetails)
                if (userDetails.token != nil && userDetails.token != "") {
                    SharedPreference.saveGuestLogin(isguest: false)
                    SharedPreference.saveUserData(user: userDetails)
                    self.processAfterlogin()
                }else{
                    self.showAnnouncement(withMessage: UseCaseMessage.Empty.TokenMessage)
                }
               
            }
            else {
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        } else if (actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kshareShoppingListUdate + SharedPreference.getUserData().token) {
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
    
    // Send Email API
    func callEmailVerifyAPI(name: String, email: String, token: String){
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kName] = name
        param[ApiConstant.ApiKey.kEmail] = email
        param[ApiConstant.ApiKey.kToken] = token
        let actio_str: String = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kEmailVerify
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
}
//MARK:- GIDSignInDelegate Method
extension LoginVC: GIDSignInDelegate {
    
    func googleLogin(){
        GIDSignIn.sharedInstance().signIn()
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        }else {
            // Perform any operations on signed in user here.
            let userId = user.userID
            let idToken = user.authentication.idToken
            let first_name = user.profile.givenName
            _ = user.profile.familyName
            let email = user.profile.email
            let profile_pic = user.profile.imageURL(withDimension: 250)
            print("User ID : \(userId!) \n ID Token: \(idToken!) \n First name : \(first_name!) \n  email : \(email!) \n Profile pic : \(profile_pic!)")
            
            self.callAPIForSocialLogin(id: "\(userId ?? "")", name: "\(first_name ?? "")", email: "\(email ?? "")", loginType: SocialType.KGoogle)
            
        }
    }
}
struct SocialType {
    static var Kfacebook = "1"
    static var KGoogle = "2"
    static var kApple = "apple"
}

@available(iOS 13.0, *)
extension LoginVC: ASAuthorizationControllerDelegate {

    // ASAuthorizationControllerDelegate function for successful authorization
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            self.showAnnouncement(withMessage: "Can't sign in with Apple.")
            return
        }
        // Create an account in your system.
        let userIdentifier = appleIDCredential.user
        let userFirstName = appleIDCredential.fullName?.givenName
        let userLastName = appleIDCredential.fullName?.familyName
        let userEmail = appleIDCredential.email
      
        self.callAPIForSocialLogin(id: "\(userIdentifier )", name: "\(userFirstName ?? "") \(userLastName ?? "")", email: "\(userEmail ?? "")", loginType: SocialType.kApple)
  }

    

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        self.showAnnouncement(withMessage: "Can't sign in with Apple.")
        print("Sign in with Apple errored: \(error)")
    }

}
