//
//  RBag.swift
//  MobileAppCore
//
//  Created by Sudheendra Kaanugovi on 7/8/15.
//  Copyright (c) 2015 Sudheendra Kaanugovi. All rights reserved.
//

import Foundation

public typealias ServiceCompletion = (NSDictionary?, NSError?) -> ()

public class RBag: NSObject {
    
    public override init() {
        super.init()
    }
    
    public func makeAPIRequest(apiservice apiservice: String, requestDictionary: NSDictionary?, completionblock:ServiceCompletion){

        if let request = self.constructRequest(service: apiservice, requestDictionary: requestDictionary) {
        
            let op = SKNetworkOperation(request: request) { (responsedict, error) -> () in
                completionblock(responsedict, error)
            }
            SKNetworkPerformer.sharedInstance.perform(op)
        } else {
            let error = NSError(domain: CoreConstants.domain, code: ServiceError.kServiceRequestConstructionError.value(), userInfo: [:])
            completionblock(nil, error)
        }
    }
    
    func constructRequest(service service: String, requestDictionary: NSDictionary?) -> NSURLRequest? {
        
        if let serviceInfo = ServiceConfiguration.sharedInstance.serviceInfoDictionary(service) as NSDictionary? {
            var endpoint: String!
            
            if let _ = serviceInfo.objectForKey(CoreConstants.ServiceDataConstants.kisExplicitURL) as? Bool {
                endpoint = serviceInfo.objectForKey(CoreConstants.ServiceDataConstants.kURLKey) as! String
            } else {
                // End Point Base URL
                let baseURL = ServiceConfiguration.sharedInstance.globalConfig.objectForKey(CoreConstants.ServiceDataConstants.kBaseURLKey) as! String
                endpoint = "\(baseURL)\(serviceInfo.objectForKey(CoreConstants.ServiceDataConstants.kURLKey) as! String)"

            }

            // End Point Request Object with Full URL Extracted
            let request = NSMutableURLRequest(URL: NSURL(string: endpoint)!)
            // End Point Request Object set HTTPMethod
            if let networkmethod = serviceInfo.objectForKey(CoreConstants.ServiceDataConstants.kMethodKey) as? String {
                request.HTTPMethod = networkmethod
            }
            var jsonError: NSError?
            // End Point Request Type
            request.addValue((serviceInfo.objectForKey(CoreConstants.ServiceDataConstants.kType) as? String)!, forHTTPHeaderField: "Content-Type")
            
            // End Point Request Object set HTTPBody
            if let requestData = requestDictionary {
                var byteData: NSData?
                do {
                    byteData = try NSJSONSerialization.dataWithJSONObject(requestData, options: [])
                } catch let error as NSError {
                    jsonError = error
                    byteData = nil
                }
                if jsonError == nil {
                    request.HTTPBody = byteData
                }
            }
            // End Point Request Object Confgure HTTPheaders
            return request
        }
        return nil
    }
}

class ServiceConfiguration:NSObject {
   
    private var servicesData:NSDictionary! = nil
    var globalConfig:NSDictionary! = nil
    
    class var sharedInstance: ServiceConfiguration {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: ServiceConfiguration? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = ServiceConfiguration()
        }
        return Static.instance!
    }

    private override init() {
        super.init()
        
        var filePath: NSURL?
        // prioritize from main bundle
        if let priorityAPIConfigJSON = NSBundle.mainBundle().URLForResource("apiconfig", withExtension: "json") {
            filePath = priorityAPIConfigJSON
        } else {
            filePath = NSBundle(forClass: ServiceConfiguration.self).URLForResource("apiconfig", withExtension:"json")
        }
        
        if let jsonData = try? NSData(contentsOfURL: filePath!, options: NSDataReadingOptions.DataReadingMappedIfSafe) {
            self.servicesData = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as! [String:AnyObject]

        self.globalConfig = self.servicesData.objectForKey(CoreConstants.ServiceDataConstants.kGlobalConfigsKey) as? NSDictionary
        }
    }
    
    func serviceInfoDictionary(serviceName:String) -> NSDictionary? {
        guard let serviceInfo = self.servicesData.objectForKey(serviceName) as? NSDictionary else {
            return nil
        }
        return serviceInfo
    }
    
}