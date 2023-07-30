//
//  FAQVC.swift
//  Speed Shopping List
//
//  Created by info on 18/05/18.
//  Copyright © 2018 mac. All rights reserved.
//
import UIKit
import ObjectMapper
import OneSignal

class FAQVC: BaseViewController ,UITableViewDelegate, UITableViewDataSource, WebServiceDelegate {
    @IBOutlet weak var tbl_FAQList: UITableView!
    var arrFAQList = [FAQListModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.setupBack()
        self.title = "FAQ"
        tbl_FAQList.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         callAPIForFAQ()
        OneSignal.addTrigger("faq", withValue: "loaded")
    }
    func callAPIForFAQ(){
        Apimanager.sharedManager.webServiceDelegate = self
        let actio_str = ApiConstant.ApiType.kComman + ApiConstant.ApiAction.kFaq + SharedPreference.getUserData().token
        Apimanager.sharedManager.callApiGetMethod(str_Action: actio_str)
    }
    //MARK:- API Success
    func success_serverResponse(data: Any, actionStr: String) {
        if actionStr == ApiConstant.ApiType.kComman + ApiConstant.ApiAction.kFaq + SharedPreference.getUserData().token {
            guard let baseModel = Mapper<BaseListModel<FAQListModel>>().map(JSONObject: data) else {
                print("Parse Error")
                return
            }
            if baseModel.isSuccess {
                arrFAQList = baseModel.object!
                print(arrFAQList)
               self.tbl_FAQList.reloadData()
            }
            else {
                print("Parse Error")
            }
        }
    }
    func error_serverResponse(data: Any, actionStr: String) {
         self.showAnnouncement(withMessage: (data as AnyObject).userInfo[NSLocalizedDescriptionKey] as! String)
    }
    //MARK:- Tableview datasource Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFAQList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellRID", for: indexPath) as! FAQListCell
        let data = arrFAQList[indexPath.row]
        cell.lbl_questions.text = data.question
        cell.lbl_questions.numberOfLines = 0
        return cell
    }
    
    //MARK:- TAbleview Delegate Method
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let vc = self.storyboard?.instantiateViewController(withIdentifier: "FAQAnswerVC") as! FAQAnswerVC
        vc.FAQData = arrFAQList[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
