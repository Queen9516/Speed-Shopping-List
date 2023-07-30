import UIKit
import ObjectMapper
import SYBlinkAnimationKit
import CoreLocation
import GoogleMobileAds
import StoreKit
import OneSignal

protocol ShoppingListDelegate {
    func handleAction(action: ShoppingListModel)
}

class ShoppingListDialog: BaseViewController, Myprotocol, AddNewStoreDelegate {
    
    var delegate: ShoppingListDelegate?
    var ezData = EZListModel()
    var shopData = ShoppingListModel()
    
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var tblShoppingList: UITableView!
    @IBOutlet weak var listLable: SYLabel!
    @IBOutlet weak var vwIntro: UIView!

    @IBOutlet weak var overlayView: UIView!
    @IBOutlet var bannerView: GADBannerView!
    var storeData = StoreModel()
    var arrStore = ShoppingModel()
    var arrShoppingList = [ShoppingListModel]()
    
    var viewModel = ViewModel()
    
    var list = String()
    var index = Int()
    var tf = String()
    var token = String()
    var store_id = String()
    var arrList = ""
    var itemArray = ["Grocery Store(Jun)", "Vegetables", "Soft Drinks", "Fruits", "Dry Fruits", "Shopping for gift", "My Dresses", "Electronics gadget"]
    var isPremium: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overlayView.isHidden = true
        tblShoppingList.rowHeight = UITableViewAutomaticDimension
        tblShoppingList.separatorStyle = UITableViewCellSeparatorStyle.none
        self.title = "My Lists"
       // self.listLable.backgroundColor = UIColor.black
        self.dismiss(animated: true, completion: nil)
        setupSyncForaShoppingList()
        let imageData = try! Data(contentsOf: Bundle.main.url(forResource: "pointing_hand", withExtension: "gif")!)
        imgArrow.image = UIImage.gif(data: imageData)
       // BlinkView()
        isPremium = UserDefaults.standard.bool(forKey: UseCaseMessage.Purchase.premium)
        isPremium = true
        if isPremium {
            bannerView.isHidden = true
            bannerViewHeight.constant = 0.0
        } else {
            bannerView.isHidden = false
            self.bannerView.adUnitID = "ca-app-pub-1558394739169751/4978387294"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
        }
    }
    
    @IBAction func detailTapped(_ sender: UIButton) {
        print("shopping list: ", arrShoppingList[sender.tag])
        viewModel.delegate = self
        let list_id =  self.arrShoppingList[sender.tag].id!
        
        if isPremium {
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "StoreImagesVC") as! StoreImagesVC
            vc.list_id =  list_id
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            
            if UserDefaults.standard.bool(forKey: "purchased") {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "StoreImagesVC") as! StoreImagesVC
                vc.list_id =  list_id
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                guard let product = viewModel.getProductForItem(at: 0) else {
                    showSingleAlert(withMessage: "Renewing this item is not possible at the moment.")
                    return
                }
                showAlert(for: product, id: list_id)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Notify the ViewModel object that the View part is ready.
        viewModel.viewDidSetup()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !self.getCurrentLocationEnabledCondition(){
            self.goToAppSettingForEnableLocation()
        }else{
            callAPiForGettingShoppingList()
        }
        
        UIApplication.shared.isIdleTimerDisabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(updateUser(not:)), name: LocationNotificationName1.userUpdateLocation, object: nil)
        OneSignal.addTrigger("shoppingList", withValue: "loaded")
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil);
    }
    
    static func showPopup(parentVC: BaseViewController, ezData1: EZListModel){
        if let popupViewController = parentVC.storyboard?.instantiateViewController(withIdentifier: "ShoppingListDialog") as? ShoppingListDialog {
            popupViewController.modalPresentationStyle = .custom
            popupViewController.modalTransitionStyle = .crossDissolve
            popupViewController.delegate = parentVC as? ShoppingListDelegate
            popupViewController.ezData = ezData1;
            parentVC.present(popupViewController, animated: true)
        }
    }
    
    //MARK:-Notification Method
    @objc func updateUser(not: Notification) {
        print("aa gya")
        self.callAPiForGettingShoppingList()
    }
    
    func goToAppSettingForEnableLocation(){
        self.showAnnouncementYesAndNoOption(withMessage: "Please Turn on Location from Settings or allow locations for Speed Shopping List", yesTitle: "Go to Settings", noTitle: "Retry", closer: {
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(settingsUrl)
                }
            }
        },closer1: {
            if !self.getCurrentLocationEnabledCondition(){
                self.goToAppSettingForEnableLocation()
            }else{
                self.callAPiForGettingShoppingList()
            }
        })
    }
    
    func BlinkView(){
//        listLable.text = "TAP THE SHOPPING LIST NAME TO ADD ITEMS"
//        listLable.textColor = UIColor.white
//        listLable.animationType = .text
//        listLable.startAnimating()
    }
    
    func setupSyncForaShoppingList(){
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 25)
        menuBtn.setImage(UIImage(named:"sync"), for: .normal)
        menuBtn.addTarget(self, action: #selector(SynButtonAction), for: UIControlEvents.touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 65)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 30)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
        
        
    }
    
    @objc func SynButtonAction(){
        if !self.getCurrentLocationEnabledCondition(){
            self.goToAppSettingForEnableLocation()
        }else{
            callAPiForGettingShoppingList()
        }
    }
    
    @objc func callAPiForGettingShoppingList() {
        Apimanager.sharedManager.webServiceDelegate = self
        
        var act_str = ""
        act_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kShoppingList + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethodWithoutParam(str_Action: act_str)
    }
    
    @objc func callAPiForAddingItemToMyLists() {
        Apimanager.sharedManager.webServiceDelegate = self
        
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kEZListId] = ezData.id
        param[ApiConstant.ApiKey.kMyListId] = shopData.id
        print("~~~~", ezData.id, shopData.id)
        var act_str = ""

        act_str = ApiConstant.ApiType.kEZLists + ApiConstant.ApiAction.KAddItemToEZLists + SharedPreference.getUserData().token
         Apimanager.sharedManager.callApiPostMethod(str_Action: act_str, param: param)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:- Myprotocol delegate method
    func listAddedSucees() {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.navigationController?.popViewController(animated: true)
        }
        
        self.callAPiForGettingShoppingList()
    }
    
    func listAddedSuceesGuese(name: String) {
        print(name)
    }
    
    func backData(addItem: String) {
        print(addItem)
        itemArray.append(addItem)
        tblShoppingList.reloadData()
    }
    
    //MARK:- Fetch new store delegate method
    func FetchStores(storesData: StoreModel) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddActionVC") as! AddActionVC
            vc.myprotocol = self
            vc.storeData = storesData
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func showSingleAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "Speed Shopping List", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(for product: SKProduct, id: String) {
        guard let price = IAPManager.shared.getPriceFormatted(for: product) else { return }
        
        let alertController = UIAlertController(title: product.localizedTitle,
                                                message: product.localizedDescription,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Buy now for \(price)", style: .default, handler: { (_) in
            
            if !self.viewModel.purchase(product: product, list_id: id) {
                self.showSingleAlert(withMessage: "In-App Purchases are not allowed in this device.")
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}

//MARK:- API Calling Function
extension ShoppingListDialog {
    //MARK:-  Call API For Remove Shopping List Item
    func CallAPIForRemoveShoppingList(list_id: String){
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kListId] = list_id
        let actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kRemoveShoppingList + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    //MARK- Call API for Add Item to Shopping List
    func CallAPIForAddItemtoShoppingList(id: String, item: String) {
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kListId] = id
        param[ApiConstant.ApiKey.kItem] = item
        let actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kAddItemToShoppingList + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    func callApiForGetStore(lat: Double,long: Double){
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kLatitude] = SharedPreference.getCurrentLocation().lat
        param[ApiConstant.ApiKey.kLongitude] = SharedPreference.getCurrentLocation().long
        let act_str = ApiConstant.ApiType.kStore + ApiConstant.ApiAction.kGetStores + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: act_str, param: param)
    }
    //MARK: API For UpdateShoppingList
    func callAPIForUpdateShoppingListName(list_id: String, name: String) {
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kListId] = list_id
        param[ApiConstant.ApiKey.kName] = name
        let actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kUpdateShoppingListName + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
}
//MARK:- Tableview Datasource Method
extension ShoppingListDialog: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrShoppingList.count == 0 {
            self.bannerView.isHidden = true
        }
        self.bannerView.isHidden = false
        return arrShoppingList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShoppingListCell
        let data = arrShoppingList[indexPath.row]
    
        cell.lable_ItemList.text = data.name?.capitalized
        cell.lbl_storeName.text =  data.store_name
        
        if data.address == nil {
            cell.lbl_storeFullAddress.text = "Address: null"
        } else {
            cell.lbl_storeFullAddress.text = "Address: " + data.address!
        }
        
        cell.viewCell.layer.shadowOpacity = 1
        cell.viewCell.layer.shadowOffset = CGSize.zero
        cell.viewCell.layer.shadowRadius = 5
        cell.btnDetail.tag = indexPath.row
    
        var link = ""
        if data.image == nil || data.image == "logo_0" {
//            cell.storeLogo.image = UIImage(named: "logo_0")
            link = "https://www.speedshopperapp.com/app/public/store_images/logo_0.png"
        } else {
            link = "https://www.speedshopperapp.com/app/public/store_images/" + data.image!
        }
        
        let url = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let imageURL = URL(string: url!)!

        DispatchQueue.global().async {
            // Fetch Image Data
            if let data = try? Data(contentsOf: imageURL) {
                DispatchQueue.main.async {
                    // Create Image and Update Image View
                    cell.storeLogo.image = UIImage(data: data)
                }
            }
        }

