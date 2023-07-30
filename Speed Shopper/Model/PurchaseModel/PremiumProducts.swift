//
//  PremiumProducts.swift
//  Speed Shopping List
//
//  Created by Wang on 3/12/21.
//  Copyright © 2021 mac. All rights reserved.
//

import Foundation

public struct PremiumProducts {
    public static let weeklySub = "premium_weekly"
    public static let monthlySub = "premium_monthly"
    public static let threeMonthsSub = "premium_3months"
    public static let sixMonthsSub = "premium_6months"
    public static let yearlySub = "premium_yearly"
    public static let store = PremiumIAPManager(productIDs: PremiumProducts.productIDs)
    private static let productIDs: Set<ProductID> = [PremiumProducts.yearlySub, PremiumProducts.monthlySub, PremiumProducts.weeklySub, PremiumProducts.threeMonthsSub, PremiumProducts.sixMonthsSub]
}

public func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}
