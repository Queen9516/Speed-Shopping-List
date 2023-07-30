//
//  HomeVC.swift
//  Speed Shopping List
//
//  Created by info on 12/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import GoogleMaps
import ObjectMapper
import GooglePlaces
import CoreLocation
import GooglePlacePicker
import OneSignal

protocol AddNewStoreDelegate {
    func FetchStores(storesData: StoreModel)
}
class HomeVC: BaseViewController  , Myprotocol {
    
    var delegate: AddNewStoreDelegate?
    
    @IBOutlet weak var btn_list: UIButton!
    @IBOutlet weak var btn_map: UIButton!
    @IBOutlet weak var tblStoreList: UITableView!
    @IBOutlet weak var viewGoogleSearch: UIView!
    @IBOutlet weak var btn_GoogleSearch: UIButton!
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var addStoresView: UIView!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    var arrAddStore = [ShoppingModelAddToGoogleSearch]()
    var token = ""
    var index = Int()
    var storesName = ""
    var storesLat  =  Double()
    var storesLong = Double()
    var lat = String()
    var long = String()
    var storesAddress = ""
    var country = ""
    var state = ""
    var city = ""
    var zipcode = ""
    var address = ""
    var subLicality = ""
    var radiusSet = 5.0
   // var savedRadius = SharedPreference.getRadius()
    @IBOutlet weak var map_view: GMSMapView!
    let myview = UIView()
    let dropDown = UIButton(frame: CGRect(x: 0, y: 0, width: menuIconSize.width, height: 45))
    var arrStore = [StoreModel]()
    var arrSearchStore = [StoreModel]()
    
    override func viewDidLoad() {
        print(radiusSet)
        super.viewDidLoad()
        addStoresView.layer.cornerRadius = 20
        addStoresView.layer.masksToBounds = true

        tfSearch.delegate = self
        self.viewDidLoadContent()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewWillAppearContent()
        OneSignal.addTrigger("home", withValue: "loaded")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func listAddedSucees() {
        self.dismiss(animated: false) {}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.navigationController?.popViewController(animated: false)
//            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    func listAddedSuceesGuese(name: String) {
        print(name)
        print(arrSearchStore[index])
        var arr = SharedPreference.getGuestShoppingList()
        arr.append(["storeName":arrSearchStore[index].name,"name":name,"address":arrSearchStore[index].address])
        SharedPreference.saveGuestShoppingList(list: arr)
        self.dismiss(animated: false) {}
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    //MARK:- GoogleSearchBar Button To Add Store
    @IBAction func btn_GoogleSearchBar(_ sender: UIButton){
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            let searchBarTextAttributes: [String : AnyObject] = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white, NSAttributedStringKey.font.rawValue: UIFont.systemFont(ofSize: UIFont.systemFontSize)]
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = searchBarTextAttributes
            present(autocompleteController, animated: true, completion: nil)
        
    }
}
//***************************************************//
//MARK:- viewdidload & viewwillappear content
extension HomeVC {
    func viewDidLoadContent(){
        tblStoreList.rowHeight = UITableViewAutomaticDimension
        tblStoreList.separatorStyle = UITableViewCellSeparatorStyle.none
        self.title = "Stores Near You"
        self.btn_List(self.btn_list)
        print(token)
        self.setupBack()
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        definesPresentationContext = true
        self.map_view.settings.myLocationButton = true
        self.map_view.isMyLocationEnabled = true
    }
    func viewWillAppearContent(){
        self.setRadius()
        self.showNavigationBar()
        self.callApiForGetStore(distance: "5")
        print(SharedPreference.getCurrentLocation())
        map_view.isMyLocationEnabled = true
        map_view.delegate = self
        map_view.camera = GMSCameraPosition.camera(withLatitude: SharedPreference.getCurrentLocation().lat, longitude: SharedPreference.getCurrentLocation().long, zoom: 12.0)
        self.btn_GoogleSearch.imageView?.contentMode = .scaleAspectFit
        
        //tfSearch.addTarget(self, action: #selector(SearchStore(sender:)), for: .editingChanged)
         self.dropDown.setTitle("\("\(SharedPreference.getRadius())".components(separatedBy: ".")[0]) miles", for: .normal)
        self.dropDown.isHidden = false
      //  self.dropDown.setTitle("All Stores", for: .normal)
    }
}
//MARK:- reverseGeocodeLocation (Get Address from lat & long)
extension HomeVC {
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        //21.228124
        let lon: Double = Double("\(pdblLongitude)")!
        //72.833770
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                guard let pm = placemarks else {
                    let alert = UIAlertController(title: "Alert!", message: "Can't get geo location.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let action = UIAlertAction(title: "OK", style: .default) { (alertAction) in
                    }
                    alert.addAction(action)
                    self.present(alert, animated:true, completion: nil)
                    return
                }
                if pm.count > 0 {
                    let pm = placemarks![0]
                    print(pm.country ?? "")
                    self.country = pm.country ?? ""  //country
                    print(pm.locality ?? "")
                    self.city = pm.locality ?? ""  // city
                    print(pm.subLocality ?? "")
                    // self.address = pm.subLocality ?? self.city  // address
                    print(pm.thoroughfare ?? "")
                    self.address = pm.thoroughfare ?? ""   // address
                    if self.address == "" {
                        if self.subLicality == "" {
                            self.address = self.city
                        }else{
                            self.address = self.subLicality
                        }
                    }
                    print(pm.postalCode ?? "")
                    self.zipcode = pm.postalCode ?? ""  // zipCode
                    print(pm.administrativeArea ?? "")
                    self.state = pm.administrativeArea ?? "" // state
                    self.callAPIForAddStore()
                }
        })
    }
}
//MARK:- Usable Function
extension HomeVC {
    func getDistanceBtwToLocation(startLat: Double , startLong: Double , endLat: Double, endLong: Double) -> Double {
        
        let coordinate₀ = CLLocation(latitude: startLat, longitude: startLong)
        let coordinate₁ = CLLocation(latitude: endLat, longitude: endLong)
        let distanceInMeters = coordinate₀.distance(from: coordinate₁) // result is in meters
        let distanceInMiles = distanceInMeters * 0.00062137
        print("distance in miles \(distanceInMiles)")
        return distanceInMiles
        
    }
    func addStoresOnMap(){
        map_view.clear()
        for store in arrSearchStore {
            let marker = GMSMarker()
            marker.title = store.name
            marker.snippet = store.address
            marker.userData = store
            marker.position = CLLocationCoordinate2DMake(Double(store.latitude!)!, Double(store.longitude!)!)
            marker.map = map_view
        }
    }
    func goToAddShopingList(with storeData: StoreModel){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddActionVC") as! AddActionVC
        vc.myprotocol = self
        vc.storeData = storeData
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
        
    }
    //MARK:- Search Filter
    @objc func Search_Store(tempStr: String){
        if tempStr == "" {
            arrSearchStore = self.arrStore
            
        }else{
            //let str = self.tfSearch.text?.uppercased()
            let filterArr = self.arrStore.filter { store in
                return(store.name!.uppercased().contains(tempStr.uppercased()))
            }
            print(filterArr)
            arrSearchStore = filterArr
        }
        tblStoreList.reloadData()
    }
  
    
    
