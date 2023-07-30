//
//  SpeedShopperMarketVC.swift
//  Speed Shopping List
//
//  Created by mac on 30/05/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import OneSignal

class SpeedShopperMarketVC: BaseViewController , UITableViewDelegate , UITableViewDataSource , WebServiceDelegate , UITextFieldDelegate {
    var page = 0
    var arrShoppingList = [SpeedShopperMarketModel]()
    var arrShownShoppingList = [SpeedShopperMarketModel]()
    @IBOutlet weak var tblStoreList : UITableView!
    @IBOutlet weak var tfSearchStore: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Gift Cards"
        tfSearchStore.delegate = self
        self.callAPIForGetspeedShopperMarket(page_no: page, text2Search: "")
        //tfSearchStore.addTarget(self, action: #selector(SearchStore(sender:)), for: .edi)
    }
    @objc func SearchStore(sender: UITextField){
        //callAPIForGetspeedShopperMarket(page_no: page)
//        if tfSearchStore.text != "" {
//            callAPIForGetspeedShopperMarket(page_no: page)
//        }
        /*if tfSearchStore.text == "" {
            arrShownShoppingList = arrShoppingList
            tblStoreList.reloadData()
        }else{
            let str = self.tfSearchStore.text?.uppercased()
            let filterArr = arrShoppingList.filter { store in
                return(store.store_name?.uppercased().contains("\(String(describing: str!))"))!
            }
            print(filterArr)
            arrShownShoppingList = filterArr
            tblStoreList.reloadData()
        }*/
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OneSignal.addTrigger("searchMarket", withValue: "loaded")
    }
    
    //API For GetspeedShopperMarket
    func callAPIForGetspeedShopperMarket(page_no : Int , text2Search: String) {
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kpage] = page_no
        param[ApiConstant.ApiKey.kkey] = text2Search//
        let act_str = ApiConstant.ApiType.kSpeedShopperMarket + ApiConstant.ApiAction.kGetSpeedShopperMarket + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: act_str, param: param)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Tableview Delegate & Datasource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrShownShoppingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MerchantTablCell") as! MerchantTablCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let storeData = arrShownShoppingList[indexPath.row]
        cell.lblStoreName.text = storeData.store_name
        cell.lblStoreAddress.text =  storeData.address
        let imagePath = arrShoppingList[indexPath.row].profile_pic
        cell.imgStore?.sd_setImage(with: URL(string: imagePath! ), placeholderImage: #imageLiteral(resourceName: "img"), options: .progressiveLoad, completed: nil)
        cell.viewCell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.viewCell.layer.shadowOpacity = 1
        cell.viewCell.layer.shadowRadius = 5
        cell.viewCell.layer.shadowOffset = CGSize.zero
        return cell
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let product = self.storyboard?.instantiateViewController(withIdentifier: "ProductListVC") as! ProductListVC
        product.store_id = arrShownShoppingList[indexPath.row].store_id!
        product.storeName = arrShownShoppingList[indexPath.row].store_name!
        self.navigationController?.pushViewController(product, animated: true)
    }
    
    //MARK:- Server Response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr ==  ApiConstant.ApiType.kSpeedShopperMarket + ApiConstant.ApiAction.kGetSpeedShopperMarket + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseListModel<SpeedShopperMarketModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            if baseModel.isSuccess {
                arrShoppingList = baseModel.object!
                arrShownShoppingList = arrShoppingList
                tblStoreList.reloadData()
            }else {
                //self.showAnnouncement(withMessage: baseModel.msg!)
                self.showAnnouncement(withMessage: baseModel.msg!, closer: {
                    self.tfSearchStore.text = ""
                })
            }
        }
    }
    
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
    //MARK :- Uitextfield delegate method
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let str = textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        //NSString *trimmedString = [myString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if str?.count == 0 {
            self.showAnnouncement(withMessage: "Please enter keyword for search", closer: {
            })
        }else{
            self.callAPIForGetspeedShopperMarket(page_no: page, text2Search: self.tfSearchStore.text!)
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        /*if(string == "\n") {
         textField.resignFirstResponder()
         return false
         }
         if(string == " ")
         {
         return false
         }
         */
        
        let oldLength: Int = (textField.text?.count)!
        let newLength: Int = oldLength + string.count - range.length
        if newLength == 0 {
            self.callAPIForGetspeedShopperMarket(page_no: page , text2Search: "")
            return true
            
        }
        
        
        return true
    }
    
}
class MerchantTablCell: UITableViewCell {
    
    @IBOutlet weak var lblStoreName : UILabel!
    @IBOutlet weak var lblStoreAddress : UILabel!
    @IBOutlet weak var imgStore : UIImageView!
    @IBOutlet weak var viewCell : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}



