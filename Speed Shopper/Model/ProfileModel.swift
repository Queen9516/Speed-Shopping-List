//
//  ProfileModel.swift
//  Speed Shopping List
//
//  Created by mac on 18/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import ObjectMapper

struct ProfileModel: Mappable {
    var id : String?
    var name : String?
    var email : String?
    var contact : String?
    var contact_verify : String?
    var password : String?
    var token : String?
    var profile_pic : String?
    var device_id : String?
    var device_type : String?
    var status : String?
    var created_at : String?
    var path : String?
    var balance : String?
    
    init?(map: Map) {}
    init() {}
    mutating func mapping(map: Map) {
        id                   <- map["id"]
        name                 <- map["name"]
        email                <- map["email"]
        contact              <- map["contact"]
        contact_verify       <- map["contact_verify"]
        password             <- map["password"]
        token                <- map["token"]
        profile_pic          <- map["profile_pic"]
        device_id            <- map["device_id"]
        device_type          <- map["device_type"]
        status               <- map["status"]
        created_at           <- map["created_at"]
        path                 <- map["path"]
        balance                 <- map["balance"]
    }
}
