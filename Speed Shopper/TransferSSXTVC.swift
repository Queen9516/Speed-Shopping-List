//
//  TransferSSXTVC.swift
//  Speed Shopping List
//
//  Created by info on 20/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import OneSignal

class TransferSSXTVC: BaseViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblTransferSSTX: UITableView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Transfer SSXT"
        tblTransferSSTX.rowHeight = UITableViewAutomaticDimension
        tblTransferSSTX.separatorStyle = UITableViewCellSeparatorStyle.none
        tblTransferSSTX.separatorColor = UIColor.hexStringToUIColor(AppColor.blueColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        OneSignal.addTrigger("transfer", withValue: "loaded")
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            let celloddPosition = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! TransferSSTXCell
            celloddPosition.lable_Rupee.text = "500"
            celloddPosition.lable_SSTX.text = "'SSTX'"
            celloddPosition.lable_date.text = "- 18 Febuary"
            return celloddPosition
        }
        else {
        let cellEvenPosition = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! TransferSSTXCell2
            cellEvenPosition.lable_Rupee.text = "500"
            cellEvenPosition.lable_SSTX.text = "'SSTX'"
            cellEvenPosition.lable_Date.text = "- 18 Febuary"
        
            return cellEvenPosition
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
