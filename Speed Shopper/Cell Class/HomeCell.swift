//
//  HomeCell.swift
//  Speed Shopping List
//
//  Created by info on 12/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class HomeCell: UITableViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lable: UILabel!
    @IBOutlet weak var viewCell: UIView!
    @IBOutlet weak var lbl_storeName: UILabel!
    @IBOutlet weak var lbl_Address: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
