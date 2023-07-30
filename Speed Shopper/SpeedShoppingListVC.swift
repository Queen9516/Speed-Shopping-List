//
//  SpeedShoppingListVC.swift
//  Speed Shopping List
//
//  Created by info on 19/04/18.
//  Copyright © 2018 mac. All rights reserved.
//
import UIKit
import ObjectMapper
import Speech
import CoreLocation
import GoogleMobileAds
import LinkPresentation
import Foundation
import OneSignal
import BEMCheckBox

class SpeedShoppingListVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, WebServiceDelegate , CustomPickerDelegate , SFSpeechRecognizerDelegate,  GADFullScreenContentDelegate, StoreListDelegate, BEMCheckBoxDelegate, UIActivityItemSource, SpeedShoppingListCellDelegate, SortDelegate {
      
    var arrAdd = NSArray()
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var lbl_storeName: UILabel!
    @IBOutlet weak var btnMicrophone: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var lbl_Adrress: UILabel!
    @IBOutlet weak var view_content: UIView!
    @IBOutlet weak var tfItemName: UITextField!
    @IBOutlet weak var lbl_listName: UILabel!
    @IBOutlet weak var btnDeleteAll: UIButton!
    @IBOutlet weak var btnDeletedChecked: UIButton!
    @IBOutlet weak var btnReverseSort: UIButton!

    @IBOutlet weak var ItemsToallPrice: UILabel!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var bannerViewHeight: NSLayoutConstraint!
    var arrShoppingList = [ShoppingListModel]()
    var arrindex = [IndexPath]()
    var list_id = ""
    var item = ""
    var storeId = ""
    var arrShoppingListItem = ShoppingListItemModel()
    var storeData = StoreModel()
    var index = Int()
    var location = String()
    var arrStore1 = [StoreModel]()
    var store_name =  ""
    var store_address = ""
    var arrAdvertisementList = [AdvertisementListModel]()
    var isFirstTime = true
    /*Locale.init(identifier: "en_IN")*/
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.current) //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    var interstitial: GADInterstitialAd!
    var purchasePos = -1, purchaseStatus = false, deleteItemStatus = false
    
    var metadata: LPLinkMetadata?
    var tokenString: String = ""
    var isPremium: Bool = false
    var totoalPrice : [Float] = []
    var price : Float = 0.0
    var currentSortMode: Int = 1;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Speed Shopping List"
        isPremium = UserDefaults.standard.bool(forKey: UseCaseMessage.Purchase.premium)
//        isPremium = true
        print("UPGRADED-->", isPremium)
        if isPremium {
            bannerView.isHidden = true
            bannerViewHeight.constant = 0.0
        } else {
            bannerView.isHidden = false
            bannerViewHeight.constant = 50.0
            bannerView.adUnitID = "ca-app-pub-1558394739169751/4978387294"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            bannerView.delegate = self
        }
        
        myTableView.rowHeight = UITableViewAutomaticDimension
        myTableView.estimatedRowHeight = 60
        myTableView.delegate = self
        self.lbl_listName.text = item
