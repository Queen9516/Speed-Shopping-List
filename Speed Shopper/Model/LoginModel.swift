//
//  File.swift
//  Speed Shopping List
//
//  Created by mac on 13/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import ObjectMapper

struct LoginModel : Mappable {
    var userID: Any!
    var userName: String!
    var profileImageUrl: String!
    var mobile: String!
    var email: String!
    var emailVerify: String!
    var contactVerify: String!
    var token: String!
    var userToken: String!
    var path: String!
    var profile_pic: String!
    var device_id: String!
    var device_type: String!
    var contact: String!
    var otp: String!
    
    init?(map: Map) {
        
    }
    
    init() {
    }
        var id: String? {
            guard let id = self.userID
                else{return nil}
            return "\(id)"
        }
    
//    id": "12",
//    "name": "Hemant",
//    "email": "hemant121483@yopmail.com",
//    "email_verify": "0",
//    "contact": "1256127890",
//    "contact_verify": "0",
//    "profile_pic": "",
//    "token": "201804141156560000005ad19f30f3534DpUnumlRdLNti6SohB1Gb5yws3rPcITM"
    
    mutating func mapping(map: Map) {
        userID                  <-  map["id"]
        userName                <-  map["name"]
        email                   <-  map["email"]
        mobile                  <-  map["contact"]
        profileImageUrl         <-  map["profile_pic"]
        emailVerify             <-  map["email_verify"]
        contactVerify           <-  map["contact_verify"]
        token                   <-  map["token"]
        userToken               <-  map["user_token"]
        path                    <- map["path"]
        profile_pic             <- map["profile_pic"]
        device_id               <- map["device_id"]
        device_type             <- map["device_type"]
        contact                 <- map["contact"]
        otp                     <- map["smsCode"]
    }
}
