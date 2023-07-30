//
//  TransferSSTXVC.swift
//  Speed Shopping List
//
//  Created by mac on 17/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import OneSignal

class TransferSSTXVC: BaseViewController, UITextFieldDelegate , UITableViewDelegate , UITableViewDataSource {

    @IBOutlet weak var tblHistory: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var vwSearch: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let gradient = CAGradientLayer()
            gradient.frame = self.vwSearch.bounds
            gradient.colors = [UIColor.hexStringToUIColor("bfbec3"),UIColor.hexStringToUIColor("d8d8d9") , UIColor.hexStringToUIColor("bfbec3")]
            
            self.vwSearch.layer.insertSublayer(gradient, at: 0)
        }*/
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        OneSignal.addTrigger("transfer", withValue: "loaded")
    }
    
    @IBAction func clickMeAction(_ sender: UIButton) {
        self.showAnnouncement(withMessage: "Click me")
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("yha toh aa rha")
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- UITableview Datasource method
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TransactionTblCell = tableView.dequeueReusableCell(withIdentifier: "TransactionTblCell") as! TransactionTblCell
        return cell
    }
    
    //MARK:- UITableview delegate Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Ho rha click")
        let transfer = self.storyboard?.instantiateViewController(withIdentifier: "TransferSSXTVC") as! TransferSSXTVC
        self.navigationController?.pushViewController(transfer, animated: true)
    }
}