    func removeMiddleString(inputString: String, fromIndex: Int, lengthToRemove: Int)->String
    {
        let c = inputString//.characters
        let r_a = c.index(c.startIndex, offsetBy: 0)..<c.index(c.startIndex, offsetBy: fromIndex)
        let substring_a = inputString[r_a]
        let r_b = c.index(c.startIndex, offsetBy: substring_a.count+lengthToRemove)..<c.index(c.endIndex, offsetBy: 0)
        let substring_b = inputString[r_b]
        return "\(substring_a)\(substring_b)"
    }
    func insertStringInMiddle(inputString: String, stringToAdd: String, onIndex: Int)->String
    {
        // This is the input string.
        let c = inputString//.characters
        let r_a = c.index(c.startIndex, offsetBy: 0)..<c.index(c.startIndex, offsetBy: onIndex)
        let substring_a = inputString[r_a]
        //print("A=>", substring_a)
        //        if substring_a.count > 0
        //        {
        let r_b = c.index(c.startIndex, offsetBy: substring_a.count)..<c.index(c.endIndex, offsetBy: 0)
        let substring_b = inputString[r_b]
        return "\(substring_a)\(stringToAdd)\(substring_b)"
        //        }
        
        return "\(substring_a)\(stringToAdd)"
        //print("B=>",substring_b)
        
    }
}



