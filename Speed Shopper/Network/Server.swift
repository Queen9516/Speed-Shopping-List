//
//  Server.swift
//  IRIS
//
//  Created by user on 21/8/2017.
//  Copyright © Ajayy infograins. All rights reserved.
//
protocol ServerType {
    var isProduction: Bool {get}
    var hostName: String {get}
    var domain: String {get}
    var fileDirectory: String {get}
    var baseURL: String {get}
    var postURL: String {get}
    var path: String {get}
}
private enum DevelopmentType{
    case sandBox
    case production
}
class ServerManager {
    fileprivate var developmentType: DevelopmentType
    var clientServer: ServerType
    class var sharedManager:ServerManager{
        
//        return ServerManager(developmentType: .sandBox, clientServer: ServerManager.createClientServerForEnviroment(.sandBox))
       return ServerManager(developmentType: .production, clientServer: ServerManager.createClientServerForEnviroment(.production))
    }
    fileprivate init(developmentType: DevelopmentType, clientServer: ServerType) {
        self.developmentType = developmentType
        self.clientServer = clientServer
    }
    static fileprivate func createClientServerForEnviroment(_ developmentType: DevelopmentType) -> ServerType{
        let isProductionServer = (developmentType == .production) ? (true) : (false);
        let hostName =  (isProductionServer) ? (ServerConstants.clientPoductionServer.HostName) :  (ServerConstants.clientSandBoxServer.HostName)
        let domain =  (isProductionServer) ? (ServerConstants.clientPoductionServer.Domain) :  (ServerConstants.clientSandBoxServer.Domain)
        let fileDirectory = (isProductionServer) ? (ServerConstants.clientPoductionServer.fileDirectory) :  (ServerConstants.clientSandBoxServer.fileDirectory)
        let postURL  = (isProductionServer) ? (ServerConstants.clientPoductionServer.postDirectory) :  (ServerConstants.clientSandBoxServer.postDirectory)
        let server = Server(isProduction:isProductionServer, hostName: hostName, domain: domain,  fileDirectory: fileDirectory, postURL: postURL)
        return server
    }
}
struct Server: ServerType {
    var isProduction: Bool
    var hostName: String
    var domain: String
    var path: String {
        return self.baseURL + self.postURL
    }
    var fileDirectory: String
    var postURL: String
    
    var baseURL: String {
        return self.hostName
    }
}
struct ServerConstants {
    struct defaults{
        static var businessServiceIconsfileDirectory: String{
            return "/INFO01/bingu/uploads/services_icon/";
        }
        static var businessBranchImagesfileDirectory: String{
            return "/INFO01/bingu/uploads/branch_images/";
        }
        static var businessProfileImagesfileDirectory: String{
            return "/INFO01/bingu/uploads/owner_images/";
        }
        static var businessOwnerImagesfileDirectory: String{
            return "/INFO01/bingu/uploads/business_images/";
        }
    }
    fileprivate struct clientSandBoxServer{
        
        static  var HostName:String {
           return "http://192.168.1.120/SSTX/api/"
           // return "https://infograins.in/INFO01/SSTX/api/"
        }
        static var Domain: String{
           return "http://192.168.1.120/SSTX/api/"
          // return "https://infograins.in/INFO01/SSTX/api/"
        }
        static var fileDirectory: String{
            return "/INFO01/bingu/uploads/owner_images/";
        }
        static var postDirectory: String{
            return ""
        }
    }
    fileprivate struct clientPoductionServer{
        
        static  var HostName:String {
          //   return "http://192.168.1.120/SSTX/api/"
          //   return "https://infograins.in/INFO01/SSTX/api/"
             return "https://www.speedshopperapp.com/app/api/"
             //  return "https://www.speedshopperapp.com/app_sandbox/api/"
            
        }
        static  var Domain: String{
        //    return "http://192.168.1.120/SSTX/api/"
        //    return "https://infograins.in/INFO01/SSTX/api/"
            return "https://www.speedshopperapp.com/app/api/"
             // return "https://www.speedshopperapp.com/app_sandbox/api/"
        }
        static var fileDirectory: String{
            return "/INFO01/bingu/uploads/owner_images/";
        }
        
        static var postDirectory: String{
            return ""
        }
    }
}
