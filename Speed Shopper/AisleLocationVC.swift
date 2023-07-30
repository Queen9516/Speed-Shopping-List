//
//  StoreLocationVC.swift
//  Speed Shopping List
//
//  Created by mac on 11/05/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper

protocol AisleLocationDelegate {
    func SetAisleLocation(id: String , name : String)
}
class AisleLocationVC: BaseViewController , UITableViewDelegate , UITableViewDataSource , WebServiceDelegate{
    var delegate : AisleLocationDelegate?
    var arrAisleLoc = [StoreItemModel]()
    var arrShown = NSArray()//[StoreItemModel]()
    
    var sortArray = NSArray()
    @IBOutlet weak var tblAisleLocation: UITableView!
    @IBOutlet weak var tfSearchAisle: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callAPIForLocation()
        self.tfSearchAisle.addTarget(self, action: #selector(searchAisleFilter(sender:)), for: .allEditingEvents)
    }
    @IBAction func searchAisleFilter(sender : UITextField){
        print("Aa gya")
        if tfSearchAisle.text == "" {
            arrShown = sortArray
            tblAisleLocation.reloadData()
        }else{
            let str = self.tfSearchAisle.text?.uppercased()
            let filtArr = sortArray.filter({ (aisle) -> Bool in
                return ((aisle as! String).components(separatedBy: "__").first?.uppercased().starts(with: str!))!
            })
            print(filtArr)
            arrShown = filtArr as NSArray
            tblAisleLocation.reloadData()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btn_cross(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    //MARK:- Tableview delegate & datasource method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrShown.count//arrShown.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblAisleLocation.dequeueReusableCell(withIdentifier: "ItemAisleTblCell") as! ItemAisleTblCell
        let locName = (arrShown[indexPath.row] as! String).components(separatedBy: "_")
        cell.lblAisleLocation.text = locName[0]//arrShown[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let aisleLocData = (arrShown[indexPath.row] as! String).components(separatedBy: "_") //arrShown[indexPath.row]
        self.delegate?.SetAisleLocation(id: aisleLocData.last!, name: aisleLocData.first!)
    }
    
    func callAPIForLocation(){
        Apimanager.sharedManager.webServiceDelegate = self
        let actio_str = ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kLocation + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiGetMethod(str_Action: actio_str)
    }
    //MARK:- Server response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kShopping + ApiConstant.ApiAction.kLocation + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseListModel<StoreItemModel>>().map(JSONObject: data) else {
                print("Parse Error")
                return}
            if baseModel.isSuccess {
                //                arrAisleLoc = baseModel.object!
                //                arrShown = arrAisleLoc
                //
                //                //
                //                let sortArray = ((data as! NSDictionary).value(forKey: "data") as! NSArray).sortedArray(using: [NSSortDescriptor(key: "name", ascending: true)])
                //                print(sortArray)
                
                /*let finalArr = NSArray()
                 for a in  sortArray{
                 let aDict = a as! NSDictionary
                 let id = NSNumber(value: aDict.value(forKey: "id"))
                 if id != nil {
                 let addData = "0" + "\(String(describing: aDict.value(forKey: "id")))"
                 finalArr.adding(addData)
                 }else {
                 let addData = "\(String(describing: aDict.value(forKey: "id")))"
                 finalArr.adding(addData)
                 }
                 }
                 
                 print(finalArr)*/
                
                //
                sortArray = (data as! NSDictionary).value(forKey: "data") as! NSArray
                arrShown = sortArray
                print(sortArray)
                
                tblAisleLocation.reloadData()
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    
    func error_serverResponse(data: Any, actionStr: String) {
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
}

