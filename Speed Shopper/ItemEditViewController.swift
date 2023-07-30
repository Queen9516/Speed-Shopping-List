//
//  ItemEditViewController.swift
//  Speed Shopping List
//
//  Created by Super on 9/24/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import OneSignal

class ItemEditViewController: BaseViewController, AisleLocationDelegate, WebServiceDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var aisleLabel: UILabel!
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet var quantityView: UIView!
    @IBOutlet weak var itemPriceView: UIView!
    @IBOutlet weak var aisleBtn: UIButton!
    @IBOutlet weak var itemImageView: UIView!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var btnReTakePhoto: UIButton!
    
    @IBOutlet weak var lblPicItem: UILabel!
    @IBOutlet weak var topSpaceValue: NSLayoutConstraint!
    @IBOutlet weak var bottomSpaceValue: NSLayoutConstraint!
    
    @IBOutlet weak var btnHeightValue: NSLayoutConstraint!
    
    @IBOutlet weak var lblTakePhoto: UILabel!
    @IBOutlet weak var btnTakePhoto: UIButton!
    @IBOutlet weak var btnRemove: UIButton!
    
    var item_id = "", m_id = "", storeId = "", listId = "", itemName = "", itemQuantity = "", itemAisle = "", itemPrice = "", imageName = ""
    var tempAisle = ""
    var isPremium : Bool = false
    var imageURlProf = ""
    var itemPic: UIImage!
    var isTakedPic: Bool = false
    var isLocated: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtPrice.delegate = self
        isPremium = UserDefaults.standard.bool(forKey: UseCaseMessage.Purchase.premium)
