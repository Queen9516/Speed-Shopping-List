//
//  MyWalletVC.swift
//  Speed Shopping List
//
//  Created by mac on 14/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import OneSignal

class MyWalletVC: BaseViewController , WebServiceDelegate{
    
    @IBOutlet weak var lblMoney: UILabel!
    @IBOutlet weak var lblSSTX: UILabel!
    @IBOutlet weak var btnSSTX: SpeedShopperButton!
    @IBOutlet weak var btnETH: SpeedShopperButton!
    @IBOutlet weak var lblAmountSstx: UILabel!
    @IBOutlet weak var vwWalletDetail: UIView!
    @IBOutlet weak var moneyImage: UIImageView!
    
    var addressToken = ""
    var ethToken = ""
    var SSTX = ""
    var privateAddress = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = "My Wallet"
        moneyImage.loadGif(asset: "money")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.vwWalletDetail.setTopCurve()
        }
        self.setupTransferHistory()
        self.callAPiForGetWalletDetail()
        
        let historyFilterBarButton = UIBarButtonItem(title: "History", style: .plain, target: self, action: #selector(transactionHistory))
        self.navigationItem.rightBarButtonItem = historyFilterBarButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        OneSignal.addTrigger("wallet", withValue: "loaded")
    }
    @objc func transactionHistory(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "TransactionHistoryVC") as! TransactionHistoryVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btn_Deposite(_ sender: UIButton) {
        self.addTransitionEffect()
        if addressToken == "" {
            self.showAnnouncement(withMessage: "Address Not Found")
        }else{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Wallet2VC") as! Wallet2VC
            vc.address = addressToken
            vc.PrivateAddress = self.privateAddress
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: false, completion: nil)
        }
    }
    @IBAction func btn_ShowSSTX(_ sender: UIButton){
        self.lblAmountSstx.text = ethToken
        self.lblSSTX.text = "SPEED TOKENS"
        self.lblMoney.text = "'TOKENS'"
        btnETH.isSelected = false
        btnSSTX.isSelected = true
        btnSSTX.backgroundColor = UIColor.hexStringToUIColor(AppColor.blueColor)
        btnETH.backgroundColor = UIColor.hexStringToUIColor(AppColor.lightGray)
    }
    @IBAction func btn_ShowETH(_sender: UIButton) {
        self.lblAmountSstx.text = SSTX
        self.lblSSTX.text = "ETH"
        self.lblMoney.text = "'TOKEN'"
        btnSSTX.isSelected = false
        btnETH.isSelected = true
        btnETH.backgroundColor = UIColor.hexStringToUIColor(AppColor.blueColor)
        btnSSTX.backgroundColor = UIColor.hexStringToUIColor(AppColor.lightGray)
    }
    func callAPiForGetWalletDetail(){
        Apimanager.sharedManager.webServiceDelegate = self
        //        let actStr = ApiConstant.ApiType.kWallet + ApiConstant.ApiAction.kGetWallet + SharedPreference.getUserData().token!
        let actStr = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kGetProfile + SharedPreference.getUserData().token!
        Apimanager.sharedManager.callApiGetMethod(str_Action: actStr)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Server response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kGetProfile + SharedPreference.getUserData().token!{
            guard let baseModel = Mapper<BaseModel<ProfileModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            
            if baseModel.isSuccess{
                self.setWalletData(walletData: baseModel.object!)
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
    
    func setWalletData(walletData : ProfileModel){
        //        let walletAmount = walletData.ethToken as? String ?? "0.0"
        //        let walletBallance = walletData.ethBalance as? String ?? "0.0"
        //        self.lblAmountSstx.text = walletAmount
        //        ethToken = walletAmount
        //        SSTX = walletBallance
        //        addressToken = walletData.address!
        //        privateAddress = "\(walletData.privateAd ?? "")"
        self.lblAmountSstx.text = walletData.balance ?? "0"
    }
}
