import UIKit
import BEMCheckBox

protocol SortDelegate {
    func clickSortItem(item: Int)
}

class SortDialog: BaseViewController, BEMCheckBoxDelegate {
    
    
    @IBOutlet var myView: UIView!
    @IBOutlet var aisleUpButton: UIButton!
    @IBOutlet var aisleDownButton: UIButton!
    @IBOutlet var nameUpButton: UIButton!
    @IBOutlet var nameDownButton: UIButton!
    
    @IBOutlet weak var aisleUpCheckBox: BEMCheckBox!
    @IBOutlet weak var aisleDownCheckBox: BEMCheckBox!
    @IBOutlet weak var nameUpCheckBox: BEMCheckBox!
    @IBOutlet weak var nameDownCheckBox: BEMCheckBox!
    
    var delegate: SortDelegate?
    var currentSortMode: Int = 1
    var checkBoxColor: String = "#116C99"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped))
        myView.addGestureRecognizer(gesture)
        
        aisleUpCheckBox.delegate = self
        aisleUpCheckBox.tag = 0
        aisleDownCheckBox.delegate = self
        aisleDownCheckBox.tag = 1
        nameUpCheckBox.delegate = self
        nameUpCheckBox.tag = 2
        nameDownCheckBox.delegate = self
        nameDownCheckBox.tag = 3
        
        aisleUpCheckBox.onTintColor = UIColor.hexStringToUIColor(checkBoxColor)
        aisleUpCheckBox.onCheckColor = UIColor.hexStringToUIColor(checkBoxColor)
        aisleDownCheckBox.onTintColor = UIColor.hexStringToUIColor(checkBoxColor)
        aisleDownCheckBox.onCheckColor = UIColor.hexStringToUIColor(checkBoxColor)
        nameUpCheckBox.onTintColor = UIColor.hexStringToUIColor(checkBoxColor)
        nameUpCheckBox.onCheckColor = UIColor.hexStringToUIColor(checkBoxColor)
        nameDownCheckBox.onTintColor = UIColor.hexStringToUIColor(checkBoxColor)
        nameDownCheckBox.onCheckColor = UIColor.hexStringToUIColor(checkBoxColor)
        
        updateSelectCheckBox(index: currentSortMode)
        switch currentSortMode {
        case 0:
            aisleUpButton.setTitleColor(UIColor.hexStringToUIColor(checkBoxColor), for: .normal)
            break
        case 1:
            aisleDownButton.setTitleColor(UIColor.hexStringToUIColor(checkBoxColor), for: .normal)
            break
        case 2:
            nameUpButton.setTitleColor(UIColor.hexStringToUIColor(checkBoxColor), for: .normal)
            break
        case 3:
            nameDownButton.setTitleColor(UIColor.hexStringToUIColor(checkBoxColor), for: .normal)
            break
        default:
            break
        }
    }
    
    @objc func viewTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        didSelectOption(index: checkBox.tag)
    }
    
    func updateSelectCheckBox(index: Int) {
        aisleUpCheckBox.on = false
        aisleDownCheckBox.on = false
        nameUpCheckBox.on = false
        nameDownCheckBox.on = false
        
        switch currentSortMode {
        case 0:
            aisleUpCheckBox.on = true
            break
        case 1:
            aisleDownCheckBox.on = true
            break
        case 2:
            nameUpCheckBox.on = true
            break
        case 3:
            nameDownCheckBox.on = true
            break
        default:
            break
        }
    }
    
    func didSelectOption(index: Int) {
        updateSelectCheckBox(index: index)
        self.dismiss(animated: true, completion: nil)
        self.delegate?.clickSortItem(item: index)
    }
    
    @IBAction func index0(_ sender: UIButton) {
        didSelectOption(index: 0)
    }
    
    @IBAction func index1(_ sender: UIButton) {
        didSelectOption(index: 1)
    }
    
    @IBAction func index2(_ sender: UIButton) {
        didSelectOption(index: 2)
    }
    
    @IBAction func index3(_ sender: UIButton) {
        didSelectOption(index: 3)
    }
    
    static func showPopup(parentVC: BaseViewController, sortMode: Int){
        if let popupViewController = parentVC.storyboard?.instantiateViewController(withIdentifier: "SortDialog") as? SortDialog {
            popupViewController.modalPresentationStyle = .custom
            popupViewController.modalTransitionStyle = .crossDissolve
            popupViewController.delegate = parentVC as? SortDelegate
            popupViewController.currentSortMode = sortMode
            parentVC.present(popupViewController, animated: true)
        }
    }
}
