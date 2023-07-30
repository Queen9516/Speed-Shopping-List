//
//  StoreModel.swift
//  Speed Shopping List
//
//  Created by mac on 19/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import ObjectMapper

struct StoreModel : Mappable {
    init?(map: Map) {}
    init() {}
    /*
     "id": "4",
     "name": "Vishal Mega Mart",
     "logo": "35bd088700c1e5b693f2efb84771c1d3.jpg",
     "address": "Mhow Naka Circle, Balda Colony, Indore, Madhya Pradesh",
     "latitude": "22.705446",
     "longitude": "75.843617",
     "distance": "1.90",
     "path": "http://192.168.sstx_1.120/SSTX/public/images/store/"
     */
    var id : String?
    var name : String?
    var logo : String?
    var address : String?
    var latitude : String?
    var longitude : String?
    var distance : String?
    var path : String?
    
    mutating func mapping(map: Map) {
        id            <- map["id"]
        name          <- map["name"]
        logo          <- map["logo"]
        address       <- map["address"]
        latitude      <- map["latitude"]
        longitude     <- map["longitude"]
        distance      <- map["distance"]
        path          <- map["path"]
    }
}

struct ShoppingListModel : Mappable {
    /*"id": "69",
     "name": "jnbhnb hjn hjntesrr",
     "store_name": "Ritika Store",
     "store_id": "8",
     "address": "Tower 61, In front of mata gujari  girls college, indore"*/
    var id : String?
    var name : String?
    var image : String?
    var store_name: String?
    var store_id: String?
    var address : String?
    var item_count: String?
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        id          <- map["id"]
        name        <- map["name"]
        image       <- map["image"]
        store_name  <- map["store_name"]
        store_id    <- map["store_id"]
        address     <- map["address"]
        item_count  <- map["item_count"]
       
    }    
}

struct StoreLogoListModel : Mappable {
    var image_name : String?
    var image_id : String?
    var update_time : String?
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        image_name        <- map["image_name"]
        image_id          <- map["id"]
        update_time       <- map["upload_time"]
    }
}

struct ShoppingModel : Mappable {
    
//    "id": "4",
//    "name": "Vishal Mega Mart",
//    "logo": "35bd088700c1e5b693f2efb84771c1d3.jpg",
//    "path": "http://192.168.1.120/SSTX/public/images/store/",
//    "unused": "26"
    var id: String?
    var name: String?
    var logo: String?
    var path: String?
    var unused: String?
    
    init?(map: Map) {}
    init() {}

   mutating func mapping(map: Map) {
    id     <- map["id"]
    name   <- map["name"]
    logo   <- map["logo"]
    path   <- map["path"]
    unused   <- map["unused"]
}
}

struct ShoppingModelAddToGoogleSearch : Mappable {
    
   /*
    "id": "32",
    "name": "Ritika Store",
    "logo": "",
    "address": "Tower 61, In front of mata gujari  girls college, indore",
    "latitude": "22.685422",
    "longitude": "75.614271",
    "path": "http://192.168.1.120/SSTX/public/images/store/"
    */
    
    var id: String?
    var name: String?
    var logo: String?
    var path: String?
    var address: String?
    var latitude: String?
    var longitude: String?

    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        id     <- map["id"]
        name   <- map["name"]
        logo   <- map["logo"]
        path   <- map["path"]
        address <- map["address"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
    }
}

struct ShareModel: Mappable {
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
 
    }
}


struct ShoppingListItemModel : Mappable {
    /*"id": "3",
     "item_id": "4",
     "name": "Meat",
     "status": "0",
     "location": ""*/
    var unpurchased: [ShoppingItems]?
    var purchased:  [ShoppingItems]?
    init?(map: Map) {}
    init() {}
    mutating func mapping(map: Map) {
        
        unpurchased    <- map["unpurchased"]
        purchased      <- map["purchased"]
    }
}

