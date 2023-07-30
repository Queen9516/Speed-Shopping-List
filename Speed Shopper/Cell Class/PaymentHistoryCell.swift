//
//  PaymentHistoryCell.swift
//  Speed Shopping List
//
//  Created by info on 20/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class PaymentHistoryCell: UITableViewCell {

    @IBOutlet weak var lableDoller: UILabel!
    @IBOutlet weak var lblBigBazarCoupanCode: UILabel!
    @IBOutlet weak var imgCell: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
