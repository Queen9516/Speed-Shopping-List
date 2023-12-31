//
//  ApiConstant.swift
//  Speed Shopping List
//
//  Created by mac on 13/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
struct ApiConstant {
    static let kDeviceType = "ios"
    struct ApiType {
        static let kAccount = "account/"
        static let kStore = "store/"
        static let kShopping = "shopping/"
        static let kGuest = "Guestcommon/"
        static let kWallet = "wallet/"
        static let kComman = "common/"
        static let kSpeedShopperMarket = "speed_shopper_market/"
        static let kEZLists = "ez_lists/"
        static let kTransaction = "transaction/"
    }
    struct ApiAction {
        
        static let kGuestLogin = "guestregister"
        static let kLogin = "login"
        static let kSignup = "register"
        static let kForgotPassword = "forget"
        static let kGetProfile = "getUser/"
        static let kGetReward  = "getReward"
        static let kChangePasword = "changePassword"
        static let kUpdateProfile = "update"
        static let kDeleteAccount = "delete"
        static let kPhoneVerify = "phoneVerify"
        static let kEmailVerify = "messageVerify"
        static let kMobileVerifyOTP = "verifyMobileOTP"
        static let kLogout = "logout"
        static let kGetStores = "getStores/"
        static let kShoppingList = "shoppingList/"
        static let kShoppingListGuest = "shoppingList"

        static let kImportItem = "importItem/"
        static let kAddShoppingList = "addShoppingList/"
        static let kStoreItems = "storeItems/"
        static let KshoppingListItem = "shoppingListItem/"
        static let kshareShoppingList = "shareShoppingList/"
        static let kshareShoppingListUdate = "shareShoppingListUpdate/"
        static let kAddItemToShoppingList = "addItemToShoppingListNew/"
        static let kRemoveAllItem = "removeAllItem/"
        static let kRemoveItemImage = "removeItemImage/"
        static let kRemoveCheckedItem = "removeCheckedItem/"
        static let kRemoveShoppingList = "removeShoppingList/"
        static let kUpdateShoppingListName = "updateShoppingListName/"
        static let kUpdateShoppingListLogo = "updateShoppingListLogo/"
        static let kAddItemLocation = "addItemLocation/"
        static let kAddItemLocationPro = "addItemLocationPro/"
        static let kUpdateItemLocation = "updateItemLocation/"
        static let kUpdateItemLocationPro = "updateItemLocationPro/"
        static let kUpdateItemQuantity = "updateItemQuantity/"
        static let kGetSSTXVal = "getSSTXValue/"
        static let kPurchaseItem = "purchaseItemNew/"
        static let kShoppingHistoryStore = "shoppingHistoryStore/"
        static let kGetWallet = "getWallet/"
        static let kfacebookLogin = "facebookLogin?"
        static let kAdd =  "add/"
        static let kLocation =  "locations/"
        static let kContact = "contact/"
        static let kFaq = "faq/"
        static let kGetSpeedShopperMarket = "getSpeedShopperMarket/"
        static let KGetEZLists = "getEz_list/"
        static let KAddItemToEZLists = "addItemToMyLists/"
        static let kIncreaseAdsCount = "advertisement_increase_click_count/"
        static let kGetProductByMerchant = "getProductByMerchantID/"
        static let kbuy =  "buy/"
        static let kadvertisement = "advertisement_list_by_store_id/"
        static let kbuyList = "buy_list/"
        static let kTransactionHistory = "transaction_history/"
        static let kNotifications = "notifications/"
        static let kMessages = "messages/"
        static let kGetLogos = "logos/"
    }
    struct ApiKey {
        static let kfacebook_id = "facebook_id"
        static let kEmail = "email"
        static let kPassword = "password"
        static let kDeviceId = "device_id"
        static let kDeviceType = "device_type"
        static let kPush_id = "push_id"
        static let kName = "name"
        static let kContact = "contact"
        static let kMobile = "mobile"
        static let kToken = "token"
        static let kProfilePic = "profile_pic"
        static let kLatitude = "latitude"
        static let kLongitude = "longitude"
        static let kStoreId = "store_id"
        static let kAdsId = "ads_id"
        static let kListId =  "list_id"
        static let kSharingToken = "sharing_token"
        static let kItem =  "item"
        static let kItemId = "item_id"
        static let kId = "id"
        static let kPrice  = "unit_price"
        static let kItemQuantity = "quantity"
        static let kItemImage = "item_pic"
        static let kPurchase = "purchase"
        static let kLocation = "location"
        static let kAddress = "address"
        static let kCurrentLatitude = "user_latitude"
        static let kCurrentLongitude = "user_longitude"
        static let kMessage = "message"
        static let kpage  = "page"
        static let kproductId  = "product_id"
        static let kuserId  = "user_id"
        static let kmerchant_id  = "merchant_id"
        static let kkey =  "key"
        static let kPremium = "premium"
        static let kEZListId = "ez_list_id"
        static let kMyListId = "my_list_id"
        
        static let kCity = "city"
        static let kCountry = "country"
        static let kState = "state"
        static let kZipCode = "zipcode"
        static let kDistance = "distance"
        
        static let KloginType = "login_type"
        static let kImage = "image"
    
    }
}