struct ShoppingItems: Mappable {
    var id : String?
    var item_id : String?
    var name: String?
    var image: String?
    var quantity: String?
    var unit_price: String?
    var status: String?
    var location : String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id             <- map["id"]
        item_id        <- map["item_id"]
        name           <- map["name"]
        image          <- map["image"]
        quantity       <- map["quantity"]
        unit_price     <- map["unit_price"]
        status         <- map["status"]
        location       <- map["location"]
    }
    
}

struct StoreItemModel : Mappable {
      var id : String?
      var name: String?
     init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        id             <- map["id"]
        name        <- map["name"]
    }

}

struct ContactModel : Mappable {
    var message: String?
     init?(map: Map) {}
    
    mutating func mapping(map: Map) {
       message  <- map["message"]
    }
}
struct FAQListModel : Mappable {
    var question: String?
    var answer: String?
    var image: String?
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
      question     <- map["question"]
      answer       <- map["answer"]
      image       <- map["image"]
    }
}



struct SpeedShopperMarketModel : Mappable {
    var store_id: String?
    var store_name: String?
    var address: String?
    var profile_pic: String?
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        store_id        <- map["store_id"]
        store_name      <- map["store_name"]
        address         <- map["address"]
        profile_pic     <- map["profile_pic"]
        
    }
}

struct ProductModel : Mappable {
    
    /*"store_id": "1",
     "store_name": "Hemant",
     "address": "qwerty",
     "product_name": "New P",
     "price": "30",
     "description": "Hello this is test prduct",
     "product_id": "5",
     "product_image": "afe3a9f1a4454ac8d916da9ee3849f4d.jpeg",
     "path": "http://192.168.1.137/SSTX/public/images/store/"*/
    
    var store_id: String?
    var store_name: String?
    var address: String?
    var product_name : String?
    var price : String?
    var description : String?
    var product_id : String?
    var product_image : String?
    var path : String?
    var discount : String?
    var website : String?
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        store_id        <- map["store_id"]
        store_name      <- map["store_name"]
        address         <- map["address"]
        product_name    <- map["product_name"]
        price           <- map["price"]
        description     <- map["description"]
        product_id      <- map["product_id"]
        product_image   <- map["product_image"]
        path            <- map["path"]
        website         <- map["website"]
        discount        <- map["discount"]
    }
}

struct AdvertisementListModel: Mappable {
   
    var name: String?
    var image : String?
    var item_id: String?
    var adv_id: String?
    var adv_link: String?
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        name         <- map["name"]
        image        <- map["image"]
        item_id      <- map["item_id"]
        adv_link     <- map["adv_link"]
        adv_id       <- map["adv_id"]
    }
}

struct BuyListModel: Mappable {
    var id: String?
    var merchant_id: String?
    var store: String?
    var coupon_code : String?
    var product_name : String?
    var price : String?
    var product_image : String?
    var path : String?
    var user_name: String?
    var website : String?
    
    init?(map: Map) {}
    init() {}
    
    mutating func mapping(map: Map) {
        id                  <- map["id"]
        merchant_id         <- map["merchant_id"]
        store               <- map["store"]
        coupon_code         <- map["coupon_code"]
        product_name        <- map["product_name"]
        price               <- map["price"]
        product_image       <- map["product_image"]
        path                <- map["path"]
        user_name           <- map["user_name"]
        website             <- map["website"]
    }
}

struct EZListModel : Mappable {
    init?(map: Map) {}
    init() {}
    /*
     "id": "4",
     "name": "Vishal Mega Mart",
     "logo": "35bd088700c1e5b693f2efb84771c1d3.jpg",
     "address": "Mhow Naka Circle, Balda Colony, Indore, Madhya Pradesh",
     "latitude": "22.705446",
     "longitude": "75.843617",
     "distance": "1.90",
     "path": "http://192.168.sstx_1.120/SSTX/public/images/store/"
     */
    var id : String?
    var title : String?
    var description : String?
    var image : String?
    
    mutating func mapping(map: Map) {
        id            <- map["id"]
        title         <- map["title"]
        description   <- map["description"]
        image         <- map["image"]
    }
}
