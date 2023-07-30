//
//  TransactionHistoryVC.swift
//  Speed Shopping List
//
//  Created by info on 26/06/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import OneSignal

class TransactionHistoryVC: BaseViewController , UITableViewDelegate,UITableViewDataSource , WebServiceDelegate {
    
    @IBOutlet weak var tblTransactionHistory: UITableView!
    var arrHistoryList = [HistoryListModel]()
    var dateSeperate : String = ""
    var timeSeperate : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showNavigationBar()
        self.setupBack()
        self.title = "Transaction History"
        self.CallAPIForTransactionHIstory()
       tblTransactionHistory.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        OneSignal.addTrigger("transaction", withValue: "loaded")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Call API For Transaction History
    func CallAPIForTransactionHIstory(){
        Apimanager.sharedManager.webServiceDelegate = self
        let actio_str = ApiConstant.ApiType.kTransaction + ApiConstant.ApiAction.kTransactionHistory + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiGetMethod(str_Action: actio_str)
    }
    // MARK:- Tableview Datasource And Delegate Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrHistoryList.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryCell", for: indexPath) as! TransactionHistoryCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        let data = arrHistoryList[indexPath.row]
        let DateTime = data.created_at
        let strSeperate = DateTime?.components(separatedBy: " ")
        cell.lblDesciption.text = data.description
        cell.lblQuantity.text = data.quantity
        cell.lblDate.text = strSeperate?[0]
        cell.lblTime.text = strSeperate?[1]
        if data.type == "0" {
            cell.imgType.image = UIImage(named: "red ")
        }else{
            cell.imgType.image = UIImage(named: "green ")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
     //MARK:- Server Response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kTransaction + ApiConstant.ApiAction.kTransactionHistory + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseListModel<HistoryListModel>> ().map(JSONObject: data)else{
                return
            }
            if baseModel.isSuccess {
                arrHistoryList = baseModel.object!
                print(arrHistoryList)
                tblTransactionHistory.reloadData()
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    func error_serverResponse(data: Any, actionStr: String) {
         self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
}
class TransactionHistoryCell: UITableViewCell {
    
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDesciption: UILabel!
    @IBOutlet weak var lblQuantity: UILabel!
    
    @IBOutlet weak var imgType: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}

