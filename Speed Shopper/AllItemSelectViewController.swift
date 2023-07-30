//
//  AllItemSelectViewController.swift
//  Speed Shopping List
//
//  Created by Super on 4/22/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class AllItemSelectViewController: UIViewController {

    @IBOutlet weak var doneImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doneImage.loadGif(asset: "done")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didTapCloseBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
