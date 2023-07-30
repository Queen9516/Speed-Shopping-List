//
//  ShoppingListCell.swift
//  Speed Shopping List
//
//  Created by info on 12/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class ShoppingListCell: UITableViewCell {

    @IBOutlet weak var lable: UILabel!
    @IBOutlet weak var viewCell: UIView!
  
    @IBOutlet weak var storeLogo: UIImageView!
    @IBOutlet weak var cellBox: UIImageView!
    @IBOutlet weak var Btn_edit: UIButton!
    @IBOutlet weak var btn_delete: UIButton!
    @IBOutlet weak var lable_ItemList: UILabel!
    @IBOutlet weak var lbl_storeName: UILabel!
    @IBOutlet weak var lbl_storeFullAddress: UILabel!
    @IBOutlet var btnDetail: UIButton!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var itemCountView: UIView!
    @IBOutlet weak var arrowRight: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        itemCountView.layer.cornerRadius = 15
        itemCountView.layer.masksToBounds = true
        arrowRight.loadGif(asset: "arrow_right")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
