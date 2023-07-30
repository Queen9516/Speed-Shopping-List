//
//  Wallet2VC.swift
//  Speed Shopping List
//
//  Created by info on 04/07/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class Wallet2VC: BaseViewController {
    
    @IBOutlet weak var lblQRAddress: UILabel!
    @IBOutlet weak var lblPrivateAddress: UILabel!
    @IBOutlet weak var imgQRCode: UIImageView!
    
    var address = ""
    var PrivateAddress = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       print(address)
        if address == "" {
            self.showAnnouncement(withMessage: "Address is empty")
        }else{
            self.lblQRAddress.text = address
            self.lblPrivateAddress.text = PrivateAddress
            let imageQR = generateQRCode(from: address)
            self.imgQRCode.image = imageQR
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func btnDismissAction(_ sender: UIButton) {
        self.addTransitionEffect()
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func btnAddressCopy(_ sender: UIButton) {
        if lblQRAddress.text == "" {
            self.showAnnouncement(withMessage: "cannot empty the clipboard")
        }else{
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.lblQRAddress.text!
            self.showAnnouncement(withMessage: "copy to clipboard successfully")
        }
    }
    @IBAction func btnPrivateAddressCopy(_ sender: UIButton) {
        if lblQRAddress.text == "" {
            self.showAnnouncement(withMessage: "cannot empty the clipboard")
        }else{
            let pasteboard = UIPasteboard.general
            pasteboard.string = self.lblPrivateAddress.text!
            self.showAnnouncement(withMessage: "copy to clipboard successfully")
        }
    }
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}
