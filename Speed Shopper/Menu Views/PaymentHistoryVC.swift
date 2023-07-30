//
//  PaymentHistoryVC.swift
//  Speed Shopping List
//
//  Created by mac on 14/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import OneSignal

class PaymentHistoryVC: BaseViewController ,UITableViewDelegate, UITableViewDataSource, CollapsibleTableViewHeaderDelegate {
    @IBOutlet weak var tblPaymentHistory: UITableView!
    
    @IBOutlet weak var lbl_commingsoon: UILabel!
    
    var sections = sectionsData
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Payment history"
        tblPaymentHistory.isHidden = true
        lbl_commingsoon.isHidden = false
        
        tblPaymentHistory.rowHeight = UITableViewAutomaticDimension
        tblPaymentHistory.separatorColor = UIColor.gray
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        OneSignal.addTrigger("history", withValue: "loaded")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PaymentHistoryCell
        let item: Item = sections[indexPath.section].items[indexPath.row]
        cell.lblBigBazarCoupanCode.text = item.name
        cell.lblBigBazarCoupanCode.textColor = UIColor.darkGray
        cell.lableDoller.text = item.detail
        cell.lableDoller.textColor = UIColor.darkGray
        return cell
    }
    
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int){
        let collapsed = !sections[section].collapsed
        sections[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        tblPaymentHistory.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if sections[indexPath.section].collapsed{
            return UITableViewAutomaticDimension //According to need
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleTableViewHeader ?? CollapsibleTableViewHeader(reuseIdentifier: "header")
        header.titleLabel.text = sections[section].name
        header.arrowLabel.text = ">"
        header.section = section
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
}

