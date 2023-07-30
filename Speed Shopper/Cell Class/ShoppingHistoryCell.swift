//
//  ShoppingHistoryCell.swift
//  Speed Shopping List
//
//  Created by info on 21/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class ShoppingHistoryCell: UITableViewCell {
    @IBOutlet weak var view_cell: UIView!
    @IBOutlet weak var lable_items: UILabel!
    @IBOutlet weak var lbl_StoreName : UILabel!
    @IBOutlet weak var Img_store: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
