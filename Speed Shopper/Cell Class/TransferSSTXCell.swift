//
//  TransferSSTXCell.swift
//  Speed Shopping List
//
//  Created by info on 20/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class TransferSSTXCell: UITableViewCell {

    @IBOutlet weak var viewCell: UIView!
    
    @IBOutlet weak var lable_Rupee: UILabel!
    
    @IBOutlet weak var lable_SSTX: UILabel!
    
    @IBOutlet weak var lable_date: UILabel!
    @IBOutlet weak var Btn_SeeDetails: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
