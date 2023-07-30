//
//  ProductListVC.swift
//  Alamofire
//
//  Created by mac on 31/05/18.
//

import UIKit
import ObjectMapper
import OneSignal

class ProductListVC: BaseViewController , UITableViewDelegate , UITableViewDataSource , WebServiceDelegate , UITextFieldDelegate{
    var store_id = ""
    var storeName = ""
    var page = 0
    var ind = Int()
    var arrProduct = [ProductModel]()
    var arrAdvertisementList = [AdvertisementListModel]()
    var arrShownProduct = [ProductModel]()
    @IBOutlet weak var tblProduct : UITableView!
    @IBOutlet weak var textFieldSearchProduct: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBack()
        self.title = storeName
        textFieldSearchProduct.delegate = self
        self.callAPIForGetProductList(page_no: page, text2search: "")
        //textFieldSearchProduct.addTarget(self, action: #selector(SearchProduct), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        OneSignal.addTrigger("productList", withValue: "loaded")
    }
    
    @objc func SearchProduct() {
        //self.callAPIForGetProductList(page_no: page)
        print("chal raha hai")
        
        /*if textFieldSearchProduct.text == "" {
            arrShownProduct = arrProduct
            tblProduct.reloadData()
        }else{
            let str = self.textFieldSearchProduct.text?.uppercased()
            let filterdArr = arrProduct.filter { product in
                return (product.product_name?.uppercased().contains("\(String(describing: str!))"))!
            }
            print(filterdArr)
            arrShownProduct = filterdArr
            tblProduct.reloadData()*/
        
    }
    //API For GetspeedShopperMarket
    func callAPIForGetProductList(page_no : Int, text2search: String)
    {
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kpage] = page_no
        param[ApiConstant.ApiKey.kStoreId] = store_id
        param[ApiConstant.ApiKey.kkey] = text2search//self.textFieldSearchProduct.text
        let act_str = ApiConstant.ApiType.kSpeedShopperMarket + ApiConstant.ApiAction.kGetProductByMerchant + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: act_str, param: param)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableview delegate & datasource method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrShownProduct.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTblCell") as! ProductTblCell
        ind = indexPath.row
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let productData = arrShownProduct[indexPath.row]
        cell.lblProdcutName.text = productData.product_name
        cell.lblProductSSTX.text = "\(String(describing: productData.price!)) Tokens "
//        cell.lblProductDiscount.text = "\(String(describing: productData.discount!))% Off"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detail = self.storyboard?.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
        detail.productDetail = arrShownProduct[indexPath.row]
        self.navigationController?.pushViewController(detail, animated: true)
    }
    //MARK:- Server Response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr ==  ApiConstant.ApiType.kSpeedShopperMarket + ApiConstant.ApiAction.kGetProductByMerchant + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseListModel<ProductModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            if baseModel.isSuccess {
                arrProduct = baseModel.object!
                arrShownProduct = arrProduct
                tblProduct.reloadData()
            }else {
                //self.showAnnouncement(withMessage: baseModel.msg!)
                self.showAnnouncement(withMessage: baseModel.msg!, closer: {
                    self.textFieldSearchProduct.text = ""
                })
            }
        }
    }
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let str = textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        //NSString *trimmedString = [myString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if str?.count == 0 {
            self.showAnnouncement(withMessage: "please enter keyword for search", closer: {
            })
        }else{
            self.callAPIForGetProductList(page_no: page, text2search: self.textFieldSearchProduct.text!)
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
            self.callAPIForGetProductList(page_no: page, text2search: "")
            return true
            
        }
        return true
    }
   
}
class ProductTblCell: UITableViewCell {
    @IBOutlet weak var lblProductDiscount: UILabel!
    @IBOutlet weak var lblProdcutName : UILabel!
    @IBOutlet weak var lblProductSSTX : UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
