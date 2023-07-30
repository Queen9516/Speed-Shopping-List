//
//  SearchStoreVC.swift
//  Speed Shopping List
//
//  Created by mac on 26/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import OneSignal

class SearchStoreVC: BaseViewController ,UITableViewDelegate, UITableViewDataSource, WebServiceDelegate , UISearchBarDelegate{
    @IBOutlet weak var tblStoreList: UITableView!
    var arrStore = [StoreModel]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        callApiForGetStore(storeName: "")
        self.setupBack()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        OneSignal.addTrigger("search", withValue: "loaded")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func callApiForGetStore(storeName : String){
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kToken] = SharedPreference.getUserData().token
        param[ApiConstant.ApiKey.kLatitude] = SharedPreference.getCurrentLocation().lat
        param[ApiConstant.ApiKey.kLongitude] = SharedPreference.getCurrentLocation().long
        param[ApiConstant.ApiKey.kName] = storeName
        let act_str = ApiConstant.ApiType.kStore + ApiConstant.ApiAction.kGetStores
        Apimanager.sharedManager.callApiPostMethod(str_Action: act_str, param: param)
    }
    
    //MARK:- Tableview delegate & data source method
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrStore.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeCell
        let data = arrStore[indexPath.row]
        //        let imgPath = data
        //        cell.img.image = imgArray[indexPath.row]
        let imgPath = data.path! + data.logo!
        cell.img?.sd_setImage(with: URL(string: imgPath), placeholderImage: #imageLiteral(resourceName: "img"), options: .progressiveLoad, progress: nil, completed: nil)
        cell.lable.text! = data.address! //addressArray1[indexPath.row]
        cell.viewCell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.viewCell.layer.shadowOpacity = 1
        cell.viewCell.layer.shadowRadius = 5
        cell.viewCell.layer.shadowOffset = CGSize.zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.goToShopingList(with: arrStore[indexPath.row])
    }

    func goToShopingList(with storeData: StoreModel){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShoppingListVC") as! ShoppingListVC
        vc.storeData = storeData
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:- Search bar delegate method
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text!.count > 0 {
            callApiForGetStore(storeName: searchBar.text!)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    //MARK:- Server response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kStore + ApiConstant.ApiAction.kGetStores{
            guard let baseModel = Mapper<BaseListModel<StoreModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            if baseModel.isSuccess{
                arrStore = baseModel.object!
                tblStoreList.reloadData()
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
}
