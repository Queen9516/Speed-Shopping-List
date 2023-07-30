//
//  FAQListCell.swift
//  Speed Shopping List
//
//  Created by info on 19/05/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class FAQListCell: UITableViewCell {

    @IBOutlet weak var view_cell: UIView!
    @IBOutlet weak var lbl_questions: UILabel!
    @IBOutlet weak var img_cell: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
