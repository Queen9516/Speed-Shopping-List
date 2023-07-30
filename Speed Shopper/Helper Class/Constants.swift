//
//  Constants.swift
//  Speed Shopping List
//
//  Created by mac on 11/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import UIKit

struct MainClass {
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    static let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//    static let token = SharedPreference.getUserData().token!
}

struct UseCaseMessage {
    struct Empty {
        static let Email = "Please enter valid email"
        static let Password = "Please enter valid password"
        static let Phone = "Please enter valid phone number"
        static let Name = "Please enter Name"
        static let shoppingListName = "Shopping list name can't be blank"
         static let ItemLocation = "Please enter adress"
        static let TokenMessage = "User data can not be accessed from the database at the moment "
    }
    
    struct InValid {
        static let Email = "Please enter valid email"
        static let Password = "Please enter valid password, password is too short , it should be minimum 6 digits"
        static let Contact = "Please enter Valid contact number"
        
    }
    
    struct NotAvailable {
        static let camera = "oops! Camera not available"
        static let gallery = "oops! Gallery not available"
    }
    
    struct Purchase {
        static let premium = "premium_member"
    }
}

struct AppColor {
    static let blueColor = "2D2884"
    static let blackColor = "2B2A2A"
    static let lightGray = "c6c6c7"
}
