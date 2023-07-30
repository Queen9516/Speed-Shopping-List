//
//  StoreListViewController.swift
//  Speed Shopping List
//
//  Created by Super on 2/23/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import ObjectMapper

protocol StoreListDelegate {
    func ImportItemFromStore(id: String)
}
class StoreListVC: BaseViewController , UITableViewDelegate , UITableViewDataSource{
    var delegate : StoreListDelegate?
    var storeList = [ShoppingListModel]()
    var arrShown = [ShoppingListModel]()//[StoreItemModel]()
    var index = Int()
    
    var sortArray = [ShoppingListModel]()
    @IBOutlet weak var tblAisleLocation: UITableView!
    @IBOutlet weak var tfSearchAisle: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        arrShown = storeList
        sortArray = storeList
        self.tfSearchAisle.addTarget(self, action: #selector(searchAisleFilter(sender:)), for: .allEditingEvents)
    }
    @IBAction func searchAisleFilter(sender : UITextField){
        print("Aa gya")
        if tfSearchAisle.text == "" {
            arrShown = sortArray
            tblAisleLocation.reloadData()
        }else{
            let str = self.tfSearchAisle.text?.uppercased()
            let filtArr = storeList.filter({ (storeLoc) -> Bool in
                return ((storeLoc.name?.uppercased().contains(str!))!)
            })
            print(filtArr)
            arrShown = filtArr
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
        let cell = tblAisleLocation.dequeueReusableCell(withIdentifier: "StoreListTblCell") as! StoreListTblCell
        cell.shoppingListNameLabel.text = arrShown[indexPath.row].name
        cell.storeNameLabel.text = arrShown[indexPath.row].store_name
        cell.id = arrShown[indexPath.row].id!
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tblAisleLocation.cellForRow(at: indexPath) as! StoreListTblCell
        
        let alert = UIAlertController(title: Utils.AppName(), message: "Are you sure you want to import items from " + selectedCell.shoppingListNameLabel.text!, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.delegate?.ImportItemFromStore(id: selectedCell.id)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

