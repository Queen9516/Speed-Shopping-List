//
//  ContactUSViewController.swift
//  Speed Shopping List
//
//  Created by info on 16/05/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import OneSignal

class ContactUSViewController: BaseViewController , WebServiceDelegate , UITextViewDelegate, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var textView_Message: UITextView!
    @IBOutlet weak var tblmessageList: UITableView!
    
    var pageNumber = 1
    var pageLimit = 5
    var refreshSponsors = Bool()
    let tvPlaceholderText = "Message"
    var arrMessageList = [MessageListModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contact"
        tblmessageList.separatorStyle = UITableViewCellSeparatorStyle.none
        self.CallAPIForMessage(pageNo: pageNumber)
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        OneSignal.addTrigger("contact", withValue: "loaded")
    }
    //MARK:- Call API For Messages
    func CallAPIForMessage(pageNo : Int) {
        Apimanager.sharedManager.webServiceDelegate = self
        let actio_str = ApiConstant.ApiType.kComman + ApiConstant.ApiAction.kMessages + SharedPreference.getUserData().token + "/" + "\(pageNo)"
        Apimanager.sharedManager.callApiGetMethod(str_Action: actio_str)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btn_Submit(_ sender: UIButton){
        if textView_Message.isEmpty() || textView_Message.text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == tvPlaceholderText{
            self.showAnnouncement(withMessage: "Message can not be blank")
        }else{
            let message = textView_Message.text!
            self.callAPIForContact(message: message)
        }
    }
    //MARK:- Call API For ContactUS
    func callAPIForContact(message: String){
        Apimanager.sharedManager.webServiceDelegate = self
        var param = [String: Any]()
        param[ApiConstant.ApiKey.kMessage] = message
        let actio_str = ApiConstant.ApiType.kComman + ApiConstant.ApiAction.kContact + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiPostMethod(str_Action: actio_str, param: param)
    }
    
    //MARK:- API Success
    func success_serverResponse(data: Any, actionStr: String){
        if actionStr == ApiConstant.ApiType.kComman + ApiConstant.ApiAction.kContact + SharedPreference.getUserData().token {
            guard let baseModel =  Mapper<BaseModel<ContactModel>>().map(JSONObject: data)else {
                self.showAnnouncement(withMessage: "Parser error")
                return
            }
            if baseModel.isSuccess{
                self.showAnnouncement(withMessage: baseModel.msg!)
                textView_Message.text = tvPlaceholderText
            }else{
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
        } else if actionStr == ApiConstant.ApiType.kComman + ApiConstant.ApiAction.kMessages + SharedPreference.getUserData().token + "/" + "\(pageNumber)" {
            print("MessageList: ", arrMessageList)
            guard let baseModel = Mapper<BaseListModel<MessageListModel>>().map(JSONObject: data) else {
                return
            }
            refreshSponsors = false
            if baseModel.isSuccess {
                arrMessageList += baseModel.object!
                tblmessageList.reloadData()
            }else{
                pageNumber -= 1
                self.showAnnouncement(withMessage: baseModel.msg!)
            }
            
        }
    }
      func error_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kComman + ApiConstant.ApiAction.kContact + SharedPreference.getUserData().token {
            self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)

        } else if actionStr == ApiConstant.ApiType.kComman + ApiConstant.ApiAction.kMessages + SharedPreference.getUserData().token + "/" + "\(pageNumber)" {
            refreshSponsors = false
            pageNumber -= 1
            self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
        }
        
    }
    //MARK:- UITextViewDelegate Method
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if textView.text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == tvPlaceholderText {
            textView.text = ""
            textView_Message.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == tvPlaceholderText || textView.text.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == ""
        {
           textView_Message.text = tvPlaceholderText
           textView_Message.textColor = UIColor.lightGray
        }
    }
    
    // MARK:- Tableview Datasource And Delegate Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMessageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesCell") as! MessagesCell
        let data = arrMessageList[indexPath.row]
        cell.selectionStyle = .none
        cell.lbl_Title.text = data.title
        cell.txt_Message.text = data.message
        cell.txt_Message.translatesAutoresizingMaskIntoConstraints = false
        cell.txt_Message.sizeToFit()
        cell.txt_Message.isScrollEnabled = false
        cell.lbl_DateTime.text = ServerToLocal(dateStr: data.created_at!)
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
        visibleRect.origin = tblmessageList.contentOffset
        visibleRect.size = tblmessageList.bounds.size
        print("Mid X= \(visibleRect.midX) , Min X= \(visibleRect.minX) , Max X= \(visibleRect.maxX)")
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.maxY - 50)
        let visibleIndexPath: IndexPath? = tblmessageList.indexPathForRow(at: visiblePoint) //indexPathForItem(at: visiblePoint)
        //print("Index::::: \(visibleIndexPath?.row)")
        
        if visibleIndexPath?.row == (arrMessageList.count - 1)  {
            print("last pr aa gya")
            if !refreshSponsors{
                refreshSponsors = true
                pageNumber += 1
                self.CallAPIForMessage(pageNo: pageNumber)
            }
        }
    }
}

class MessagesCell: UITableViewCell {
    
    @IBOutlet weak var lbl_DateTime: UILabel!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var txt_Message: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
