//
//  FAQAnswerVC.swiftT
//  Speed Shopping List
//
//  Created by info on 19/05/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import ObjectMapper
import OneSignal

class FAQAnswerVC: BaseViewController {
    @IBOutlet weak var lbl_Question: UILabel!
    //@IBOutlet weak var lbl_Answer: UILabel!
    @IBOutlet weak var textview_Answer: UITextView!
    
    @IBOutlet weak var imgFaqAns: UIImageView!
    var FAQData = FAQListModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "FAQ"
        self.setupBack()
       let imagePath = FAQData.image
        self.imgFaqAns?.sd_setImage(with: URL(string: imagePath!), placeholderImage: #imageLiteral(resourceName: "img"), options: .progressiveLoad, completed: nil)
       // sd_setImage(with: URL(string: imagePath!), placeholderImage: #imageLiteral(resourceName: "cross"), options: .progressiveDownload, completed: nil)
       self.lbl_Question.text = FAQData.question
       self.textview_Answer.text = FAQData.answer
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        OneSignal.addTrigger("answer", withValue: "loaded")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }
}
