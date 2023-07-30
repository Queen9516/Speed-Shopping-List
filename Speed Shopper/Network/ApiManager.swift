                   //
//  ApiManager.swift
//  Speed Shopping List
//
//  Created by mac on 13/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import ObjectMapper

protocol WebServiceDelegate {
    func success_serverResponse(data: Any, actionStr : String)
    func error_serverResponse(data: Any, actionStr : String)
}

struct HeaderKey {
    static let x_api_key = "X-API-KEY"
    static let valXApiKey = "BCX_5AAF884F75F3F"
}

class Apimanager {
    
    var webServiceDelegate : WebServiceDelegate?
    
    static var sharedManager: Apimanager{
        struct wrapper {
            static let sharedManager = Apimanager()
        }
        return wrapper.sharedManager
    }
    
    lazy fileprivate var useDefaults : UserDefaults = {
        return UserDefaults.standard
    }()
    
    func callApiPostMethod(str_Action: String! , param : [String:Any]){
        var path = ServerManager.sharedManager.clientServer.path
        path += str_Action
        let request = NetworkRequestResource(path: path, method: .post, param: param)
        Network.networkRequest(request, showProgress: true) { (resultState) in
            switch resultState{
            case .success(let baseModel):
                self.webServiceDelegate?.success_serverResponse(data: baseModel, actionStr: str_Action)
                break
            case .failure(let baseModel):
                self.webServiceDelegate?.error_serverResponse(data: baseModel, actionStr: str_Action)
                break
            }
        }
    }
    func callApiPostMethod(str_Action: String! , param : [String:Any], showProgress: Bool){
        var path = ServerManager.sharedManager.clientServer.path
        path += str_Action
        let request = NetworkRequestResource(path: path, method: .post, param: param)
        Network.networkRequest(request, showProgress: showProgress) { (resultState) in
            switch resultState{
            case .success(let baseModel):
                self.webServiceDelegate?.success_serverResponse(data: baseModel, actionStr: str_Action)
                break
            case .failure(let baseModel):
                self.webServiceDelegate?.error_serverResponse(data: baseModel, actionStr: str_Action)
                break
            }
        }
    }
    
    func callApiPostMethodWithoutParam(str_Action: String!){
        var path = ServerManager.sharedManager.clientServer.path
        path += str_Action
        let param = [String: String]()
        let request = NetworkRequestResource(path: path, method: .post, param: param)
        Network.networkRequest(request, showProgress: true) { (resultState) in
            switch resultState{
            case .success(let baseModel):
                self.webServiceDelegate?.success_serverResponse(data: baseModel, actionStr: str_Action)
                break
            case .failure(let baseModel):
                self.webServiceDelegate?.error_serverResponse(data: baseModel, actionStr: str_Action)
                break
            }
        }
    }
    
    func callApiGetMethod(str_Action: String!){
        var path = ServerManager.sharedManager.clientServer.path
        path += str_Action
        let param = [String: String]()
        let request = NetworkRequestResource(path: path, method: .get, param: param)
        Network.networkRequest(request, showProgress: true) { (resultState) in
            switch resultState{
            case .success(let baseModel):
                self.webServiceDelegate?.success_serverResponse(data: baseModel, actionStr: str_Action)
                break
            case .failure(let baseModel):
                self.webServiceDelegate?.error_serverResponse(data: baseModel, actionStr: str_Action)
                break
            }
        }
    }
    
    func callAPIForUpload(dataDict: [String:Any], action:String!) {
        var path = ServerManager.sharedManager.clientServer.path
        path += action
        let request = NetworkRequestResource(path: path, method: .post, param: dataDict)
        Network.uploadData(request){
            (resultState) in
            switch resultState {
            case .success(let baseModel):
                self.webServiceDelegate?.success_serverResponse(data: baseModel, actionStr: action)
                break
            case .failure(let error):
                self.webServiceDelegate?.error_serverResponse(data: error, actionStr: action)
                break
            }
        }
    }
}