//MARK:- List and Map Button and dropDownSet radius)
extension HomeVC {
    @IBAction func btn_Map(_ sender: UIButton) {
        self.title = "Choose From Map Below"
        viewGoogleSearch.isHidden = true
        btn_list.isSelected = false
        btn_map.isSelected = true
        btn_map.backgroundColor = UIColor.hexStringToUIColor(AppColor.blueColor)
        btn_list.backgroundColor = UIColor.white
        UIView.animate(withDuration: 0.2) {
            self.viewGoogleSearch.isHidden = true
        }
        UIView.animate(withDuration: 0.5) {
            self.map_view.isHidden = false
        }
        self.callApiForGetStore(distance: "\(self.radiusSet)")
    }
    @IBAction func btn_List(_ sender: UIButton) {
        self.dropDown.isHidden = false
       // self.dropDown.setTitle("All Stores", for: .normal)
        self.dropDown.setTitle("\("\(SharedPreference.getRadius())".components(separatedBy: ".")[0])miles", for: .normal)
        self.title = "Stores Near You"
        UIView.animate(withDuration: 0.2) {
            self.map_view.isHidden = true
        }
        UIView.animate(withDuration: 0.5) {
            self.viewGoogleSearch.isHidden = false
        }
        btn_list.isSelected = true
        btn_map.isSelected = false
        btn_list.backgroundColor = UIColor.hexStringToUIColor(AppColor.blueColor)
        btn_map.backgroundColor = UIColor.white
        self.callApiForGetStore(distance: "5")
    }
    func setRadius(){
        dropDown.setTitle(" set radius", for: .normal)
        dropDown.setImage(UIImage(named: "dropDown"), for: .normal)
        dropDown.titleLabel?.font =  UIFont(name: "HelveticaNeue-Bold", size: 13)
        dropDown.sizeToFit()
        dropDown.addTarget(self, action: #selector(setRadiusForStores), for: .touchUpInside)
        let item1 = UIBarButtonItem()
        item1.customView = dropDown
        self.navigationItem.setRightBarButtonItems([item1] , animated: true)
    }
    @objc func setRadiusForStores(){
        //self.googlePicker()
        let alert = UIAlertController(title: Utils.AppName(), message: "Choose radius for search stores ", preferredStyle: .actionSheet)
        
        let radius5 = UIAlertAction(title: "5 miles", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("5")
            self.tfSearch.text = ""
            self.dropDown.setTitle("5 miles", for: .normal)
            self.radiusSet = 5
            SharedPreference.saveSetRadius(double: self.radiusSet)
            self.callApiForGetStore(distance: "5")
        })
        let radius10 = UIAlertAction(title: "10 miles", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("10")
            self.tfSearch.text = ""
            self.dropDown.setTitle("10 miles", for: .normal)
            self.radiusSet = 10
            SharedPreference.saveSetRadius(double: self.radiusSet)
            self.callApiForGetStore(distance: "10")
        })
        let radius25 = UIAlertAction(title: "25 miles", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("25")
            self.tfSearch.text = ""
            self.dropDown.setTitle("25 miles", for: .normal)
            self.radiusSet = 25
            SharedPreference.saveSetRadius(double: self.radiusSet)
            ///
            self.callApiForGetStore(distance: "25")
            
        })
        let radius50 = UIAlertAction(title: "50 miles", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("50")
            self.tfSearch.text = ""
            self.dropDown.setTitle("50 miles", for: .normal)
            self.radiusSet = 50
            SharedPreference.saveSetRadius(double: self.radiusSet)
            self.callApiForGetStore(distance: "50")
        })
        let radius100 = UIAlertAction(title: "100  miles", style: .default, handler:
        {
            (alert: UIAlertAction!) -> Void in
            print("100")
            self.tfSearch.text = ""
            self.dropDown.setTitle("100 miles", for: .normal)
            self.radiusSet = 100
            SharedPreference.saveSetRadius(double: self.radiusSet)
            self.callApiForGetStore(distance: "100")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:
        {
            (alert: UIAlertAction!) -> Void in
            
        })
        alert.addAction(radius5)
        alert.addAction(radius10)
        alert.addAction(radius25)
        alert.addAction(radius50)
        alert.addAction(radius100)
        alert.addAction(cancelAction)
        alert.view.backgroundColor = UIColor.hexStringToUIColor(AppColor.blueColor)
        alert.view.layer.cornerRadius = 40
        self.present(alert, animated: true, completion: nil)
    }
}
//MARK:- API Calling functions
extension HomeVC {
    func callAPiForGettingShoppingList(){
        Apimanager.sharedManager.webServiceDelegate = self
        let act_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kShoppingList + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethodWithoutParam(str_Action: act_str)
    }
    
