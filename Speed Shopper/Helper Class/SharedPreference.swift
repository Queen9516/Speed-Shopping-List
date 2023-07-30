//
//  SharedPreference.swift
//  Speed Shopping List
//
//  Created by info on 14/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import ObjectMapper

class SharedPreference: NSObject {
    fileprivate let kAdsShowCounter = "ads_show_counter"
    fileprivate let kUserID = "__u_id"
    fileprivate let kUserToken = "__token_"
    fileprivate let kUserType = "__user_type"
    fileprivate let kIsActive = "__is_active"
    fileprivate let kFullName = "__fullName"
    fileprivate let kCity = "__city"
    fileprivate let kEmail = "__email"
    fileprivate let kPhone = "__phone"
    fileprivate let kImage = "__imagr"
    fileprivate let kLanguage = "__language"
    fileprivate let kCurrentLocationLat = "__currentLat"
    fileprivate let kCurrentLocationLong = "__currentLong"
    fileprivate let kDeviceToken = "__deviceToken"
    fileprivate let kIsBusy = "--isBusy"
    fileprivate let kNotificationData = "__notificationData___"
    fileprivate let kemailVerify = "__emailverify"
    fileprivate let kcontactVerify = "__contactVerify"
    fileprivate let kprofilePic = "profile_pic"
    fileprivate let kpath = "path"
    fileprivate let kname = "name"
    fileprivate let KId = "id"
    
    fileprivate let KStoreId = "id"
    fileprivate let KStoreName = "name"
    fileprivate let KGuest = "guestLogin"
    fileprivate let KGuestShoppingList = "guestShoppingList"

    fileprivate let defaults = UserDefaults.standard
    fileprivate let KSetRadius = "__setRadius"
    fileprivate let kSharetoken = "__shareToken"
    fileprivate let kOnesignal_id = "__pushId"
    
    static let sharedInstance = SharedPreference()
    
    class func saveUserData(user:LoginModel){
        sharedInstance.saveUserData(user)
    }
    
    class func saveStoreData(user: StoreModel) {
        sharedInstance.saveStoreData(user)
    }
    
    class func increaseAdsCounterAndGet() -> Int{
        return sharedInstance.increaseAdsCounterAndGet()
    }
    
    class func saveShoppingList(user: ShoppingListModel) {
        sharedInstance.saveShoppingList(user)
    }
    
    class func saveGuestLogin(isguest: Bool) {
        sharedInstance.saveGuestData(isguest)
    }
    
    class func saveGuestShoppingList(list:[Any]) {
        sharedInstance.saveGuestShoppingListData(list)
    }
    
    fileprivate func saveUserData(_ user: LoginModel){
           defaults.setValue(user.userID , forKey: kUserID)
           defaults.setValue(user.token, forKey: kUserToken)
        // defaults.setValue(user.userType, forKey: kUserType)
        //  defaults.setValue(user.is_active, forKey: kIsActive)
            defaults.setValue(user.userName, forKey: kFullName)
            defaults.setValue(user.email, forKey: kEmail)
            defaults.setValue(user.mobile, forKey: kPhone)
            defaults.setValue(user.emailVerify, forKey: kemailVerify)
            defaults.setValue(user.contactVerify, forKey: kcontactVerify)
            defaults.setValue(user.path, forKey: kpath)
            defaults.setValue(user.profile_pic, forKey: kprofilePic)
            defaults.synchronize()
    }
    
    fileprivate func increaseAdsCounterAndGet() -> Int {
        var adsCounter = defaults.value(forKey: kAdsShowCounter) as? Int ?? 0
        adsCounter = (adsCounter + 1) % 5
        defaults.setValue(adsCounter , forKey: kAdsShowCounter)
        defaults.synchronize()
        return adsCounter
    }
    
    //Mark: StoreDataModel Data
    fileprivate func saveStoreData(_ user: StoreModel){
       defaults.setValue(user.id, forKey: KStoreId)
        defaults.setValue(user.name, forKey: KStoreName)
    }
    
    //Mark: StoreDataModel Data
    fileprivate func saveGuestData(_ isGuest: Bool){
        defaults.set(isGuest, forKey: KGuest)
    }
    
    fileprivate func saveGuestShoppingListData(_ list: [Any]){
        defaults.set(list, forKey: KGuestShoppingList)
    }
    
    
    fileprivate func saveShoppingList(_ user: ShoppingListModel){
         defaults.setValue(user.name, forKey: kname)
         defaults.setValue(user.id, forKey: KId)
    }
    
    fileprivate func deleteUserData(){
        defaults.removeObject(forKey: kUserID)
        //        defaults.removeObject(forKey: kUserToken)
        //        defaults.removeObject(forKey: kUserType)
        //        defaults.removeObject(forKey: kIsActive)
        //        defaults.removeObject(forKey: kFullName)
        //        defaults.removeObject(forKey: kEmail)
        defaults.synchronize()
    }
    
    class func savePushId(_ push_id: String) {
        sharedInstance.storePushId(push_id)
    }
    
    class func PushId() -> String {
        return sharedInstance.getPushId()
    }
    