//        cell.storeLogo.image = UIImage(named: data.image ?? "logo_0")
        cell.btn_delete.isHidden = true
        cell.Btn_edit.isHidden = true
        
        let itemCount = Int(data.item_count ?? "0") ?? 0
        if (itemCount > 0) {
            cell.itemCountView.isHidden = false
            if (itemCount > 999) {
                cell.itemCountLabel.text = "99+"
            } else {
                cell.itemCountLabel.text = "\(itemCount)"
            }
            
        } else {
            cell.itemCountView.isHidden = true
        }
        if (indexPath.row % 3 == 0){
            cell.cellBox.image = UIImage(named: "redBox")
        }else if (indexPath.row % 3 == 1){
            cell.cellBox.image = UIImage(named: "greenBox")
        } else {
            cell.cellBox.image = UIImage(named: "yellowBox")
        }
        
        return cell
    }
    
    //MARK- Tableview delegate Method
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dialogMessage = UIAlertController(title: "", message: "Do you want to add these items to your list?", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.shopData = self.arrShoppingList[indexPath.row]
            self.callAPiForAddingItemToMyLists()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
}


extension ShoppingListDialog: WebServiceDelegate {
    //MARK:- Server response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kShoppingList + SharedPreference.getUserData().token! {
            guard let baseModel = Mapper<BaseListModel<ShoppingListModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            if baseModel.isSuccess{
                arrShoppingList = baseModel.object!
                print("Response--->", arrShoppingList)
                if arrShoppingList.count == 0 {
                    self.bannerView.isHidden = true
                    self.vwIntro.isHidden = false
                    self.tblShoppingList.isHidden = true
                }else{
                    self.bannerView.isHidden = false
                    self.vwIntro.isHidden = true
                    self.tblShoppingList.isHidden = false
                }
                //arrShoppingList[index].name = tf
                tblShoppingList.reloadData()
            }else{
                self.bannerView.isHidden = true
                self.vwIntro.isHidden = false
                self.tblShoppingList.isHidden = true
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }else if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kRemoveShoppingList + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseModel<ShoppingListModel>>().map(JSONObject: data) else{
                print("Parse Error")
                return
            }
            if baseModel.isSuccess {
                
                self.arrShoppingList.remove(at: index)
                if arrShoppingList.count == 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                        self.bannerView.isHidden = true
                        self.vwIntro.isHidden = false
                        self.tblShoppingList.isHidden = true
                    })
                }
                print(arrShoppingList)
                self.showAnnouncement(withMessage: baseModel.msg!)
                self.tblShoppingList.reloadData()
            }
            else {
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }else if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kUpdateShoppingListName + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseModel<ShoppingListModel>>().map(JSONObject: data) else {
                print("Parse Error")
                return
            }
            if baseModel.isSuccess {
                self.arrShoppingList[self.index].name = self.tf
                self.tblShoppingList.reloadData()
                callAPiForGettingShoppingList()
            }
            else {
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }else if actionStr == ApiConstant.ApiType.kStore + ApiConstant.ApiAction.kGetStores + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseModel<ShoppingListModel>>().map(JSONObject: data) else {
                print("Parse Error")
                return
            }
            
            if baseModel.isSuccess {
                //arrShoppingList = [baseModel.object!]
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                vc.token = SharedPreference.getUserData().token!
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                vc.token = SharedPreference.getUserData().token!
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        } else if actionStr == ApiConstant.ApiType.kEZLists + ApiConstant.ApiAction.KAddItemToEZLists + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseListModel<ShareModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            print("~~~~", baseModel.isSuccess, baseModel.msg)
            if baseModel.isSuccess{
                self.dismiss(animated: true, completion: nil)
                self.delegate?.handleAction(action: shopData)
            }else{
                self.bannerView.isHidden = true
                self.vwIntro.isHidden = false
                self.tblShoppingList.isHidden = true
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
}

