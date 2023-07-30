//
//  ProductDetailVC.swift
//  Speed Shopping List
//
//  Created by mac on 31/05/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import OneSignal

class ProductDetailVC: BaseViewController , WebServiceDelegate {
    
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblProName: UILabel!
    @IBOutlet weak var lblProSstx: UILabel!
    @IBOutlet weak var lblProWebsite: UITextView!
    @IBOutlet weak var txtVwProDescription: UITextView!
    @IBOutlet weak var btnBuy: UIButton!
    @IBOutlet weak var lblProDiscount: UILabel!
    
    var productDetail = ProductModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupBack()
        self.title = "Product detail"
        self.setProductData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        OneSignal.addTrigger("productDetail", withValue: "loaded")
    }
    func setProductData(){
        self.lblProName.text = productDetail.product_name
        self.lblProSstx.text = productDetail.price! + " Tokens"
        self.txtVwProDescription.text = productDetail.description
//        self.lblProDiscount.text = productDetail.discount! + "% Off"
        let imgPath = productDetail.path! + productDetail.product_image!
        self.imgProduct.sd_setImage(with: URL(string: imgPath), completed: nil)
        self.lblProWebsite.text = productDetail.website
        self.lblProWebsite.textContainer.lineBreakMode = .byTruncatingTail
    self.lblProWebsite.translatesAutoresizingMaskIntoConstraints = true
        self.lblProWebsite.sizeToFit()
        self.lblProWebsite.isScrollEnabled = true
//        self.imgProduct.sd_setHighlightedImage(with: URL(string: imgPath), options: .progressiveDownload, completed: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func buyAction(_ sender: UIButton) {
        let alert = UIAlertController(title: Utils.AppName(), message: "Are you sure you want \n to buy this item", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .default) { (alertaction) in
             self.CallAPIForBuyProduct()
            }
        let action2 = UIAlertAction(title: "Cancel", style: .default)  { (alertaction) in
            
        }
        alert.addAction(action)
        alert.addAction(action2)
        present(alert, animated: true)
        /*let vc = self.storyboard?.instantiateViewController(withIdentifier: "GetCoupanVC") as! GetCoupanVC
        self.navigationController?.pushViewController(vc, animated: true)*/
    }
    
    func CallAPIForBuyProduct(){
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kuserId] = SharedPreference.getUserData().id
        param[ApiConstant.ApiKey.kmerchant_id]  = self.productDetail.store_id
        param[ApiConstant.ApiKey.kproductId] = self.productDetail.product_id
        let actio_str = ApiConstant.ApiType.kSpeedShopperMarket + ApiConstant.ApiAction.kbuy + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    //MARK:- Server Response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kSpeedShopperMarket + ApiConstant.ApiAction.kbuy + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseModel<ProductModel>>().map(JSONObject: data) else{
                return
            }
            if baseModel.isSuccess {
                self.showAnnouncement(withMessage: baseModel.msg!, closer:  {
                    let couponVC = self.storyboard?.instantiateViewController(withIdentifier: "CoupanVC") as! CoupanVC
                    self.navigationController?.pushViewController(couponVC, animated: true)
                })
            }else {
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
}
