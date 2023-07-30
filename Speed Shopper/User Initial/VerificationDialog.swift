//
//  VerificationDialog.swift
//  Speed Shopping List
//
//  Created by Rome on 12/15/21.
//  Copyright © 2021 mac. All rights reserved.
//

import UIKit

protocol PopUpDelegate {
    func handleAction(action: String)
}

class VerificationDialog: BaseViewController {
    
    var delegate: PopUpDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func optionSelected() {
        
    }
 
    @IBAction func TextMePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.handleAction(action: "Text")
    }
    
    @IBAction func EmailMePressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.handleAction(action: "Email")
    }
    
    
    static func showPopup(parentVC: BaseViewController){
        if let popupViewController = parentVC.storyboard?.instantiateViewController(withIdentifier: "VerificationDialog") as? VerificationDialog {
            popupViewController.modalPresentationStyle = .custom
            popupViewController.modalTransitionStyle = .crossDissolve
            popupViewController.delegate = parentVC as? PopUpDelegate
            parentVC.present(popupViewController, animated: true)
        }
    }
}
