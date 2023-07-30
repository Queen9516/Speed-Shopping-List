//
//  AddPickerVC.swift
//  Speed Shopping List
//
//  Created by mac on 23/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import Toaster


protocol CustomPickerDelegate {
    func selectedItem(iteamName: String , isDoneClicked: Bool, isCancelled: Bool)
}

class AddPickerVC: BaseViewController , UIPickerViewDelegate , UIPickerViewDataSource , WebServiceDelegate {
   
    var storeData = StoreModel()
    var arrStore1 = [StoreModel]()
    var list_id = ""
    var storeID = ""
    let arrItem = ["Apple" , "orange" , "banana" , "Fruits" , "Rice" , "White"]
    var arrStoreItem = [StoreItemModel]()
    var inde = Int()
    
    @IBOutlet weak var pickerVw: UIPickerView!
    @IBOutlet weak var viewDone: UIView!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    var delegate : CustomPickerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
       print(list_id)
       callApiForItemList()
    }
    func callApiForItemList() {
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        //param[ApiConstant.ApiKey.kToken] = SharedPreference.getUserData().token
       param[ApiConstant.ApiKey.kStoreId] = self.storeID
        let actStr = ApiConstant.ApiType.kStore + ApiConstant.ApiAction.kStoreItems + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: actStr, param: param)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Pickerview delegate and datasource method
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrStoreItem.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return arrStoreItem[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       // print(arrStoreItem[row].name ?? "")
        inde = row
        self.delegate?.selectedItem(iteamName: arrStoreItem[row].name!, isDoneClicked: false, isCancelled: false)
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    //MARK:- Add Item Done
    @IBAction func btn_AddItemDone(_ sender: UIButton) {
        if arrStoreItem.count > 0 {
            self.delegate?.selectedItem(iteamName: arrStoreItem[inde].name!, isDoneClicked: true, isCancelled: true)
        }
    }
    @IBAction func btn_Cancel(_ sender: UIButton) {
        
        self.delegate?.selectedItem(iteamName: "", isDoneClicked: false, isCancelled: true)
    }
    
    //MARK:- Server response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr ==  ApiConstant.ApiType.kStore + ApiConstant.ApiAction.kStoreItems + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseListModel<StoreItemModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            if baseModel.isSuccess{
                arrStoreItem = baseModel.object!
                pickerVw.isHidden = false
                viewDone.isHidden = false
                pickerVw.reloadAllComponents()
//                tblShoppingList.reloadData()
            }else{
                pickerVw.isHidden = true
                viewDone.isHidden = true
                Toast(text: baseModel.msg!).show()
               // self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
}
