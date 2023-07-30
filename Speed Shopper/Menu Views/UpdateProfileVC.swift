//
//  UpdateProfileVC.swift
//  Speed Shopper
//
//  Created by info on 14/05/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit

class UpdateProfileVC: UIViewController {

    @IBOutlet weak var vwDetail: UIView!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfMobile: UITextField!
    @IBOutlet weak var imgProfilePic: UIImageView!
    @IBOutlet weak var imgProfileBackGround: UIImageView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnUpdateProfile: UIButton!
    @IBOutlet weak var btnEditProfile: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
