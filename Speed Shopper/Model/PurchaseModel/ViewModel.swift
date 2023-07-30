//
//  ViewModel.swift
//  Speed Shopping List
//
//  Created by Wang on 11/30/20.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation
import StoreKit

protocol ViewModelDelegate {
    func toggleOverlay(shouldShow: Bool)
    func willStartLongProcess()
    func didFinishLongProcess()
    func showIAPRelatedError(_ error: Error)
    func shouldUpdateUI(list_id: String)
    func didFinishRestoringPurchasesWithZeroProducts()
    func didFinishRestoringPurchasedProducts()
}


class ViewModel {
    
    // MARK: - Properties
    
    var delegate: ViewModelDelegate?
    
    private let model = Model()
    
    
    var didUnlockStoreLogos: Bool {
        return model.appData.didUnlockStoreLogos
    }
    
    
    // MARK: - Init
        
    init() {

    }
    
    
    // MARK: - Fileprivate Methods
    
    fileprivate func updateAppDataWithPurchasedProduct(_ product: SKProduct, list_id: String) {
        // Update the proper game data depending on the keyword the
        // product identifier of the give product contains.
        if product.productIdentifier.contains("logos") {
            model.appData.didUnlockStoreLogos = true
        }
        
        // Store changes.
        _ = model.appData.update()
        
        // Ask UI to be updated and reload the table view.
        delegate?.shouldUpdateUI(list_id: list_id)
    }
    
    
    fileprivate func restoreUnlockedLogos() {
        // Mark all maps as unlocked.
        model.appData.didUnlockStoreLogos = true
        
        // Save changes and update the UI.
        _ = model.appData.update()
//        delegate?.shouldUpdateUI(list_id: String)
    }
    
    
    
    // MARK: - Internal Methods
    
    func getProductForItem(at index: Int) -> SKProduct? {
        // Search for a specific keyword depending on the index value.
        let keyword: String
        
        switch index {
            case 0: keyword = "logos"
            default: keyword = ""
        }
        
        // Check if there is a product fetched from App Store containing
        // the keyword matching to the selected item's index.
        guard let product = model.getProduct(containing: keyword) else { return nil }
        print("product:", product)
        return product
    }
    
    
    
    // MARK: - Methods To Implement
    
    func viewDidSetup() {
        delegate?.willStartLongProcess()
        
        IAPManager.shared.getProducts { (result) in
            DispatchQueue.main.async {
                self.delegate?.didFinishLongProcess()
                
                switch result {
                    case .success(let products):
                        print("Purchase Item count:-->", products.count)
                        self.model.products = products
                    case .failure(let error):
                        self.delegate?.showIAPRelatedError(error)
                }
            }
        }
    }
    
    func purchase(product: SKProduct, list_id: String) -> Bool {
        if !IAPManager.shared.canMakePayments() {
            return false
        } else {
            delegate?.willStartLongProcess()
            
            IAPManager.shared.buy(product: product) { (result) in
                DispatchQueue.main.async {
                    self.delegate?.didFinishLongProcess()

                    switch result {
                    case .success(_): self.updateAppDataWithPurchasedProduct(product, list_id: list_id)
                    case .failure(let error): self.delegate?.showIAPRelatedError(error)
                    }
                }
            }
        }

        
        return true
    }
    
    
    func restorePurchases() {
        delegate?.willStartLongProcess()
        IAPManager.shared.restorePurchases { (result) in
            DispatchQueue.main.async {
                self.delegate?.didFinishLongProcess()

                switch result {
                case .success(let success):
                    if success {
                        self.restoreUnlockedLogos()
                        self.delegate?.didFinishRestoringPurchasedProducts()
                    } else {
                        self.delegate?.didFinishRestoringPurchasesWithZeroProducts()
                    }

                case .failure(let error): self.delegate?.showIAPRelatedError(error)
                }
            }
        }
    }
}
