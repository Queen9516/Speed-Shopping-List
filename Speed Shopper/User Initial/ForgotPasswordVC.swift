//
//  ForgotPasswordVC.swift
//  Speed Shopping List
//
//  Created by mac on 12/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import OneSignal

class ForgotPasswordVC: BaseViewController , WebServiceDelegate {

    @IBOutlet weak var tfEmail: UITextField!
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
        if tfEmail.text!.isEmpty {
            self.showAnnouncement(withMessage: UseCaseMessage.Empty.Email)
            
        }else if !tfEmail.isValidEmail(){
          self.showAnnouncement(withMessage: UseCaseMessage.InValid.Email)
        }else{
            self.callForgetPasswordAPI(email: self.tfEmail.text!)
        }
}
    //API for ForgotPassword
    
    func callForgetPasswordAPI(email:String) {
        var param = [String: AnyObject]()
        param[ApiConstant.ApiKey.kEmail] = email as AnyObject
        let actio_str: String = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kForgotPassword
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
     //MARK: - Server response
    
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr ==  ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kForgotPassword{
            guard let baseModel = Mapper<BaseModel<LoginModel>>().map(JSONObject: data) else {
                print("parsing Error")
                self.showAnnouncement(withMessage: "Parser Error")
                return
            }
            if baseModel.isSuccess{
                self.showAnnouncement(withMessage: baseModel.msg!){
                    let login = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    self.navigationController?.pushViewController(login, animated: true)
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