//        isPremium = true
        self.initUI()
        self.setupInitData()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        txtPrice.resignFirstResponder()
    }
    
    func initUI() {
        let borderColor = UIColor.init(red: 46/255, green: 39/255, blue: 134/255, alpha: 1.0).cgColor
        if isPremium {
            if isTakedPic {
                self.lblTakePhoto.isHidden = true
                self.btnTakePhoto.isHidden = true
                let link = "https://www.speedshopperapp.com/app/public/item_images/" + imageName
                let url = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let imageURL = URL(string: url!)!
                DispatchQueue.global().async {
                    // Fetch Image Data
                    if let data = try? Data(contentsOf: imageURL) {
                        DispatchQueue.main.async { [self] in
                            // Create Image and Update Image View
                            self.itemImage.image = UIImage(data: data)
                            self.lblPicItem.isHidden = false
                            self.itemImageView.isHidden = false
                        }
                    }
                }
//                lblPicItem.isHidden = false
//                itemImageView.isHidden = false
//                lblTakePhoto.isHidden = true
//                btnTakePhoto.isHidden = true
                itemImageView.layer.borderColor = borderColor
                itemImageView.layer.borderWidth = 1
            } else {
                lblPicItem.isHidden = true
                itemImageView.isHidden = true
                lblTakePhoto.isHidden = false
                btnTakePhoto.isHidden = false
            }
            
            topSpaceValue.constant = 15
            bottomSpaceValue.constant = 20
            btnHeightValue.constant = 60
            
        } else {
            lblTakePhoto.isHidden = true
            btnTakePhoto.isHidden = true
            lblPicItem.isHidden = true
            itemImageView.isHidden = true
            topSpaceValue.constant = 50
            bottomSpaceValue.constant = 50
            btnHeightValue.constant = 80
        }
        
        itemNameLabel.layer.borderColor = borderColor
        itemNameLabel.layer.borderWidth = 1
        quantityView.layer.borderColor = borderColor
        quantityView.layer.borderWidth = 1
        itemPriceView.layer.borderColor = borderColor
        itemPriceView.layer.borderWidth = 1
        aisleLabel.layer.borderColor = borderColor
        aisleLabel.layer.borderWidth = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OneSignal.addTrigger("itemEdit", withValue: "loaded")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if itemAisle == "" {
            isLocated = false
        } else {
            isLocated = true
        }
    }
    
    func setupInitData() {
        print("ITEM--->:", item_id)
        print("ITEMPRICE--->:", itemPrice)
        print("ITEM IMAGE--->:", itemPic)
        self.itemNameLabel.text = itemName
        self.quantityLabel.text = itemQuantity
        self.txtPrice.text = itemPrice
        self.aisleLabel.text = itemAisle
        self.setAisleButtonTitle(aisle: itemAisle)

        toggleEnableMinusBtn()
    }
    
    func takePhoto()
    {
        let actionShhet = UIAlertController(title: Utils.AppName(), message: "Choose profile pic from", preferredStyle: .actionSheet)
        actionShhet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alertAction) in
            self.openCamera()
        }))
        actionShhet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alertAction) in
            self.openGallery()
        }))
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            actionShhet.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { (alertAction) in
            }))
        }else{
            actionShhet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction) in
            }))
        }
        
        if let popoverController = actionShhet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(actionShhet, animated: true) {
        }
    }
    
    @IBAction func btnRemoveTapped(_ sender: UIButton) {
        
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        
        param[ApiConstant.ApiKey.kItemId] = item_id
        param[ApiConstant.ApiKey.kImage] = imageName
        let actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kRemoveItemImage + SharedPreference.getUserData().token!
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    
    @IBAction func btnTakePhotoTapped(_ sender: UIButton) {
        self.takePhoto()
    }
    func setAisleButtonTitle(aisle: String) {
        let btnTitle = aisle == "" ? "Tap here to add aisle" : ""
        self.aisleBtn.setTitle(btnTitle, for: .normal)
    }
    func toggleEnableMinusBtn() {
        let quantity = Int(quantityLabel.text!) ?? 1
        minusBtn.isEnabled = quantity > 1
    }
    
    @IBAction func btnReTakePhotoTapped(_ sender: UIButton) {
        self.takePhoto()
    }
    
    func openCamera(){
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imgPicker.sourceType = .camera
            self.present(imgPicker, animated: true, completion: nil)
        }else{
            self.showAnnouncement(withMessage: UseCaseMessage.NotAvailable.camera)
        }
    }
    func openGallery(){
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            imgPicker.sourceType = .photoLibrary
            self.present(imgPicker, animated: true, completion: nil)
        }else{
            self.showAnnouncement(withMessage: UseCaseMessage.NotAvailable.gallery)
        }
    }
    //MARK:- UIImagepicker controller delegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
        }
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            let data = UIImageJPEGRepresentation(image, 0.25)
            do {
                let urlString = String(describing: Utils.getAppDocumentDirectory()) + String(Utils.getCurrentTimeInterval()) + ".jpg"
                
                if let url = URL(string: urlString){
                    try data?.write(to: url, options: .atomicWrite)
                    self.itemImage.image = image
                    self.imageURlProf = urlString
                    lblTakePhoto.isHidden = true
                    btnTakePhoto.isHidden = true
                    lblPicItem.isHidden = false
                    itemImageView.isHidden = false
                    
                    
                    print("=====>>>>", self.imageURlProf)
                }
            }catch( _){
            }
        }
        
        self.dismiss(animated: true, completion: {})
    }
    
    @IBAction func minusBtnTapped(_ sender: UIButton) {
        var quantity = Int(quantityLabel.text!) ?? 1
        quantity = quantity - 1
        quantityLabel.text = String(quantity)
        toggleEnableMinusBtn()
    }
    
    @IBAction func plusBtnTapped(_ sender: UIButton) {
        var quantity = Int(quantityLabel.text!) ?? 1
        quantity = quantity + 1
        quantityLabel.text = String(quantity)
        toggleEnableMinusBtn()
    }
    
    @IBAction func selectAisleBtnTapped(_ sender: UIButton) {
        let aisle = self.storyboard?.instantiateViewController(withIdentifier: "AisleLocationVC") as! AisleLocationVC
        aisle.delegate = self
        aisle.modalPresentationStyle = .overCurrentContext
        self.present(aisle, animated: true) 
    }
    
    
    func selectExistAddress()
    {
        let aisle = self.storyboard?.instantiateViewController(withIdentifier: "AisleLocationVC") as! AisleLocationVC
        aisle.delegate = self
        aisle.modalPresentationStyle = .overCurrentContext
        self.present(aisle, animated: true)
    }
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        let quantity = self.quantityLabel.text!
        let price = self.txtPrice.text!
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        
        param[ApiConstant.ApiKey.kItemQuantity] = quantity
        param[ApiConstant.ApiKey.kItemId] = item_id
        param[ApiConstant.ApiKey.kId] = m_id
        param[ApiConstant.ApiKey.kPrice] = price
        param[ApiConstant.ApiKey.kItemImage] = URL(string :self.imageURlProf)
        let actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kUpdateItemQuantity + SharedPreference.getUserData().token!
        Apimanager.sharedManager.callAPIForUpload(dataDict: param, action: actio_str)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        txtPrice.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtPrice.resignFirstResponder()
        return true
    }
    
    
    //MARK:- Call API For AddItemLocation
    func callAPIForAddItemLocation(location: String){
        var actio_str = ""
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        let latitude = SharedPreference.getCurrentLocation().lat
        let longitude = SharedPreference.getCurrentLocation().long

        param[ApiConstant.ApiKey.kStoreId] = storeId
        param[ApiConstant.ApiKey.kItemId] = m_id
        param[ApiConstant.ApiKey.kLatitude] = latitude
        param[ApiConstant.ApiKey.kLongitude] = longitude
        param[ApiConstant.ApiKey.kLocation] = location
        param[ApiConstant.ApiKey.kListId] = self.listId
        if isPremium {
            actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kAddItemLocationPro + SharedPreference.getUserData().token!
        } else {
            actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kAddItemLocation + SharedPreference.getUserData().token!
        }
        
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    
    //MARK:- Call API For UpdateItemLocation
    func callAPIForUpdateItemLocation(location: String) {
        var actio_str = ""
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        let latitude = SharedPreference.getCurrentLocation().lat
        let longitude = SharedPreference.getCurrentLocation().long

        param[ApiConstant.ApiKey.kStoreId] = storeId
        param[ApiConstant.ApiKey.kItemId] = m_id
        param[ApiConstant.ApiKey.kLatitude] = latitude
        param[ApiConstant.ApiKey.kLongitude] = longitude
        param[ApiConstant.ApiKey.kLocation] = location
        param[ApiConstant.ApiKey.kListId] = self.listId
        if isPremium {
            actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kUpdateItemLocationPro + SharedPreference.getUserData().token!
        } else {
            actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kUpdateItemLocation + SharedPreference.getUserData().token!
        }
        
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    
    //MARK:- Call API For Reward
    func callAPIRewardMethod(str: String) {
        Apimanager.sharedManager.webServiceDelegate = self
        let token = SharedPreference.getUserData().token
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kToken] = token
        param[ApiConstant.ApiKey.kPremium] = str
        let act_str = ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kGetReward
        
        Apimanager.sharedManager.callApiPostMethod(str_Action: act_str, param: param)
    }
    
    //MARK:- Aisle location delegate method
    func SetAisleLocation(id: String , name : String) {
        self.dismiss(animated: true, completion: nil)
        
        tempAisle = name
        if isLocated {
            self.callAPIForUpdateItemLocation(location: name)
        } else {
            self.callAPIForAddItemLocation(location: name)
        }
        
    }
    
    //MARK:- Server Response
    func success_serverResponse(data: Any, actionStr: String) {
        if (actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kAddItemLocation + SharedPreference.getUserData().token! || actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kUpdateItemLocation + SharedPreference.getUserData().token!) {
            guard let baseModel = Mapper<BaseModel<ShoppingListItemModel>>().map(JSONObject: data) else {
                return
            }
            if baseModel.isSuccess {
                aisleLabel.text = tempAisle
                self.setAisleButtonTitle(aisle: tempAisle)
                tempAisle = ""
                self.callAPIRewardMethod(str: "aisle")
            }else{
                self.showAnnouncement(withMessage: "You are not currently in that store. Check the map for your current location")
            }
        } else if (actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kAddItemLocationPro + SharedPreference.getUserData().token! || actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kUpdateItemLocationPro + SharedPreference.getUserData().token!) {
            guard let baseModel = Mapper<BaseModel<ShoppingListItemModel>>().map(JSONObject: data) else {
                return
            }
            if baseModel.isSuccess {
                aisleLabel.text = tempAisle
                self.setAisleButtonTitle(aisle: tempAisle)
                tempAisle = ""
                self.callAPIRewardMethod(str: "aislepro")
            }else{
                self.showAnnouncement(withMessage: baseModel.msg ?? "Failed to update the Location")
            }
        }
        else if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kUpdateItemQuantity + SharedPreference.getUserData().token! {
            guard let baseModel = Mapper<BaseModel<ShoppingListItemModel>>().map(JSONObject: data) else {
                return
            }
            if baseModel.isSuccess {
                MainClass.appDelegate.navController.popViewController(animated: true)
            }else{
                self.showAnnouncement(withMessage: "Failed to update item. Please try again.")
            }
        } else if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kRemoveItemImage + SharedPreference.getUserData().token! {
            guard let baseModel = Mapper<BaseModel<ShoppingListItemModel>>().map(JSONObject: data) else {
                return
            }
            if baseModel.isSuccess {
                self.itemImageView.isHidden = true
                self.lblPicItem.isHidden = true
                self.lblTakePhoto.isHidden = false
                self.btnTakePhoto.isHidden = false
            }else{
                self.showAnnouncement(withMessage: "Failed to remove item image. Please try again.")
            }
        } else if actionStr == ApiConstant.ApiType.kAccount + ApiConstant.ApiAction.kGetReward {
            guard let baseModel = Mapper<BaseModel<LoginModel>>().map(JSONObject: data) else{
                return
            }
            if baseModel.isSuccess{
                
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage:  String(describing: (data as AnyObject).userInfo[NSLocalizedDescriptionKey]!).replacingOccurrences(of: "}", with: "").components(separatedBy: "=").last! )
    }
    
}