//        self.lbl_Adrress.text = self.store_address
        self.lbl_storeName.text = self.store_name
        initLayout()
        
        
        self.CallAPIForAdvertisement()
        //self.CallAPIForShoppingListItem(list_id: list_id)
        self.setUpSpeechRecognization()
        self.getSSTXEarnedVal()
        self.setupBack()
        self.setupSyncForShoppingListItem()
        self.getAllStores()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled = false
        totoalPrice.removeAll()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        resizeSSTXFrame()
    }
    
    func calculatePrice(prices: [Float]) {
        print("TOTAL PRICE---->:",  prices)
        price = 0.0
        if totoalPrice.count > 0 {
            
            for item in prices {
                price += item
            }
        }
        self.ItemsToallPrice.text = "Total Price: $\(price)"
    }
    
    func showActivityIndicator() {
        loadingView.isHidden = false
        loadingIndicator.startAnimating()
    }
    
    func hideActivityIndicator(){
        loadingView.isHidden = true
        loadingIndicator.stopAnimating()
    }
    
    func resizeSSTXFrame() {
        self.view.layoutIfNeeded()
    }
    
    func initLayout() {
        
        self.btnDeleteAll.titleLabel?.numberOfLines = 2
        self.btnDeleteAll.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.btnDeleteAll.titleLabel?.textAlignment = NSTextAlignment.center
        self.btnDeleteAll.setTitle("Delete\nAll", for: .normal)
        
        self.btnDeletedChecked.titleLabel?.numberOfLines = 2
        self.btnDeletedChecked.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.btnDeletedChecked.titleLabel?.textAlignment = NSTextAlignment.center
        self.btnDeletedChecked.setTitle("Delete\nChecked", for: .normal)
        
        self.btnReverseSort.titleLabel?.numberOfLines = 2
        self.btnReverseSort.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.btnReverseSort.titleLabel?.textAlignment = NSTextAlignment.center
        self.btnReverseSort.setTitle("Sort", for: .normal)
    }
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        tokenString = getShareToken(list_id: list_id)
        print("SHARE_TOKEN--->:", tokenString)
        self.sendShareMessage()

    }
    
    func sendShareMessage() {
        self.showActivityIndicator()
        let url = URL(string: "https://speedshopperapp.com")!
        let metadataProvider = LPMetadataProvider()
        metadataProvider.startFetchingMetadata(for: url) { linkMetadata, error in
            if error != nil {
                return
            }
            linkMetadata?.iconProvider = linkMetadata?.imageProvider
            self.metadata = linkMetadata
            let activityVc = UIActivityViewController(activityItems: [self], applicationActivities: nil)
            DispatchQueue.main.async { [self] in
                self.present(activityVc, animated: true)
                self.hideActivityIndicator()
            }
            activityVc.completionWithItemsHandler = { [self] activity, success, items, error in
                if success {
                    self.CallAPIForShareShoppingList(list_id: self.list_id)
                }
            }
        }
        
    }
        
    // The placeholder the share sheet will use while metadata loads
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "Share Shopping List"
    }
    
    // The item we want the user to act on.
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        let sharingText = "I want to share my shopping list with you. \n\n This way we'll never forget to buy anything we need, and our lists will always be in sync. \n\n Accept my share request with Speed Shopping List. If you're new, you will be sent to download the app first. Don't worry, it's free! \n\n https://speedshopperapp.com/app/share/token/\(tokenString) \n\n Try Speed Shopping List, the world's best shopping list app, for iOS and Android.\n"
        let message = "https://apps.apple.com/us/app/speed-shopper/id1434065555 \n https://play.google.com/store/apps/details?id=c.offerak.speedshopper"
        return "\(sharingText)\t\n\(message)"