    func callApiForGetStore(distance: String){
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kLatitude] = SharedPreference.getCurrentLocation().lat
        param[ApiConstant.ApiKey.kLongitude] = SharedPreference.getCurrentLocation().long
        param[ApiConstant.ApiKey.kDistance]  = distance //SharedPreference.getRadius()
        var act_str = ""
//        if SharedPreference.getGuestData() == true
//        {
//            act_str = ApiConstant.ApiType.kGuest + ApiConstant.ApiAction.kGetStores
//        }else{
            act_str = ApiConstant.ApiType.kStore + ApiConstant.ApiAction.kGetStores + SharedPreference.getUserData().token
       // }
       
        Apimanager.sharedManager.callApiPostMethod(str_Action: act_str, param: param)
    }
    
    //https://www.speedshopperapp.com/app/api/Guestcommon/getStores
    
    
    func callAPIForAddStore(){
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kName] = self.storesName
        param[ApiConstant.ApiKey.kEmail] = ""
        param[ApiConstant.ApiKey.kLatitude] =  self.lat
        param[ApiConstant.ApiKey.kLongitude] = self.long
        param[ApiConstant.ApiKey.kAddress] =   address//self.storesAddress
        param[ApiConstant.ApiKey.kContact] = ""
        param[ApiConstant.ApiKey.kCurrentLatitude] =  SharedPreference.getCurrentLocation().lat
        param[ApiConstant.ApiKey.kCurrentLongitude] = SharedPreference.getCurrentLocation().long
        param[ApiConstant.ApiKey.kCity] = city
        param[ApiConstant.ApiKey.kState] = state
        param[ApiConstant.ApiKey.kCountry] = country
        param[ApiConstant.ApiKey.kZipCode] = zipcode
        let actio_str = ApiConstant.ApiType.kStore + ApiConstant.ApiAction.kAdd + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
        
        
        //let distance = self.getDistanceBtwToLocation(startLat: Double(SharedPreference.getCurrentUserLocation_inStr().lat)!, startLong: Double(SharedPreference.getCurrentUserLocation_inStr().long)!, endLat: Double(lat)!, endLong: Double(long)!)
        //        print("distance btw 2 lat long \(distance)")
        //       // print(radiusSet)
        //        if distance < SharedPreference.getRadius() {
        //            self.AddStores()
        //        }else {
        //            let radius1 = SharedPreference.getRadius()
        //            self.showAnnouncement(withMessage: "store is not in \(Int(radius1)) miles range")
        //            self.dropDown.setTitle("\("\(SharedPreference.getRadius())".components(separatedBy: ".")[0])miles", for: .normal)
        //             //self.dropDown.setTitle("\(Int(SharedPreference.getRadius()))miles", for: .normal)
        //        }
    }
}
//MARK:- Google map delegate method and GMSAutocompleteViewControllerDelegate
extension HomeVC: GMSAutocompleteViewControllerDelegate, GMSAutocompleteResultsViewControllerDelegate , GMSMapViewDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    //MARK:- GMSAutocompleteResultsViewControllerDelegate
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        
        print("Place name: \(place.name)")
        //print("Place address: \(place.formattedAddress)")
      //  print("Place attributions: \(place.attributions)")
        print("place Latitude: \(place.coordinate.latitude)")
        print("place long: \(place.coordinate.longitude)")
        
    }
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        
        print("Place name: \(place.name)")
    //    print("Place address: \(place.formattedAddress)")
      //  print("Place attributions: \(place.attributions)")
        print("place Latitude: \(place.coordinate.latitude)")
        print("place long: \(place.coordinate.longitude)")
        
        let addressComponents = place.addressComponents
        for components in addressComponents! {
            if components.type == "sublocality_level_1" {
                print(components.name) // Address  "Khandwa Road"
                subLicality = components.name
            }
        }
        /* for components in addressComponents! {
         if components.type == "country" {
         print(components.name) // country  India
         country = components.name
         }else if components.type == "administrative_area_level_1" {
         print(components.name) //state Madhya Pradesh"
         state = components.name
         }else if components.type == "locality" {
         print(components.name) // city Indore
         city = components.name
         }else if components.type == "postal_code" {
         print(components.name) // zipCode  452001
         zipcode = components.name
         }else if components.type == "sublocality_level_1" {
         print(components.name) // Address  "Khandwa Road"
         address = components.name
         }
         }*/
        
        storesLat =  place.coordinate.latitude
        storesLong = place.coordinate.longitude
        // Convert double to string
        lat = String(storesLat)
        long = String(storesLong)
        storesName = place.name ?? ""
        storesAddress = place.formattedAddress!
       
        self.getAddressFromLatLon(pdblLatitude: lat, withLongitude: long)
        
    }
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker){
        print("Ho Gya Tap")
        print(marker.userData ?? "No data available")
        let storeData = marker.userData as! StoreModel
        self.goToAddShopingList(with: storeData)
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print( "coordinate:: \(coordinate)")
    }
}
//MARK:- Tableview delegate & data source method
extension HomeVC:  UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSearchStore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeCell
        
        cell.selectionStyle = .none
        let data = arrSearchStore[indexPath.row]
        cell.lbl_storeName.text = arrSearchStore[indexPath.row].name
        cell.lable.attributedText = String().attributedText(withString: String(format: "Address: %@", data.address!), boldString: "Address: ", font: cell.lable.font)
        cell.viewCell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.viewCell.layer.shadowOpacity = 1
        cell.viewCell.layer.shadowRadius = 5
        cell.viewCell.layer.shadowOffset = CGSize.zero
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        index = indexPath.row
        self.goToAddShopingList(with: arrSearchStore[indexPath.row])
    }
    
    
}
//MARK:- Server response
extension HomeVC: WebServiceDelegate {
    func success_serverResponse(data: Any, actionStr: String) {
        //StoreModel
       if actionStr == ApiConstant.ApiType.kGuest + ApiConstant.ApiAction.kGetStores {
            guard let baseModel = Mapper<BaseListModel<StoreModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            
            if baseModel.isSuccess{
                arrStore = baseModel.object!
                arrSearchStore = arrStore
                
                // SharedPreference.saveStoreData(user: arrStore)
                //tblStoreList.reloadData()
                Search_Store(tempStr: "")
                addStoresOnMap()
            }else{
                arrSearchStore.removeAll()
                tblStoreList.reloadData()
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }else if actionStr == ApiConstant.ApiType.kStore +
      
        ApiConstant.ApiAction.kGetStores + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseListModel<StoreModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            
            if baseModel.isSuccess{
                arrStore = baseModel.object!
                arrSearchStore = arrStore
                
                // SharedPreference.saveStoreData(user: arrStore)
                //tblStoreList.reloadData()
                Search_Store(tempStr: "")
                addStoresOnMap()
            }else{
                arrSearchStore.removeAll()
                tblStoreList.reloadData()
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }else if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kShoppingList + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseListModel<StoreModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            
            if baseModel.isSuccess{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShoppingListVC") as! ShoppingListVC
                self.navigationController?.pushViewController(vc, animated: true)
                //addStoresOnMap()
            }else{
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ShoppingListVC") as! ShoppingListVC
                self.navigationController?.pushViewController(vc, animated: true)
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
        else if actionStr == ApiConstant.ApiType.kStore + ApiConstant.ApiAction.kAdd + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseModel<StoreModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            if baseModel.isSuccess {
                if baseModel.msg == "Store is not in your range."{
                    self.showAnnouncement(withMessage: baseModel.msg!)
                }else{
                    //  self.dropDown.setTitle("\("\(SharedPreference.getRadius())".components(separatedBy: ".")[0])miles", for: .normal)
                    
                    self.delegate?.FetchStores(storesData: baseModel.object!)
                    
                    //******************************************/////**********/////
                    //self.callApiForGetStore(distance: "")
                }
                
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
}
//MARK :- Uitextfield delegate method
extension HomeVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let str = textField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if str?.count == 0 {
            self.showAnnouncement(withMessage: "Please enter keyword for search", closer: {
            })
        }else{
            
           // self.callAPIForGetspeedShopperMarket(page_no: page, text2Search: self.tfSearchStore.text!)
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let oldLength: Int = (textField.text?.count)!
        let newLength: Int = oldLength + string.count - range.length
        
        
        var strToSearch = "\(self.tfSearch.text ?? "")"
        
        if (range.length > 0 && string != "") {
            strToSearch = removeMiddleString(inputString: strToSearch, fromIndex: range.location, lengthToRemove: range.length)
            strToSearch = insertStringInMiddle(inputString: strToSearch, stringToAdd: string, onIndex: range.location)
        }
        else if range.length > 0 {
            strToSearch = removeMiddleString(inputString: strToSearch, fromIndex: range.location, lengthToRemove: range.length)
        }
        else if string != "" {
            strToSearch = insertStringInMiddle(inputString: strToSearch, stringToAdd: string, onIndex: range.location)
        }
       // tfSearch.addTarget(self, action: #selector(SearchStore(sender:)), for: .editingChanged)
       Search_Store(tempStr: strToSearch)

        return true
    }
}
extension String{
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedStringKey.font: font])
        let boldFontAttribute: [NSAttributedStringKey: Any] = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
}