//MARK:- Register Notification

struct LocationNotificationName1 {
    static let userUpdateLocation = Notification.Name("GetLocation")
    
}


extension ShoppingListDialog: GADBannerViewDelegate {
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        self.bannerView.alpha = 0
        UIView.animate(withDuration: 1) {
            self.bannerView.alpha = 1
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
        addBannerViewToView(bannerView)
    }
}

// MARK: - ViewModelDelegate
extension ShoppingListDialog: ViewModelDelegate {
    
    func toggleOverlay(shouldShow: Bool) {
        overlayView.isHidden = !shouldShow
    }
    
    func willStartLongProcess() {
        overlayView.isHidden = false
    }
    
    func didFinishLongProcess() {
        overlayView.isHidden = true
    }
    
    
    func showIAPRelatedError(_ error: Error) {
        let message = error.localizedDescription
    
        showSingleAlert(withMessage: message)
    }
    
    
    func shouldUpdateUI(list_id: String) {
        UserDefaults.standard.set(true, forKey: "purchased")
//        tableView.reloadData()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "StoreImagesVC") as! StoreImagesVC
        vc.list_id =  list_id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func didFinishRestoringPurchasesWithZeroProducts() {
        showSingleAlert(withMessage: "There are no purchased items to restore.")
    }
    
    
    func didFinishRestoringPurchasedProducts() {
        showSingleAlert(withMessage: "All previous In-App Purchases have been restored!")
    }
}

