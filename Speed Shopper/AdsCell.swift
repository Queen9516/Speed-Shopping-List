//
//  AdsCell.swift
//  Speed Shopping List
//
//  Created by info on 02/07/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

protocol AdsCellDelegate {
    func adsImageTapped(advLink: String?, advId: String?)
}
class AdsCell: UICollectionViewCell {

    var advLink: String?
    var advId: String?
    var delegate: AdsCellDelegate?
    @IBOutlet weak var cntView: UIView!
    @IBOutlet weak var AdsImg: UIImageView!
    @IBOutlet weak var lblAds: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        DispatchQueue.main.async {
            self.cntView.layer.shadowColor = UIColor.lightGray.cgColor
            self.cntView.layer.shadowOpacity = 0.5
            self.cntView.layer.shadowOffset = .zero
            self.cntView.layer.shadowPath = UIBezierPath(rect: self.cntView.bounds).cgPath
            self.cntView.layer.shouldRasterize = true
            
        }
    }

    @IBAction func adsImageTapped(_ sender: UIButton) {
        delegate?.adsImageTapped(advLink: advLink, advId: advId)
    }
}
