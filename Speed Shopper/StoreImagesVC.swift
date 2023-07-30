//
//  StoreImagesVC.swift
//  Speed Shopping List
//
//  Created by Wang on 11/28/20.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import OneSignal

class StoreImagesVC: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    
    @IBOutlet weak var collectionView: UICollectionView!
//    var imageItems: [ImageModel] = []
    var list_id = ""
    
    var arrLogoList = [StoreLogoListModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Store Logos"
        self.loadImageItems()
        collectionView.reloadData()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        OneSignal.addTrigger("storeImage", withValue: "loaded")
    }
    
    func loadImageItems() {
        
        Apimanager.sharedManager.webServiceDelegate = self

        let act_str = ApiConstant.ApiType.kComman + ApiConstant.ApiAction.kGetLogos + SharedPreference.getUserData().token
        
         Apimanager.sharedManager.callApiGetMethod(str_Action: act_str)
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrLogoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellIdentifier", for: indexPath) as! ImageCollectionCell
        
        cell.setImageItem(arrLogoList[indexPath.row])
        return cell
    }
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.callAPIForUpdateShoppingListImage(list_id: self.list_id, image: arrLogoList[indexPath.row].image_name ?? "logo_0.png")
    }
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let picDimension = self.view.frame.size.width / 4.0
        return CGSize(width: picDimension, height: picDimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let leftRightInset = self.view.frame.size.width / 15.0
        return UIEdgeInsets(top: 5.0, left: leftRightInset, bottom: 10.0, right: leftRightInset)
    }
    
    //MARK: API For UpdateShoppingList
    func callAPIForUpdateShoppingListImage(list_id: String, image: String) {
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kListId] = list_id
        param[ApiConstant.ApiKey.kImage] = image
        let actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kUpdateShoppingListLogo + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }

}

extension StoreImagesVC: WebServiceDelegate {
    //MARK:- Server response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kUpdateShoppingListLogo + SharedPreference.getUserData().token! {
            guard let baseModel = Mapper<BaseModel<ShoppingListModel>>().map(JSONObject: data) else {
                print("Parse Error")
                return
            }
            if baseModel.isSuccess {
                _ = navigationController?.popViewController(animated: true)
            }
            else {
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        } else if actionStr == ApiConstant.ApiType.kComman + ApiConstant.ApiAction.kGetLogos + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseListModel<StoreLogoListModel>>().map(JSONObject: data) else {
                print("Parse Error")
                return
            }
            if baseModel.isSuccess {
                
                arrLogoList = baseModel.object!
                collectionView.reloadData()
                print("json data:-------->", arrLogoList)
            } else {
                print("json data:-------->", baseModel.msg!)
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    func error_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kUpdateShoppingListLogo + SharedPreference.getUserData().token! {
            self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
        } else if actionStr == ApiConstant.ApiType.kComman + ApiConstant.ApiAction.kGetLogos + SharedPreference.getUserData().token {
        
            self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
        }
        
    }
}

class ImageCollectionCell: UICollectionViewCell {
    @IBOutlet weak var storeImage: UIImageView!
    func setImageItem(_ item:StoreLogoListModel) {
        let link = "https://www.speedshopperapp.com/app/public/store_images/" + item.image_name!
        let url = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
//        storeImage.image = UIImage(named: item.image_name ?? "logo_0.png")
        let imageURL = URL(string: url!)!

        DispatchQueue.global().async {
            // Fetch Image Data
            if let data = try? Data(contentsOf: imageURL) {
                DispatchQueue.main.async {
                    // Create Image and Update Image View
                    self.storeImage.image = UIImage(data: data)
                }
            }
        }
    }
    
}
