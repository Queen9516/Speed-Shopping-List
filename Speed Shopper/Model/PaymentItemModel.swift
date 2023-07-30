//
//  PaymentItemModel.swift
//  Speed Shopping List
//
//  Created by info on 20/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

public struct Item {
    var name : String
    var detail: String
    
    public init(name: String, detail: String) {
        self.name = name
        self.detail = detail
    }
}
public struct Section {
    var name: String
    var items: [Item]
    var collapsed: Bool
    
    public init(name: String, items: [Item], collapsed: Bool = false) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }
}
public var sectionsData: [Section] = [
    Section(name: "12 Mar,2018", items: [
        Item(name:"Buy Big bazar coupan code", detail:"$500" ),
        Item(name: "Buy Big bazar coupan code", detail: "$500"),
        Item(name: "Buy Big bazar coupan code", detail: "$500"),
        Item(name: "Buy Big bazar coupan code", detail: "$500"),
        Item(name: "Buy Big bazar coupan code", detail: "$500")
        ]),
    Section(name: "12 Mar,2018", items: [
        Item(name:"Buy Big bazar coupan code", detail:"$500" ),
        Item(name: "Buy Big bazar coupan code", detail: "$500"),
        Item(name: "Buy Big bazar coupan code", detail: "$500"),
        Item(name: "Buy Big bazar coupan code", detail: "$500"),
        Item(name: "Buy Big bazar coupan code", detail: "$500")
        ]),
    Section(name: "12 Mar,2018", items: [
        Item(name:"Buy Big bazar coupan code", detail:"$500" ),
        Item(name: "Buy Big bazar coupan code", detail: "$500"),
        Item(name: "Buy Big bazar coupan code", detail: "$500"),
        Item(name: "Buy Big bazar coupan code", detail: "$500"),
        Item(name: "Buy Big bazar coupan code", detail: "$500")
        ]),
]






