//
//  addActionVC.swift
//  Speed Shopping List
//
//  Created by info on 13/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper

protocol Myprotocol {
    func listAddedSucees()
    func listAddedSuceesGuese(name:String)

}

class AddActionVC: BaseViewController , WebServiceDelegate  {
    
    @IBOutlet weak var viewTextField: UIView!
    @IBOutlet weak var tf_textField: UITextField!
    @IBOutlet weak var lblList: UILabel!
    @IBOutlet weak var addDialogView: UIView!
    
    var storeData = StoreModel()
    let token = SharedPreference.getUserData().token
    var myprotocol: Myprotocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.lblList.text = storeData.name ?? ""
        
        addDialogView.layer.cornerRadius = 8.0
        addDialogView.layer.masksToBounds = true
    }
    
    @IBAction func btn_close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btn_done(_ sender: UIButton) {
        if tf_textField.text == "" {
            let alertController =   UIAlertController(title: Utils.AppName() , message: "Please add item", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel) { (action:UIAlertAction!) in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            let store_id = storeData.id
            let name = tf_textField.text!
            let image = "logo_0"
//            let token = SharedPreference.getUserData().token
//            if SharedPreference.getGuestData() == true
//            {
//                 self.myprotocol?.listAddedSuceesGuese(name:name)
//
//            }else
//            {
            self.CallAPIForAddShoppingList(name: name, store_id: store_id!, image: image)
            //}

        }
    }
    
    func CallAPIForAddShoppingList(name: String, store_id: String, image: String) {
         Apimanager.sharedManager.webServiceDelegate = self
     
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kName] = name
        param[ApiConstant.ApiKey.kStoreId] = store_id
        param[ApiConstant.ApiKey.kImage] = image
        let actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kAddShoppingList + token!
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btn(_ sender: Any) {
        self.view.backgroundColor = UIColor.gray
    }
    
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kAddShoppingList + token!  {
            guard let baseModel = Mapper<BaseModel<ShoppingListModel>>().map(JSONObject: data) else {
                print("Parse Error")
                self.showAnnouncement(withMessage: "Parser Error")
                return
            }
            if baseModel.isSuccess {
                self.myprotocol?.listAddedSucees()
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
}

