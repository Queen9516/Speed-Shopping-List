//
//  ItemImageViewController.swift
//  Speed Shopping List
//
//  Created by Wang on 3/13/21.
//  Copyright © 2021 mac. All rights reserved.
//

import UIKit

class ItemImageViewController: UIViewController {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var ImageContainerView: UIView!
    var itemImage1: UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
        itemImage.image = itemImage1

    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
