import UIKit
import ObjectMapper
import OneSignal

class SendSmsVC: BaseViewController , WebServiceDelegate {
    
    var userToken: String = ""
    var phoneNumber: String = ""
    
    @IBOutlet weak var tfPhone: UITextField!
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
        OneSignal.addTrigger("forgot", withValue: "loaded")
    }
    
    @IBAction func sendAction(_ sender: UIButton) {
        if tfPhone.text!.isEmpty {
            self.showAnnouncement(withMessage: UseCaseMessage.Empty.Phone)
            
        } else{
            phoneNumber = self.tfPhone.text!
            self.callSendSmsAPI(mobile: self.tfPhone.text!)
        }
    }
    
    //API for SendSms
    
    func callSendSmsAPI(mobile:String) {
        var param = [String: AnyObject]()
        param[ApiConstant.ApiKey.kMobile] = mobile as AnyObject
        param[ApiConstant.ApiKey.kToken] = userToken as AnyObject
        let actio_str: String = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kPhoneVerify
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
     //MARK: - Server response
    
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr ==  ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kPhoneVerify{
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
                    verification.nameGet = ""
                    verification.emailGet = ""
                    verification.tokenGet = self.userToken
                    verification.OTPFromAPI = userDetails.otp
                    verification.mobileGet = self.phoneNumber
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
    
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
