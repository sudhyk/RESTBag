//
//  CoreConstants.swift
//  MobileAppCore
//
//  Created by Sudheendra Kaanugovi on 7/8/15.
//  Copyright (c) 2015 Sudheendra Kaanugovi. All rights reserved.
//

import Foundation

enum ServiceError {
    case kServiceRequestError, kServiceResponseError, kServiceRequestConstructionError
    
    func value()->(Int) {
        switch self {
        case .kServiceRequestError:
            return 5001
        case .kServiceResponseError:
            return 5002
        case .kServiceRequestConstructionError:
            return 5003
        }

        
    }
}

enum ServiceMethodType {
    case GET, POST, DELETE, PUT
    
    func value()->String {
        switch self {
        case .GET:
            return "GET"
        case .POST:
            return "POST"
        case .DELETE:
            return "DELETE"
        case .PUT:
            return "PUT"
        }
    }
    
}

struct CoreConstants {
    
    static let maximumconcurrentoperations = 5
    static let domain = "com.nsstack.restbag"
    
    struct ServiceDataConstants {
    
        static let kGlobalConfigsKey = "globalConfigs"
        static let kBaseURLKey = "baseURL"
        static let kURLKey = "url"
        static let kMethodKey = "method"
        static let kType = "type"
        static let kisExplicitURL = "expliciturl"
    }
    
    
}