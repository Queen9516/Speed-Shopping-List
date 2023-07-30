//
//  Model.swift
//  Speed Shopping List
//
//  Created by Wang on 11/30/20.
//  Copyright © 2020 mac. All rights reserved.
//

import Foundation
import StoreKit

class Model {
    
    struct AppData: Codable, SettingsManageable {
        
        var didUnlockStoreLogos = false
    }
    
    var appData = AppData()
    
    var products = [SKProduct]()
    
    
    init() {
        _ = appData.load()
    }
    
    
    func getProduct(containing keyword: String) -> SKProduct? {
        print("IAP PRODUCTS", products.count)
        let product =  products.filter { $0.productIdentifier.contains(keyword) }.first
        print("Purchase Item :-->", product as Any)
        return product
    }
}