    fileprivate func storePushId(_ push_id: String) {
        defaults.set(push_id, forKey: kOnesignal_id);
    }
    
    fileprivate func getPushId() -> String {
        return defaults.value(forKey: kOnesignal_id) as? String ?? ""
    }
    
    class func clearUserData(){
        sharedInstance.clearUserData()
    }
    
    fileprivate func clearUserData(){
        self.deleteUserData()
    }
    
    class func getUserData() -> LoginModel{
        return sharedInstance.getUserData()
    }
    class func getStoreData() -> StoreModel {
        return sharedInstance.getStoreData()
    }
    
    class func getGuestData() -> Bool {
           return sharedInstance.getGuestData()
    }
    
    class func getGuestShoppingList() -> [Any] {
           return sharedInstance.getStoreShoppingList()
    }
    
    
    fileprivate  func getUserData() -> LoginModel {
        var user:LoginModel  = LoginModel()
        user.userID        = defaults.value(forKey: kUserID)  as? String
        //        user.userType       = defaults.value(forKey: kUserType) as? String
        user.token          = defaults.value(forKey: kUserToken) as? String
        //        user.is_active      = defaults.value(forKey: kIsActive) as? String
        user.userName       = defaults.value(forKey: kFullName) as? String
        //        user.emailPhone     = defaults.value(forKey: kEmail) as? String
        user.emailVerify = defaults.value(forKey: kemailVerify) as? String
        user.path        = defaults.value(forKey: kpath) as? String
        user.profile_pic = defaults.value(forKey: kprofilePic) as? String
        
        return user
    }
    fileprivate func getStoreData() -> StoreModel {
        var user:StoreModel = StoreModel()
        user.id = defaults.value(forKey: KStoreId) as? String
        user.name = defaults.value(forKey: KStoreName) as? String
        return user
    }
    
    fileprivate func getStoreShoppingList() -> [Any] {
        return  defaults.array(forKey: KGuestShoppingList) ?? []
    }
    
    
    fileprivate func getGuestData() -> Bool {
        return  defaults.bool(forKey: KGuest)
    }
    
    func setCurrentLocation(lat: Double, long: Double){
        
        defaults.set(lat, forKey: kCurrentLocationLat)
        defaults.set(long, forKey: kCurrentLocationLong)
        //(latitude: 22.67558239277778, longitude: 76.020274646580219)

        defaults.set("\(lat)", forKey: kCurrentLocationLat)
        defaults.set("\(long)", forKey: kCurrentLocationLong)
        defaults.synchronize()
    }
    class func getCurrentLocation() -> (lat: Double, long: Double) {
        return  sharedInstance.getCurrent()
    }
    func getCurrent() -> (lat: Double, long: Double){
        return (defaults.double(forKey: kCurrentLocationLat),  defaults.double(forKey: kCurrentLocationLong))
    }
    
    class func getCurrentUserLocation_inStr() -> (lat: String, long: String) {
        return  sharedInstance.getCurrentUser()
    }
    
    func getCurrentUser() -> (lat: String, long: String){
        return (defaults.string(forKey: kCurrentLocationLat)!,  defaults.string(forKey: kCurrentLocationLong)!)
    }
    
    class func storeDeviceToken(_ token: String) {
        sharedInstance.setDeviceToken(token)
    }
    class func deviceToken() -> String {
        return sharedInstance.getDeviceToken() ?? "1234567890"
    }
    class func saveSharetoken(_ token : String) {
        sharedInstance.storeShareToken(token)
    }
    class func shareToken() -> String {
        return sharedInstance.getShareToken() ?? "0987654321"
    }
    
    fileprivate func setDeviceToken(_ token: String){
        defaults.set(token, forKey: kDeviceToken);
    }
    
    fileprivate func storeShareToken(_ token: String) {
        defaults.set(token, forKey: kSharetoken)
    }
    
    fileprivate func getShareToken()->String? {
        return defaults.value(forKey: kSharetoken) as? String
    }
    
    fileprivate func getDeviceToken() -> String?{
        return defaults.value(forKey: kDeviceToken) as? String
    }
    func saveNotificationData(notificationDict : NSDictionary) {
        defaults.set(notificationDict, forKey: kNotificationData)
    }
    
    func getNotificationData() -> NSDictionary{
        if (defaults.value(forKey: kNotificationData) != nil){
            return (defaults.value(forKey: kNotificationData) as? NSDictionary)!
        }else{
            return NSDictionary()
        }
    }
    //MARK:- Save SetRadius in Double
    class func saveSetRadius(double: Double) {
        sharedInstance.setRadius(double)
    }
    fileprivate func setRadius(_ double: Double) {
        defaults.set(double, forKey: KSetRadius)
    }
    class func getRadius() -> Double {
        return sharedInstance.getRadiusFun()
    }
    fileprivate func getRadiusFun() -> Double  {
        return defaults.value(forKey: KSetRadius) as? Double ?? 5
    }
    class func clearRadius(){
        sharedInstance.clearRadius()
    }
    fileprivate func clearRadius(){
        self.deleteSetRadius()
    }
    fileprivate func deleteSetRadius(){
        defaults.removeObject(forKey: KSetRadius)
    }
}
