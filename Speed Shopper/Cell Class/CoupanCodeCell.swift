//
//  CoupanCodeCell.swift
//  Speed Shopping List
//
//  Created by info on 25/06/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class CoupanCodeCell: UITableViewCell {

    @IBOutlet weak var ezTitle: UILabel!
    @IBOutlet weak var ezDesc: UILabel!
    @IBOutlet weak var ezImg: UIImageView!
    @IBOutlet weak var viewCell : UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
