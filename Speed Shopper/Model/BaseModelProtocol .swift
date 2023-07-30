//
//  BaseModelProtocol.swift
//  Speed Shopper
//
//  Created by mac on 13/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import ObjectMapper

protocol BaseModelProtocol: Mappable {
    associatedtype Object
    var success : Any? {get set}
    var msg : String? {get set}
    var object : Object? {get set}
}

struct UniversalModel: Mappable {
    var success : Any?
    var msg : String?
    var dictype : [String : String]?
    
    var isSuccess: Bool{
        guard let status = self.success else{
            return false
        }
        let statusInt = status as! Int
        if statusInt == 200 {
            return true
        }else {
            return false
        }
    }
    init?(map: Map) {}
    init() {}
    mutating func mapping(map: Map) {
        success       <- map["status"]
        msg           <- map["message"]
        dictype       <- map["data"]
    }
}
struct BaseModel<T: Mappable> : BaseModelProtocol {
    var success: Any?
    var msg: String?
    var object: T?
    var isSuccess : Bool{
        guard let status = self.success else{
            return false
        }
        let statusInt = status as! Int
        if statusInt == 200 {
            return true
        }
        else {
            return false
        }
    }
    var isVerify: Bool {
        guard let str2 = self.success else{return false}
        if "\(str2)" == "400" {
            return true
        }else{
            return false
        }
    }
    
    init?(map: Map) {}
    init() {}
    mutating func mapping(map: Map) {
        success       <- map["status"]
        msg           <- map["message"]
        object        <- map["data"]
    }
}

struct BaseListModel<T: Mappable>: BaseModelProtocol {
    var success: Any?
    var msg: String?
    var object: [T]?
    
    init(){}
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        success     <- map["status"]
        msg         <- map["message"]
        object      <- map["data"]
    }
    
    var isSuccess: Bool {
        guard let status = self.success else{
            return false
        }
        let statusInt = status as! Int
        if statusInt == 200 {
            return true
        }
        else {
            return false
        }
    }
    var isVerify: Bool {
        guard let str2 = self.success else{return false}
        if "\(str2)" == "400" {
            return true
        }else {
            return false
        }
    }
}