//        return self.metadata
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController,
                                subjectForActivityType activityType: UIActivityType?) -> String {
        let subject = "View My Shopping List With Speed Shopping List"
        return subject
    }
    
    // The metadata we want the system to represent as a rich link
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        metadata!.title = "Share Shopping List"
        metadata!.originalURL = URL(string: "https://speedshopperapp.com")!
        metadata!.url = metadata!.originalURL
        // Set URL for sharing
        
        return metadata
    }
    
    @IBAction func importBtnTapped(_ sender: UIButton) {
        let storeList = self.storyboard?.instantiateViewController(withIdentifier: "StoreListVC") as! StoreListVC
        storeList.delegate = self
        storeList.storeList = self.arrShoppingList
        storeList.modalPresentationStyle = .overCurrentContext
        self.present(storeList, animated: true) {
        }
    }
    
    func ImportItemFromStore(id: String) {
        self.dismiss(animated: true, completion: nil)
        Apimanager.sharedManager.webServiceDelegate = self
        let act_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kImportItem + SharedPreference.getUserData().token
        var param = [String: Any]()
        param["import_shopping_list_id"] = id
        param["cur_shopping_list_id"] = list_id
        Apimanager.sharedManager.callApiPostMethod(str_Action: act_str, param: param)
    }
    fileprivate func createAndLoadInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-1558394739169751/3489963699", request: request,
                          completionHandler: { [self] ad, error in
                            if let error = error {
                              print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                              return
                            }
                            self.interstitial = ad
                            self.interstitial.fullScreenContentDelegate = self
                          }
        )
    }
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
      print("Ad did fail to present full screen content.")
      createAndLoadInterstitial()
    }

    /// Tells the delegate that the ad presented full screen content.
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad did present full screen content.")
      
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      print("Ad did dismiss full screen content.")
        if (isFirstTime) {
            isFirstTime = false
        }
      createAndLoadInterstitial()
    }
    
    func showAds(_ viewController: UIViewController) {
        if interstitial != nil {
            interstitial?.present(fromRootViewController: viewController)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    fileprivate func getAllStores() {
        Apimanager.sharedManager.webServiceDelegate = self
        let act_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kShoppingList + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethodWithoutParam(str_Action: act_str)
    }
    
    func setupSyncForShoppingListItem(){
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 50, height: 20)
        menuBtn.setImage(UIImage(named:"sync"), for: .normal)
        menuBtn.addTarget(self, action: #selector(callShoppingList), for: UIControlEvents.touchUpInside)
        
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 65)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 30)
        currHeight?.isActive = true
        self.navigationItem.rightBarButtonItem = menuBarItem
    }
    
    @objc func callShoppingList(){
        totoalPrice.removeAll()
        self.CallAPIForShoppingListItem(list_id: self.list_id)
    }
    
    func setUpSpeechRecognization(){
        btnMicrophone.isEnabled = false  //2
        speechRecognizer?.delegate = self  //3
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            var isButtonEnabled = false
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            OperationQueue.main.addOperation() {
                self.btnMicrophone.isEnabled = isButtonEnabled
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createAndLoadInterstitial()
        Apimanager.sharedManager.webServiceDelegate = self
        isFirstTime = true        
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.CallAPIForShoppingListItem(list_id: list_id)
        OneSignal.addTrigger("speedshop", withValue: "loaded")
        
    }
    
    func getShareToken(list_id: String) -> String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timeString = formatter.string(from: today)
        let shareToken = list_id + "_" + timeString
        
        return shareToken
    }
    //MARK:- Call API for ShoppingListItem
    func CallAPIForShoppingListItem(list_id: String) {
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kListId] = list_id
        let actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.KshoppingListItem + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    
    func CallAPIForShareShoppingList(list_id: String) {
        Apimanager.sharedManager.webServiceDelegate = self
        
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kListId] = list_id
        param[ApiConstant.ApiKey.kSharingToken] = tokenString
        let actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kshareShoppingList + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    
    func setInitialVal(){
        arrShoppingListItem = ShoppingListItemModel()
        arrShoppingListItem.purchased = [ShoppingItems]()
        arrShoppingListItem.unpurchased = [ShoppingItems]()
    }
    
    func addItemAndReloadTableView(item: ShoppingItems, purchaseStatus: Bool = false, fromPurchase: Bool = false) {
        if (arrShoppingListItem.purchased == nil) {
            arrShoppingListItem.purchased = [ShoppingItems]()
        }
        if (arrShoppingListItem.unpurchased == nil) {
            arrShoppingListItem.unpurchased = [ShoppingItems]()
        }
        if (item.location == "") {
            if (purchaseStatus) {
                arrShoppingListItem.purchased!.insert(item, at: 0)
            } else {
                arrShoppingListItem.unpurchased!.insert(item, at: 0)
            }
           
        } else {
            let purchasedItems = arrShoppingListItem.purchased!, unPurchasedItems = arrShoppingListItem.unpurchased!
            
            if (purchaseStatus) {
                var index = 0
                var flag = false
                for i in 0 ..< purchasedItems.count {
                    if ((purchasedItems[i].location ?? "") >= item.location!) {
                        flag =  true
                        index = i
                        break
                    }
                }
                if (flag) {
                    arrShoppingListItem.purchased!.insert(item, at: index)
                } else {
                    arrShoppingListItem.purchased!.append(item)
                }
            } else {
                var index = 0
                var flag = false
                for i in 0 ..< unPurchasedItems.count {
                    if ((unPurchasedItems[i].location ?? "") >= item.location!) {
                        flag =  true
                        index = i
                        break
                    }
                }
                if (flag) {
                    arrShoppingListItem.unpurchased!.insert(item, at: index)
                } else {
                    arrShoppingListItem.unpurchased!.append(item)
                }
            }
            
        }

        self.toggleButtons()
        reverseSort()
        myTableView.reloadData()
        if fromPurchase && arrShoppingListItem.purchased?.count != 0 && arrShoppingListItem.unpurchased?.count == 0{
            let allItemVC = self.storyboard?.instantiateViewController(withIdentifier: "AllItemSelectViewController") as! AllItemSelectViewController
            allItemVC.modalPresentationStyle = .overCurrentContext
            
            if isPremium {
                self.present(allItemVC, animated: true)
            } else {
                self.present(allItemVC, animated: true) {
                    self.showAds(allItemVC)
                }
            }
        }
    }
    
    //MARK:- Server Response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kImportItem + SharedPreference.getUserData().token {
            self.CallAPIForShoppingListItem(list_id: list_id)
        } else if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kGetSSTXVal + SharedPreference.getUserData().token {
            if let JSON = data as? [String: Any] {
                resizeSSTXFrame()
                
            }
            
        } else if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kShoppingList + SharedPreference.getUserData().token! {
            guard let baseModel = Mapper<BaseListModel<ShoppingListModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            if baseModel.isSuccess{
                arrShoppingList = baseModel.object!
                for i in 0 ..< arrShoppingList.count {
                    if (self.arrShoppingList[i].store_id == self.storeId) {
                        self.arrShoppingList.remove(at: i)
                        break
                    }
                }
            }else{
                arrShoppingList = []
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }else if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.KshoppingListItem + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseModel<ShoppingListItemModel>>().map(JSONObject: data) else {
                print("Parse Error")
                self.showAnnouncement(withMessage: "Parser Error")
                return
            }
            if baseModel.isSuccess {
                setInitialVal()
                arrShoppingListItem = baseModel.object!
                print("ITEMS--->:", arrShoppingListItem.unpurchased as Any)
                let purchasedItems = self.arrShoppingListItem.purchased!
                let unpurchasedItems = self.arrShoppingListItem.unpurchased!
                if purchasedItems.count > 0 {
                    for item in purchasedItems {
                        let price: Float! = Float(item.unit_price!)
                        let quanity: Int! = Int(item.quantity!)
                        let total: Float! = price * Float(quanity)
                        self.totoalPrice.append(total)
                    }
                }
                
                if unpurchasedItems.count > 0 {
                    for item in unpurchasedItems {
                        let price: Float! = Float(item.unit_price!)
                        let quanity: Int! = Int(item.quantity!)
                        let total: Float! = price * Float(quanity)
                        self.totoalPrice.append(total)
                    }
                }
                
                reverseSort()
                myTableView.reloadData { [self] in
                    self.calculatePrice(prices: self.totoalPrice)
                }

                self.toggleButtons()
            }
        }else if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kAddItemToShoppingList + SharedPreference.getUserData().token {
            
            //ShoppingItems
            guard let baseModel = Mapper<BaseModel<ShoppingItems>>().map(JSONObject: data), let baseModelObj = baseModel.object else {
                print("Parse Error")
                self.showAnnouncement(withMessage: "Parser Error")
                return
            }
            if baseModel.isSuccess {
                totoalPrice.removeAll()
                addItemAndReloadTableView(item: baseModelObj)
            }
            else{
                
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        } else if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kRemoveAllItem + SharedPreference.getUserData().token! {
            guard let baseModel = Mapper<BaseModel<ShoppingListItemModel>>().map(JSONObject: data) else {
                print("Parse Error")
                self.showAnnouncement(withMessage: "Parser Error")
                return
            }
            if baseModel.isSuccess {
                setInitialVal()
                self.toggleButtons()
                self.reverseSort()
                self.myTableView.reloadData()
                self.ItemsToallPrice.text = "Total Price: $0.0"
            }else {
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        } else if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kRemoveCheckedItem + SharedPreference.getUserData().token! {
            guard let baseModel = Mapper<BaseModel<ShoppingListItemModel>>().map(JSONObject: data) else {
                print("Parse Error")
                self.showAnnouncement(withMessage: "Parser Error")
                return
            }
            if baseModel.isSuccess {
                arrShoppingListItem.purchased = [ShoppingItems]()
                self.toggleButtons()
                
                reverseSort()
                myTableView.reloadData()
                
            }else {
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        } else if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kPurchaseItem + SharedPreference.getUserData().token! {
            guard let baseModel = Mapper<BaseModel<ShoppingListItemModel>>().map(JSONObject: data) else {
                print("Parse Error")
                return}
            if baseModel.isSuccess {
                var editItem: ShoppingItems!
                
                if (self.purchaseStatus) {
                    editItem = self.arrShoppingListItem.purchased?[self.purchasePos]
                    self.arrShoppingListItem.purchased?.remove(at: self.purchasePos)
                } else {
                    editItem = self.arrShoppingListItem.unpurchased?[self.purchasePos]
                    self.arrShoppingListItem.unpurchased?.remove(at: self.purchasePos)
                }

                if (self.deleteItemStatus) {
                    toggleButtons()
                    
                    reverseSort()
                    myTableView.reloadData()
                    
                    return
                }
                editItem.status = purchaseStatus ? "0" : "1"
                addItemAndReloadTableView(item: editItem, purchaseStatus: !purchaseStatus, fromPurchase: true)
                
                let adsCounter = SharedPreference.increaseAdsCounterAndGet()
                if (adsCounter == 0) {
                    if isPremium {
                    } else {
                        self.showAds(self)
                    }
                }
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
        else if actionStr == ApiConstant.ApiType.kSpeedShopperMarket + ApiConstant.ApiAction.kadvertisement + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseListModel<AdvertisementListModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "parser error")
                return
            }
            if baseModel.isSuccess
            {
                arrAdvertisementList = baseModel.object!
                
                arrAdd = (data as! NSDictionary).value(forKey: "data") as! NSArray
                arrAdd = arrAdd.value(forKey: "item_id") as! NSArray
                if arrAdvertisementList.count != 0 {
                   // self.gotoAdvertizementVC()
                }
                
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        } else if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kshareShoppingList + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseListModel<ShoppingListModel>>().map(JSONObject: data) else {
                self.showAnnouncement(withMessage: "parser error")
                return
            }
            if baseModel.isSuccess {
//                self.sendShareMessage()
                self.hideActivityIndicator()
                self.showAnnouncement(withMessage: baseModel.msg!)
            } else {
                self.hideActivityIndicator()
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    
    func error_serverResponse(data: Any, actionStr: String) {
        
        self.showAnnouncement(withMessage:  String(describing: (data as AnyObject).userInfo[NSLocalizedDescriptionKey]!).replacingOccurrences(of: "}", with: "").components(separatedBy: "=").last! )
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var myCount = (self.arrShoppingListItem.purchased?.count ?? 0) + (self.arrShoppingListItem.unpurchased?.count ?? 0)
        myCount = myCount == 0 ? 1 : myCount
        myTableView.isScrollEnabled = myCount != 1 ? true : false
        return myCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let purchasedItems = self.arrShoppingListItem.purchased, let unpurchasedItems = self.arrShoppingListItem.unpurchased, (purchasedItems.count != 0 || unpurchasedItems.count != 0) else {
            let itemNotFoundCell = tableView.dequeueReusableCell(withIdentifier: "cell2") as! ItemNotFoundCell
            return itemNotFoundCell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SpeedShoppingListCell
        cell.cellDelegate = self
        cell.cellID = indexPath.row
        index = indexPath.row
        var realIndexValue = index
        var data:ShoppingItems
        if (index >= unpurchasedItems.count) {
            data = purchasedItems[index - unpurchasedItems.count]
            realIndexValue = index - unpurchasedItems.count + 100
            cell.customCellID = realIndexValue
        } else {
            data = unpurchasedItems[index]
            realIndexValue = index + 5000
            cell.customCellID = realIndexValue
        }
        
        cell.deleteItemBtn.tag = realIndexValue
        cell.editItemBtn.tag = realIndexValue
        cell.btnTakePic.tag = realIndexValue
        cell.itemCheckBox.tag = realIndexValue
        cell.itemCheckBox.onTintColor = UIColor.hexStringToUIColor("#009900")
        cell.itemCheckBox.onCheckColor = UIColor.hexStringToUIColor("#009900")
        cell.lable_list.text! = data.name!
        
        let item_id = data.item_id
        cell.lable_list.tag = Int(item_id!)!
        
        if arrAdd.contains(item_id ?? "no value"){
            let textColor: UIColor = UIColor.hexStringToUIColor(AppColor.blueColor)
            let underLineColor: UIColor = UIColor.hexStringToUIColor(AppColor.blueColor)
            let underLineStyle = NSUnderlineStyle.styleSingle.rawValue
            let labelAtributes:[NSAttributedStringKey : Any]  = [
                NSAttributedStringKey.foregroundColor: textColor,
                NSAttributedStringKey.underlineStyle: underLineStyle,
                NSAttributedStringKey.underlineColor: underLineColor
            ]
            let underlineAttributedString = NSAttributedString(string: data.name!,
                                                               attributes: labelAtributes)
            cell.lable_list.attributedText = underlineAttributedString
            let tapgesture = UITapGestureRecognizer(target: self, action: #selector(ItemAction(sender:)))
            
            cell.lable_list.isUserInteractionEnabled = true
            cell.lable_list.addGestureRecognizer(tapgesture)
        } else {
            let textColor = UIColor.darkGray
            let underLineColor = UIColor.clear
            let underLineStyle = NSUnderlineStyle.styleSingle.rawValue
            let labelAtributes:[NSAttributedStringKey : Any]  = [
                NSAttributedStringKey.foregroundColor: textColor,
                NSAttributedStringKey.underlineStyle: underLineStyle,
                NSAttributedStringKey.underlineColor: underLineColor
            ]
            let underlineAttributedString = NSAttributedString(string: data.name!,
                                                               attributes: labelAtributes)
            cell.lable_list.attributedText = underlineAttributedString
        }
        cell.itemCheckBox.delegate = self
        cell.deleteItemBtn.addTarget(self, action: #selector(deleteItemBtn(_:)), for: .touchUpInside)
        cell.adjust(upgraded: isPremium, imageName: data.image!)

        
        
        let purchase = data.status
        let location = data.location
        
        if let quantity = data.quantity {
            cell.quantityLabel.text = quantity
        }
        if location == "" {
            cell.aisleLabel.text = "Add"
        } else {
            cell.aisleLabel.text = location
        }
        
        if purchase == "1"{
            cell.itemCheckBox.on = true
        } else {
            cell.itemCheckBox.on = false
        }
 
        return cell
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        var list_id_loc = String()
        var tag = 0
        var purchase = ""
        if checkBox.tag >= 5000 {
            tag = checkBox.tag - 5000
            list_id_loc = arrShoppingListItem.unpurchased![tag].id!
            purchase = "1"
        }else{
            tag = checkBox.tag - 100
            list_id_loc = arrShoppingListItem.purchased![tag].id!
            purchase = "0"
        }
        purchasePos = tag
        purchaseStatus = purchase == "0"
        deleteItemStatus = false
        self.callAPIForPurchaseItem(item_id: list_id_loc,list_id: self.list_id ,purchase: purchase)
    }
    
    @objc func ItemAction(sender: UITapGestureRecognizer)
    {
        let uu = sender.view!.tag
        var arrTempAdList = [AdvertisementListModel]()
        for i in 0..<arrAdvertisementList.count
        {
            if arrAdvertisementList[i].item_id == "\(uu)"
            {
                arrTempAdList.append(arrAdvertisementList[i])
            }
        }
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AdsVC") as! AdsVC
        vc.arrAdvertizementList = arrTempAdList //arrAdvertisementList
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func previewImage(_ sender: SpeedShoppingListCell) {
        let indexPath = IndexPath(row: sender.cellID, section: 0)
        let cell = myTableView.cellForRow(at: indexPath) as? SpeedShoppingListCell
        let prevewVC = self.storyboard?.instantiateViewController(withIdentifier: "ItemImageViewController") as! ItemImageViewController
        prevewVC.modalPresentationStyle = .overCurrentContext
        prevewVC.itemImage1 = cell?.itemImage.image
        self.present(prevewVC, animated: true)
    }
    
    func editItem(_ sender: SpeedShoppingListCell) {
        let indexPath = IndexPath(row: sender.customCellID, section: 0)
        let cell = myTableView.cellForRow(at: indexPath) as? SpeedShoppingListCell
        let itemEditVC = self.storyboard?.instantiateViewController(withIdentifier: "ItemEditViewController") as! ItemEditViewController
        var itemId = "", itemQuantity="", itemName="", itemAisle = "", itemPrice = "", itemImageName = ""
        var itemData: ShoppingItems!
        
        if sender.customCellID >= 5000 {
            let tag = sender.customCellID - 5000
            itemData = self.arrShoppingListItem.unpurchased![tag]
        }else{
            let tag = sender.customCellID - 100
            itemData = self.arrShoppingListItem.purchased![tag]
        }

        itemId = itemData.id!
        itemQuantity = itemData.quantity ?? "1"
        itemName = itemData.name ?? ""
        itemPrice = itemData.unit_price ?? "0"
        itemAisle = itemData.location ?? ""
        itemImageName = itemData.image ?? ""
        
        print("IMAGE NAME--->:", cell?.itemImage.image as Any)
        
        itemEditVC.listId = list_id
        itemEditVC.storeId = storeId
        itemEditVC.item_id = itemId
        itemEditVC.m_id    = itemData.item_id!
        itemEditVC.itemName = itemName
        itemEditVC.itemQuantity = itemQuantity
        itemEditVC.itemPrice = itemPrice
        itemEditVC.itemAisle = itemAisle
        if itemImageName == "" {
            itemEditVC.isTakedPic = false
        } else {
            itemEditVC.isTakedPic = true
            itemEditVC.itemPic = cell?.itemImage.image
            itemEditVC.imageName = itemImageName
        }
        MainClass.appDelegate.navController.pushViewController(itemEditVC, animated: true)
    }
    
    //MARK:- Edit Item
    @IBAction func editItemBtnTapped1(_ sender: UIButton) {
        
        let itemEditVC = self.storyboard?.instantiateViewController(withIdentifier: "ItemEditViewController") as! ItemEditViewController
        
        var itemId = "", itemQuantity="", itemName="", itemAisle = "", itemPrice = "", itemImageName = ""
        var itemData: ShoppingItems!
        if sender.tag >= 5000 {
            let tag = sender.tag - 5000
            itemData = self.arrShoppingListItem.unpurchased![tag]
        }else{
            let tag = sender.tag - 100
            itemData = self.arrShoppingListItem.purchased![tag]
        }

        itemId = itemData.id!
        itemQuantity = itemData.quantity ?? "1"
        itemName = itemData.name ?? ""
        itemPrice = itemData.unit_price ?? "0"
        itemAisle = itemData.location ?? ""
        itemImageName = itemData.image ?? ""
        
        print("IMAGE NAME--->:", itemImageName)
        
        itemEditVC.listId = list_id
        itemEditVC.storeId = storeId
        itemEditVC.item_id = itemId
        itemEditVC.m_id    = itemData.item_id!
        itemEditVC.itemName = itemName
        itemEditVC.itemQuantity = itemQuantity
        itemEditVC.itemPrice = itemPrice
        itemEditVC.itemAisle = itemAisle
        MainClass.appDelegate.navController.pushViewController(itemEditVC, animated: true)
    }
    //Mark:- Get SSTX earned value
    func getSSTXEarnedVal() {
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kStoreId] = storeId
        let actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kGetSSTXVal + SharedPreference.getUserData().token!
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    
    //Mark:- Delete Item
    @IBAction func deleteItemBtn(_ sender: UIButton) {
        let alert = UIAlertController(title: Utils.AppName(), message: "Are you sure you want to delete this item", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .default) { (alertaction) in
            var list_id_loc = String()
            var tag = 0
            if sender.tag >= 5000 {
                tag = sender.tag - 5000
                list_id_loc = self.arrShoppingListItem.unpurchased![tag].id!
                self.purchaseStatus = false
            }else{
                tag = sender.tag - 100
                list_id_loc = self.arrShoppingListItem.purchased![tag].id!
                self.purchaseStatus = true
            }

            self.purchasePos = tag
            self.deleteItemStatus = true
            self.callAPIForPurchaseItem(item_id: list_id_loc, list_id: self.list_id, purchase: "9")
        }
        let action2 = UIAlertAction(title: "No", style: .default)  { (alertaction) in
        }
        alert.addAction(action)
        alert.addAction(action2)
        alert.view.backgroundColor = UIColor.hexStringToUIColor(AppColor.blueColor)
        alert.view.layer.cornerRadius = 40
        present(alert, animated: true)
    }
    
    @IBAction func deleteAllBtnTapped(_ sender: UIButton) {
        if ((arrShoppingListItem.purchased?.isEmpty)! && (arrShoppingListItem.unpurchased?.isEmpty)!) {
            self.showAnnouncement(withMessage: "Sorry no items found")
        }else{
            let alert = UIAlertController(title: Utils.AppName(), message: "Are you sure you want to delete all items ", preferredStyle: .alert)
            let action = UIAlertAction(title: "Yes", style: .default) { (alertaction) in
                self.CallAPIForRemoveAllItems(list_id: self.list_id, allFlag: true)
            }
            let action2 = UIAlertAction(title: "No", style: .default)  { (alertaction) in
            }
            alert.addAction(action)
            alert.addAction(action2)
            alert.view.backgroundColor = UIColor.hexStringToUIColor(AppColor.blueColor)
            alert.view.layer.cornerRadius = 40
            present(alert, animated: true)
        }
    }
    
    @IBAction func deleteCheckedBtnTapped(_ sender: UIButton) {
        if ((arrShoppingListItem.purchased?.isEmpty)!) {
            self.showAnnouncement(withMessage: "Sorry checked items not found")
        }else{
            let alert = UIAlertController(title: Utils.AppName(), message: "Are you sure you want to delete all checked items ", preferredStyle: .alert)
            let action = UIAlertAction(title: "Yes", style: .default) { (alertaction) in
                self.CallAPIForRemoveAllItems(list_id: self.list_id, allFlag: false)
            }
            let action2 = UIAlertAction(title: "No", style: .default)  { (alertaction) in
            }
            alert.addAction(action)
            alert.addAction(action2)
            alert.view.backgroundColor = UIColor.hexStringToUIColor(AppColor.blueColor)
            alert.view.layer.cornerRadius = 40
            present(alert, animated: true)
        }
    }
    
    @IBAction func reverseSortBtnTapped(_ sender: UIButton) {
//        if let unpurchasedItems = self.arrShoppingListItem.unpurchased {
//            var newItems = [ShoppingItems]()
//            for i in (0..<unpurchasedItems.count).reversed()  {
//                newItems.append(unpurchasedItems[i])
//            }
//            self.arrShoppingListItem.unpurchased = newItems
//        }
//        self.myTableView.reloadData()
        
        SortDialog.showPopup(parentVC: self, sortMode: currentSortMode)
        
    }
    
    func clickSortItem(item: Int) {
        currentSortMode = item
        reverseSort()
        self.myTableView.reloadData()
    }
    
    func reverseSort() {
        if let unpurchasedItems = self.arrShoppingListItem.unpurchased {
            var items: [ShoppingItems]
            switch currentSortMode {
                case 0:
                    items = unpurchasedItems.sorted(by: {compareByAisle(a: $0, b: $1, isDown: false)})
                    break
                case 1:
                    items = unpurchasedItems.sorted(by: {compareByAisle(a: $0, b: $1, isDown: true)})
                    break
                case 2:
                    items = unpurchasedItems.sorted(by: {compareByName(a: $0, b: $1, isDown: false)})
                    break
                case 3:
                    items = unpurchasedItems.sorted(by: {compareByName(a: $0, b: $1, isDown: true)})
                    break
                default:
                    items = unpurchasedItems
                    break
            }
            self.arrShoppingListItem.unpurchased = items
        }
    }
    
    func compareByAisle(a: ShoppingItems, b: ShoppingItems, isDown: Bool) -> Bool {
        var flag: Bool = true;
        if a.location == "" && b.location == "" {
            flag = compareByName(a: a, b: b, isDown: false)
        } else {
            flag = ((Int(a.location ?? "10000") ?? 10000) < (Int(b.location ?? "10000") ?? 10000))
        }
        if isDown {
            return flag;
        }
        return !flag;
    }
    
    func compareByName(a: ShoppingItems, b: ShoppingItems, isDown: Bool) -> Bool {
        var flag: Bool = ((a.name ?? "").lowercased() > (b.name ?? "").lowercased())
        if isDown {
            return flag;
        }
        return !flag;
    }
    
    // MARK- API For Remove all Items
    func CallAPIForRemoveAllItems(list_id: String, allFlag: Bool) {
        let apiUrl = allFlag ? ApiConstant.ApiAction.kRemoveAllItem : ApiConstant.ApiAction.kRemoveCheckedItem
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kListId] = list_id
        let actio_str = ApiConstant.ApiType.kShopping + apiUrl + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    
    //MARK:- Add Items From Admin Side
    @IBAction func selectItemAction(_ sender: UIButton) {
        if tfItemName.text != ""{
           // addItem()
            self.CallAPIForAddItemtoShoppingList(id: self.list_id, item: self.tfItemName.text!)
            self.tfItemName.text = ""
        }else{
            let selectItem = self.storyboard?.instantiateViewController(withIdentifier: "AddPickerVC") as! AddPickerVC
            selectItem.delegate = self
            selectItem.modalPresentationStyle = .overCurrentContext
            selectItem.arrStore1 = arrStore1
            selectItem.storeID = self.storeId
            selectItem.list_id = list_id
            self.present(selectItem, animated: false, completion: nil)
        }
    }
    //MARK:- Custom picker delegate method
    func selectedItem(iteamName: String, isDoneClicked: Bool, isCancelled: Bool) {
        print(iteamName)
        tfItemName.text = iteamName
        if isDoneClicked{
            self.dismiss(animated: false, completion: nil)
            self.CallAPIForAddItemtoShoppingList(id: list_id, item: iteamName)
            tfItemName.text = ""
        }else if isCancelled{
            self.dismiss(animated: false, completion: nil)
            tfItemName.text = ""
        }
    }
    //MARK:- Call API for Add Item to Shopping List
    func CallAPIForAddItemtoShoppingList(id: String, item: String) {
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kListId] = id
        param[ApiConstant.ApiKey.kStoreId] = storeId
        param[ApiConstant.ApiKey.kItem] = item
        let actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kAddItemToShoppingList + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    func toggleButtons(){
        if (arrShoppingListItem.purchased?.count == 0  && arrShoppingListItem.unpurchased?.count == 0) {
            btnDeleteAll.isHidden = true
            btnReverseSort.isHidden = true
            btnDeletedChecked.isHidden = true
        } else {
            btnDeleteAll.isHidden = false
            btnReverseSort.isHidden = false
            btnDeletedChecked.isHidden = false
        }
    }
    
    //MARK: - Call API For PurchaseItem
    func callAPIForPurchaseItem(item_id: String,list_id: String,purchase: String){
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kItemId] = item_id
        param[ApiConstant.ApiKey.kListId] = list_id
        param[ApiConstant.ApiKey.kPurchase] = purchase
        let actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kPurchaseItem + SharedPreference.getUserData().token!
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param, showProgress: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //Mark:- Microphone Action
    @IBAction func microphoneAction(_ sender: UIButton) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            btnMicrophone.isEnabled = false
            //            btnRecording.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            sender.isSelected = true
            //            btnRecording.setTitle("Stop Recording", for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                sender.isSelected = false
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.audioEngine.stop()
                self.recognitionRequest?.endAudio()
                self.btnMicrophone.isEnabled = true
                self.tfItemName.placeholder = "Enter Item"
                if self.tfItemName.text == SpeechText.msg{
                    self.tfItemName.text = ""
                    self.showAnnouncement(withMessage: "Sorry! we could not recognize")
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.addItem()
                    }
                }
            }
        }
    }
    func addItem(){
        let alt = UIAlertController(title: Utils.AppName(), message: "Do you want to add \(tfItemName.text!) to your list?", preferredStyle: .alert)
        alt.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
            self.CallAPIForAddItemtoShoppingList(id: self.list_id, item: self.tfItemName.text!)
            self.tfItemName.text = ""
        }))
        
        alt.addAction(UIAlertAction(title: "No", style: .default, handler: { (alertAction) in
            self.tfItemName.text = ""
        }))
        self.present(alt, animated: true) {
        }
        
    }
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode /*else {
         fatalError("Audio engine has no input node")
         }*/
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.tfItemName.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.btnMicrophone.isEnabled = true
            }
        })
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        tfItemName.text = SpeechText.msg
    }
    
    
    //MARK:- Call API For Advertisement
    func CallAPIForAdvertisement(){
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kStoreId] = storeId
        let actio_str = ApiConstant.ApiType.kSpeedShopperMarket + ApiConstant.ApiAction.kadvertisement + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
   /* func gotoAdvertizementVC(){
        /*let vc = self.storyboard?.instantiateViewController(withIdentifier: "AdvertisementVC") as! AdvertisementVC*/
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AdsVC") as! AdsVC
        vc.arrAdvertizementList = arrAdvertisementList
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }*/
    
}

extension SpeedShoppingListVC: GADBannerViewDelegate {
    
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
struct SpeechText {
    static let msg = "Say something, I'm listening!"
}
extension UITableView {
    func reloadData(completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData()})
        {_ in completion() }
    }
}

