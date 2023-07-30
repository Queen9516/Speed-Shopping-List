//
//  AdsVC.swift
//  Speed Shopping List
//
//  Created by info on 02/07/18.
//  Copyright © 2018 mac. All rights reserved.
//

import UIKit
import AnimatedCollectionViewLayout

class AdsVC: BaseViewController , UICollectionViewDelegate, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var AdsView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageCtrl: UIPageControl!
    
    @IBOutlet weak var adsTitle: UILabel!
    
    //@IBOutlet weak var pageCtrl: UIPageControl!
    var arrAdvertizementList = [AdvertisementListModel]()
    var runAt = 0
    var index = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        pageCtrl.numberOfPages = arrAdvertizementList.count
        print(arrAdvertizementList)
        //adsTitle.text = "\(arrAdvertizementList[index].adevertise_name ?? ""), \(arrAdvertizementList[index].description ?? "")"
        collectionView.register(UINib.init(nibName: "AdsCell", bundle: nil), forCellWithReuseIdentifier: "AdsCell")
        
       let flowLayout = UPCarouselFlowLayout()
        if arrAdvertizementList.count == 1 {
            flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: collectionView.frame.size.height)
            flowLayout.spacingMode = .fixed(spacing: 0)
            flowLayout.sideItemScale = 1.0
        }else{
            flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 20, height: collectionView.frame.size.height)
            flowLayout.spacingMode = .fixed(spacing: 5.0)
            flowLayout.sideItemScale = 0.8
        }
        
        flowLayout.sideItemAlpha = 1.0
        
        flowLayout.scrollDirection = .horizontal
        
         //collectionView.collectionViewLayout = flowLayout
        collectionView.reloadData()
        

      //  self.startTimer()
         //self.viewDesign()
    }
    func viewDesign(){
        self.AdsView.layer.shadowColor = UIColor.lightGray.cgColor
        self.AdsView.layer.shadowOpacity = 0.5
        self.AdsView.layer.shadowOffset = .zero
        self.AdsView.layer.shadowPath = UIBezierPath(rect: self.AdsView.bounds).cgPath
        self.AdsView.layer.shouldRasterize = true
    }
    @IBAction func btn_dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- UicollectionView Datasource & Delegate Method
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrAdvertizementList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdsCell", for: indexPath) as! AdsCell
        index = indexPath.row
        let imagePath = arrAdvertizementList[indexPath.row].image
        cell.AdsImg.sd_setImage(with: URL(string: imagePath!), placeholderImage: #imageLiteral(resourceName: "img") )
        cell.lblAds.text = arrAdvertizementList[indexPath.row].name
        cell.advLink = arrAdvertizementList[indexPath.row].adv_link
        cell.advId = arrAdvertizementList[indexPath.row].adv_id
        cell.delegate = self
        return cell
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect: CGRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        var visibleIndexPath: IndexPath? = collectionView.indexPathForItem(at: visiblePoint)
        //print("Index::::: \(visibleIndexPath?.row)")
        self.pageCtrl.currentPage = (visibleIndexPath?.row)!
        /*if visibleIndexPath?.row == (arrSponsors.count - 1) {
            print("last pr aa gya")
            if !refreshSponsors{
                refreshSponsors = true
            }
        }*/
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width + 20, height: collectionView.frame.size.height)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //self.pageCtrl.currentPage = indexPath.row
    }
    
    func startTimer() {
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(scrollToNextCell), userInfo: nil, repeats: true);
    }
    @objc func scrollToNextCell() {
        if runAt < arrAdvertizementList.count {
            self.ScrollView()
        }else{
            runAt = 0
            self.ScrollView()
        }
        runAt += 1
    }
    func ScrollView(){
        self.collectionView.scrollToItem(at:IndexPath(item: runAt, section: 0), at: .right, animated: false)
    }

}

extension AdsVC: AdsCellDelegate {
    func adsImageTapped(advLink: String?, advId: String?) {
        if let advLink = advLink, let advId = advId, advLink != "", advId != "", let url = URL(string: advLink)  {
            
            // Call ads incrase count api
            var param = [String: Any]()
            param[ApiConstant.ApiKey.kAdsId] = advId
            let act_str = ApiConstant.ApiType.kSpeedShopperMarket + ApiConstant.ApiAction.kIncreaseAdsCount + SharedPreference.getUserData().token
            Apimanager.sharedManager.callApiPostMethod(str_Action: act_str, param: param)
                        
            // Open Advertising URL
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            
        }
    }
    
    
}
