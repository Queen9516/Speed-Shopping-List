//
//  StoreLocationTblCell.swift
//  Speed Shopping List
//
//  Created by mac on 11/05/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class StoreListTblCell: UITableViewCell {

    @IBOutlet weak var shoppingListNameLabel: UILabel!
    @IBOutlet weak var storeNameLabel: UILabel!
    var id = String()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
