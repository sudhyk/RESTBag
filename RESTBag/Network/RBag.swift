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
    
    public func makeAPIRequest(#apiservice: String, requestDictionary: NSDictionary?, completionblock:ServiceCompletion){

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
    
    func constructRequest(#service: String, requestDictionary: NSDictionary?) -> NSURLRequest? {
        
        if let serviceInfo = ServiceConfiguration.sharedInstance.serviceInfoDictionary(service) as NSDictionary? {
            var endpoint: String!
            
            if let explicitURL = serviceInfo.objectForKey(CoreConstants.ServiceDataConstants.kisExplicitURL) as? Bool {
                endpoint = serviceInfo.objectForKey(CoreConstants.ServiceDataConstants.kURLKey) as! String
            } else {
                // End Point Base URL
                let baseURL = ServiceConfiguration.sharedInstance.globalConfig.objectForKey(CoreConstants.ServiceDataConstants.kBaseURLKey) as! String
                endpoint = "\(baseURL)\(serviceInfo.objectForKey(CoreConstants.ServiceDataConstants.kURLKey) as! String)"

            }

            // End Point Request Object with Full URL Extracted
            var request = NSMutableURLRequest(URL: NSURL(string: endpoint)!)
            // End Point Request Object set HTTPMethod
            if let networkmethod = serviceInfo.objectForKey(CoreConstants.ServiceDataConstants.kMethodKey) as? String {
                request.HTTPMethod = networkmethod
            }
            var jsonError: NSError?
            // End Point Request Type
            request.addValue(serviceInfo.objectForKey(CoreConstants.ServiceDataConstants.kType) as? String, forHTTPHeaderField: "Content-Type")
            
            // End Point Request Object set HTTPBody
            if let requestData = requestDictionary {
                var byteData = NSJSONSerialization.dataWithJSONObject(requestData, options: nil, error: &jsonError)
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
        
        var jsonError: NSError?
        var filePath: NSURL?
        // prioritize from main bundle
        if let priorityAPIConfigJSON = NSBundle.mainBundle().URLForResource("apiconfig", withExtension: "json") {
            filePath = priorityAPIConfigJSON
        } else {
            filePath = NSBundle(forClass: ServiceConfiguration.self).URLForResource("apiconfig", withExtension:"json")
        }
        if let jsonData = NSData(contentsOfURL: filePath!, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: nil) {
            self.servicesData = NSJSONSerialization.JSONObjectWithData(jsonData, options: nil, error: &jsonError) as? NSDictionary
        self.globalConfig = self.servicesData.objectForKey(CoreConstants.ServiceDataConstants.kGlobalConfigsKey) as? NSDictionary
        }
        super.init()
    }
    
    func serviceInfoDictionary(serviceName:String) -> NSDictionary? {
        
        if let serviceInfo = self.servicesData.objectForKey(serviceName) as? NSDictionary {
            return serviceInfo
        }
        return nil
    }
    
}