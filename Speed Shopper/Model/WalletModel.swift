//
//  WalletModel.swift
//  Speed Shopping List
//
//  Created by mac on 28/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

/*"ethToken": null,
"ethBalance": null */

import Foundation
import ObjectMapper

struct WalletModel : Mappable {
    
    var ethBalance : Any?
    var ethToken : Any?
    var address : String?
    var privateAd: String?
    
    init?(map: Map) {}
    init() {}
    mutating func mapping(map: Map) {
        ethBalance         <- map["ethBalance"]
        ethToken           <- map["ethToken"]
        address            <- map["address"]
        privateAd          <- map["private_address"]
    }
}

/*"id": "2",
"sender_id": "1",
"receiver_id": "1",
"type": "2",
"quantity": "10",
"description": "Product Purchase",
"status": "1",
"created_at": "2018-05-30 11:58:27"*/

struct HistoryListModel: Mappable {
    init?(map: Map) {}
    init(){}
    
    var id : String?
    var sender_id : String?
    var receiver_id : String?
    var type : String?
    var quantity : String?
    var description : String?
    var status : String?
    var created_at : String?
    
    
    mutating func mapping(map: Map) {
        id                  <- map["id"]
        sender_id           <- map["sender_id"]
        receiver_id         <- map["receiver_id"]
        type                <- map["type"]
        quantity            <- map["quantity"]
        description         <- map["description"]
        status              <- map["status"]
        created_at          <- map["created_at"]
    }
}


/*"title": "Test",
"message": "Test by hemant",
"type": "copoun",
"created_at": "2018-06-27 12:57:40"*/


struct NotificationListModel: Mappable {
    init?(map: Map) {}
    init(){}
    
    var title : String?
    var message : String?
    var type : String?
    var created_at : String?

    mutating func mapping(map: Map) {
        title        <- map["title"]
        message      <- map["message"]
        type         <- map["type"]
        created_at   <- map["created_at"]
    }
}

struct MessageListModel: Mappable {
    init?(map: Map) {}
    init(){}
    
    var title : String?
    var message : String?
    var created_at : String?

    mutating func mapping(map: Map) {
        title             <- map["title"]
        message           <- map["message"]
        created_at        <- map["created_at"]
    }
}



