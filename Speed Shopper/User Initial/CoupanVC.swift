//
//  CoupanVC.swift
//  Speed Shopping List
//
//  Created by info on 25/06/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import OneSignal

class CoupanVC: BaseViewController , UITableViewDataSource, UITableViewDelegate , WebServiceDelegate, ShoppingListDelegate {
    func handleAction(action: ShoppingListModel) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SpeedShoppingListVC") as! SpeedShoppingListVC
        vc.list_id =  action.id!
        vc.item =   action.name!
        vc.storeId =   action.store_id!
        vc.store_name = action.store_name!
        vc.store_address = action.address!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBOutlet weak var tblBuyList: UITableView!
    
    var arrEZLists = [EZListModel]()
    var arrShoppingList = [ShoppingListModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "EZ Lists"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        OneSignal.addTrigger("coupon", withValue: "loaded")
        
        if !self.getCurrentLocationEnabledCondition(){
            self.goToAppSettingForEnableLocation()
        }else{
            CallAPIForEZLists()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToAppSettingForEnableLocation(){
        self.showAnnouncementYesAndNoOption(withMessage: "Please Turn on Location from Settings or allow locations for Speed Shopping List", yesTitle: "Go to Settings", noTitle: "Retry", closer: {
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
        },closer1: {
            if !self.getCurrentLocationEnabledCondition(){
                self.goToAppSettingForEnableLocation()
            }else{
                self.CallAPIForEZLists()
            }
        })
    }
    
    //MARK:- UITableview delegate & datasource method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrEZLists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoupanCodeCell") as! CoupanCodeCell
        let data = arrEZLists[indexPath.row]
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        cell.ezTitle.text = data.title
        cell.ezDesc.text = data.description
        let imagePath = data.image
        cell.ezImg?.sd_setImage(with: URL(string: imagePath! ), placeholderImage: #imageLiteral(resourceName: "img"), options: .progressiveLoad, completed: nil)
        cell.viewCell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.viewCell.layer.shadowOpacity = 1
        cell.viewCell.layer.shadowRadius = 5
        cell.viewCell.layer.shadowOffset = CGSize.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let product = self.storyboard?.instantiateViewController(withIdentifier: "ProductListVC") as! ProductListVC
//        product.store_id = arrShownShoppingList[indexPath.row].store_id!
//        product.storeName = arrShownShoppingList[indexPath.row].store_name!
//        self.navigationController?.pushViewController(product, animated: true)
        let data = arrEZLists[indexPath.row]
        ShoppingListDialog.showPopup(parentVC: self, ezData1: data)
    }
    
    func CallAPIForEZLists(){
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kpage] = 0
        param[ApiConstant.ApiKey.kkey] = ""
        let actio_str = ApiConstant.ApiType.kEZLists + ApiConstant.ApiAction.KGetEZLists + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    
    @objc func callAPiForGettingShoppingList() {
        Apimanager.sharedManager.webServiceDelegate = self
        var act_str = ""

        act_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kShoppingList + SharedPreference.getUserData().token
         Apimanager.sharedManager.callApiPostMethodWithoutParam(str_Action: act_str)

    }
    
    //MARK:- Server Response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kEZLists + ApiConstant.ApiAction.KGetEZLists   + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseListModel<EZListModel>>().map(JSONObject: data) else{
                return
            }
            if baseModel.isSuccess {
                arrEZLists = baseModel.object!
                print(arrEZLists)
                tblBuyList.reloadData()
                
//                callAPiForGettingShoppingList()
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        } else if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kShoppingList + SharedPreference.getUserData().token! {
            guard let baseModel = Mapper<BaseListModel<ShoppingListModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            if baseModel.isSuccess{
                arrShoppingList = baseModel.object!
                print("Response--->", arrShoppingList)
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
}
