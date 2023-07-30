//
//  SpeedShoppingListCell.swift
//  Speed Shopping List
//
//  Created by info on 19/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
//import BEMCheckBox
protocol SpeedShoppingListCellDelegate : class {
    func previewImage(_ sender: SpeedShoppingListCell)
    func editItem(_ sender: SpeedShoppingListCell)
}
class SpeedShoppingListCell: UITableViewCell {

    @IBOutlet weak var deleteItemBtn: UIButton!
    @IBOutlet weak var editItemBtn: UIButton!
    @IBOutlet weak var lable_list: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var aisleLabel: UILabel!
    @IBOutlet weak var itemCheckBox: BEMCheckBox!
    
    @IBOutlet weak var btnTakePic: UIButton!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemImageContainer: UIView!
    
    @IBOutlet weak var lblTrailingValue: NSLayoutConstraint!

    var cellID : Int = 0
    var customCellID: Int = 0
    var cellDelegate: SpeedShoppingListCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func btnTakePicTapped(_ sender: UIButton) {
        cellDelegate?.previewImage(self)
    }
    
    @IBAction func btnEditItemTapped(_ sender: UIButton) {
        cellDelegate?.editItem(self)
    }
    
    func adjust(upgraded: Bool, imageName: String) {
        if upgraded && imageName != "" {
            lblTrailingValue.constant = 46
            let link = "https://www.speedshopperapp.com/app/public/item_images/" + imageName
            let url = link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            let imageURL = URL(string: url!)!
            DispatchQueue.global().async {
                // Fetch Image Data
                if let data = try? Data(contentsOf: imageURL) {
                    DispatchQueue.main.async {
                        // Create Image and Update Image View
                        self.itemImage.image = UIImage(data: data)
                        self.itemImageContainer.isHidden = false
                    }
                }
            }
            
        } else {
            
            lblTrailingValue.constant = 10
            self.itemImageContainer.isHidden = true
            
        }
    }
}
