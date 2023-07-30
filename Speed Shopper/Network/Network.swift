//
//  Network.swift
//  Speed Shopping List
//
//  Created by mac on 13/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import SystemConfiguration
import Alamofire
import UIKit

protocol NetworkRequestResourceType {
    var path: String {get}
    var method: Alamofire.HTTPMethod {get}
    var param: [String: Any] {get}
    var url:URL{get}
}

struct NetworkRequestResource: NetworkRequestResourceType {
    var path: String
    var method: Alamofire.HTTPMethod
    var param: [String : Any]
    
    var url:URL{
        return URL(string: self.path)!
    }
}

extension UIView{
    
    func getHUD(spinner:UIActivityIndicatorView) -> UIView{
        let window = UIApplication.shared.delegate?.window
        window??.resignFirstResponder()
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.center = (window??.rootViewController?.view.center)!
        spinner.center = view.center
        spinner.startAnimating()
        view.addSubview(spinner)
        window??.addSubview(view)
        return view
    }
}

    
class Network {
    class func networkRequest(_ resource:NetworkRequestResourceType , showProgress: Bool, compilation: @escaping (Result<Any, NSError>) -> Void){
        self.log(resource:resource)
        Network.dataTask(path: resource.url, method: resource.method, param: resource.param, showProgress: showProgress) {
            compilation($0)
        }
    }
    static fileprivate let kTimeOutInterval:Double = 45
    static fileprivate var sharedAlamofire:SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = kTimeOutInterval
        configuration.timeoutIntervalForRequest =  kTimeOutInterval
        let alamoFireManager = Alamofire.SessionManager(configuration: configuration)
        return alamoFireManager
    }()
    
    final class func dataTask(path: URL, method: HTTPMethod, param : Dictionary<String,Any>, showProgress: Bool, complitionBlock:@escaping(_ result: Result<Any, NSError>) -> Void){
        
        if !Connectivity.isConnectedToInternet {
            let customError = NSError(domain: "Network", code: 67, userInfo: [NSLocalizedDescriptionKey : "No Internet Connection available"])
            complitionBlock(.failure(customError))
            return
        }
        var hudView: UIView?
        if (showProgress) {
            hudView = UIView().getHUD(spinner: UIActivityIndicatorView())
        }
        
        var headers = [String : String]()
        headers[HeaderKey.x_api_key] = HeaderKey.valXApiKey
        
        self.sharedAlamofire.request(path, method: method, parameters: param, encoding: URLEncoding.default, headers: headers).responseJSON { (response: DataResponse<Any>) in
            switch(response.result){
            case .success(let JSON):
                if (showProgress) {
                    hudView?.removeFromSuperview()
                }
//                complitionBlock(.success(JSON))
                let status = (JSON as? NSDictionary)?.value(forKey: "status") as? Int
                if status == 401 {
                    SharedPreference.clearUserData()
                    let loginVC = MainClass.mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    MainClass.appDelegate.navController = UINavigationController(rootViewController: loginVC)
                    MainClass.appDelegate.window?.rootViewController = MainClass.appDelegate.navController
                }else{
                    complitionBlock(.success(JSON))
                }
                break
            case .failure(_):
//                let customError = NSError(domain: "Network", code: 67, userInfo: [NSLocalizedDescriptionKey : "Server issue"]);
                
                let customError = NSError(domain: "Network", code: 67, userInfo: [NSLocalizedDescriptionKey : response.error!.localizedDescription ]);
                complitionBlock(.failure(customError))
                if (showProgress) {
                    hudView?.removeFromSuperview()
                }
                break
            }
        }
    }
    static func log(resource: NetworkRequestResourceType) {
        let greeting = "\n\n*********************************************\n\n"
        var debugString = greeting;
        
        debugString += (resource.path  + resource.param.apiDebug)
        debugString += greeting
        print("\n\n==============NetworkRequest===============:\(debugString)\n\n")
    }
    
    final class func uploadData(_ resource: NetworkRequestResourceType, compilationBlock: @escaping (_ result: Result<Any, NSError>) -> Void){
        self.log(resource:resource)
        
        if !Connectivity.isConnectedToInternet {
            let customError = NSError(domain: "Network", code: 67, userInfo: [NSLocalizedDescriptionKey : "No internet connection available"]);
            compilationBlock(.failure(customError))
            return
        }
        let hudView = UIView().getHUD(spinner: UIActivityIndicatorView())
        
        var headers = [String : String]()
        headers[HeaderKey.x_api_key] = HeaderKey.valXApiKey
        
        self.sharedAlamofire.upload(multipartFormData: { (multipartFormData) in
            for  (key, value) in resource.param{
                if value is URL{
                    let url = value as! URL
                    multipartFormData.append(url, withName: key)
                }else {
                    multipartFormData.append((value as AnyObject).data!(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
        }, to: resource.url, headers: headers) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    hudView.removeFromSuperview()
                    switch response.result{
                    case .success(let result):
                        compilationBlock(.success(result))
                    case .failure(let error):
                        let customError = NSError(domain: "Network", code: 67, userInfo: [NSLocalizedDescriptionKey : error.localizedDescription]);
                        compilationBlock(.failure(customError))
                    }
                }
                
            case .failure( _ as NSError):
                hudView.removeFromSuperview()
                let customError = NSError(domain: "Network", code: 67, userInfo: [NSLocalizedDescriptionKey : "Server Not Responding"]);
                compilationBlock(.failure(customError))
            default:
                break
            }
        }
    }
    
    
    class func downloadImage(_ urlString:String, compilation:@escaping (_ result: Data) -> Void){
        self.sharedAlamofire.request(self.urlRequest(urlString) as! URLRequestConvertible).response(completionHandler: { (response) in
            
            guard let data = response.data else {return}
            compilation(data)
            
        })
    }
    
    class func urlRequest(_ urlString:String) -> NSMutableURLRequest {
        return NSMutableURLRequest(url: URL(string: urlString)!, cachePolicy: .returnCacheDataElseLoad , timeoutInterval: kTimeOutInterval)
    }
    
    class func downloadFileToLocal(_ fileToDownload: URL, fileToStoreLocation: URL, compilation:@escaping (_ localPath: URL?) -> Void){
        
        do {
            
            let request = try URLRequest(url: fileToDownload, method: .get)
            
            self.sharedAlamofire.download(request, to: { (url, urlReponse) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
                
                return (fileToStoreLocation, DownloadRequest.DownloadOptions.removePreviousFile)
            }).response(completionHandler: { (response) in
                compilation(response.destinationURL)
            })
            
            
        }catch (_) {
            
        }
    }
    
}

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}



