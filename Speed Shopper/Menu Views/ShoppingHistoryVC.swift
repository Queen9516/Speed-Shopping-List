//
//  ShoppingHistoryVC.swift
//  Speed Shopping List
//
//  Created by mac on 14/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import OneSignal

class ShoppingHistoryVC: BaseViewController , UITableViewDataSource, UITableViewDelegate ,WebServiceDelegate  {
    
    @IBOutlet weak var tblShoppingHistory: UITableView!
    var arrstore = [ShoppingModel]()
 //   var arrShoppingList = [ShoppingListModel]()
    
    var index = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Shopping history"
        tblShoppingHistory.rowHeight = UITableViewAutomaticDimension
        tblShoppingHistory.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
          callAPIForshoppingHistoryStore()
        OneSignal.addTrigger("shoppingHistory", withValue: "loaded")
    }
    // MARK:-call API For shoppingHistoryStore
    func callAPIForshoppingHistoryStore(){
       Apimanager.sharedManager.webServiceDelegate = self
        let actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kShoppingHistoryStore + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiGetMethod(str_Action: actio_str)
    }
    // MARK:- Server Response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kShoppingHistoryStore + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseListModel<ShoppingModel>>().map(JSONObject: data) else {
                print("Parse Error")
                return
            }
            if baseModel.isSuccess {
                arrstore = baseModel.object!
                print(arrstore)
                self.tblShoppingHistory.reloadData()
            }
            else {
                print("Parse Error")
            }
        }
    }
    func error_serverResponse(data: Any, actionStr: String) {
         self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrstore.count
       }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShoppingHistoryCell
        let data = arrstore[indexPath.row]
        cell.lbl_StoreName.text = data.name
//        cell.lbl_StoreName.text = data.name
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    func goToShopingList(with arrStore: ShoppingModel){
        
    }
}

