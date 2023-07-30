//
//  NotificationVC.swift
//  Speed Shopping List
//
//  Created by mac on 14/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import OneSignal

class NotificationVC: BaseViewController , WebServiceDelegate , UITableViewDataSource, UITableViewDelegate , UIScrollViewDelegate{
    var pageNumber = 1
    var pageLimit = 10
    var refreshSponsors = Bool()
    @IBOutlet weak var tblNotificationList: UITableView!
    var arrNotificationList = [NotificationListModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the vie
        self.title = "Notifications"
        
        tblNotificationList.separatorStyle = UITableViewCellSeparatorStyle.none
        self.CallAPIForNotification(pageNo: pageNumber)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        OneSignal.addTrigger("notification", withValue: "loaded")
    }
    
    //MARK:- Call API For Notification
    func CallAPIForNotification(pageNo : Int) {
        Apimanager.sharedManager.webServiceDelegate = self
        let actio_str = ApiConstant.ApiType.kComman + ApiConstant.ApiAction.kNotifications + SharedPreference.getUserData().token + "/" + "\(pageNo)"
        Apimanager.sharedManager.callApiGetMethod(str_Action: actio_str)
    }
    
    @IBAction func btn_onClick(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AdsVC") as! AdsVC
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Tableview Datasource And Delegate Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNotificationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationListCell") as! NotificationListCell
        let data = arrNotificationList[indexPath.row]
        cell.selectionStyle = .none
        cell.lblTitle.text = data.title
        cell.lblType.text = data.type
        cell.messageTextView.text = data.message
        cell.messageTextView.translatesAutoresizingMaskIntoConstraints = false
        cell.messageTextView.sizeToFit()
        cell.messageTextView.isScrollEnabled = false
//        cell.lblMessage.text = data.message
//        cell.lblMessage.numberOfLines = 0
        cell.lblDateTime.text = ServerToLocal(dateStr: data.created_at!)
        return cell
    }
    
    func ServerToLocal(dateStr:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT+5:30")
        
        let dt = dateFormatter.date(from: dateStr)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        
        return dateFormatter.string(from: dt!)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect: CGRect = CGRect()
        visibleRect.origin = tblNotificationList.contentOffset
        visibleRect.size = tblNotificationList.bounds.size
        print("Mid X= \(visibleRect.midX) , Min X= \(visibleRect.minX) , Max X= \(visibleRect.maxX)")
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.maxY - 50)
        let visibleIndexPath: IndexPath? = tblNotificationList.indexPathForRow(at: visiblePoint) //indexPathForItem(at: visiblePoint)
        //print("Index::::: \(visibleIndexPath?.row)")
        
        if visibleIndexPath?.row == (arrNotificationList.count - 1) {
            print("last pr aa gya")
            if !refreshSponsors{
                refreshSponsors = true
                pageNumber += 1
                self.CallAPIForNotification(pageNo: pageNumber)
            }
        }
    }
    
    //MARK:- Server Response
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kComman + ApiConstant.ApiAction.kNotifications + SharedPreference.getUserData().token + "/" + "\(pageNumber)" {
            guard let baseModel = Mapper<BaseListModel<NotificationListModel>>().map(JSONObject: data) else {
                return
            }
            refreshSponsors = false
            if baseModel.isSuccess {
                arrNotificationList += baseModel.object!
                tblNotificationList.reloadData()
            }else{
                pageNumber -= 1
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        }
    }
    
    func error_serverResponse(data: Any, actionStr: String) {
        if actionStr ==  ApiConstant.ApiType.kComman + ApiConstant.ApiAction.kNotifications + SharedPreference.getUserData().token + "/" + "\(pageNumber)"{
            refreshSponsors = false
            pageNumber -= 1
        }
        self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
}

class NotificationListCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblDateTime: UILabel!
    
    @IBOutlet weak var imgType: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
