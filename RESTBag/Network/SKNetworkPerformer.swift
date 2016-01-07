//
//  SKNetworkPerformer.swift
//  MobileAppCore
//
//  Created by Sudheendra Kaanugovi on 7/8/15.
//  Copyright (c) 2015 Sudheendra Kaanugovi. All rights reserved.
//

import Foundation

class SKNetworkPerformer: NSObject {
    
    let concurrentqueue: NSOperationQueue
    let serialqueue: NSOperationQueue
    
    class var sharedInstance: SKNetworkPerformer {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: SKNetworkPerformer? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = SKNetworkPerformer()
        }
        return Static.instance!
    }
    
    override init() {
        concurrentqueue = NSOperationQueue()
        concurrentqueue.maxConcurrentOperationCount = CoreConstants.maximumconcurrentoperations
        
        serialqueue = NSOperationQueue()
        serialqueue.maxConcurrentOperationCount = 1
        
        super.init()
    }
    
    func perform(operation: SKNetworkOperation) {
        concurrentqueue.addOperation(operation)
    }
    
    func processserialtask(operation: SKNetworkOperation) {
        serialqueue.addOperation(operation)
    }
    
    func cancelAllOperations() {
        concurrentqueue.cancelAllOperations()
        serialqueue.cancelAllOperations()
    }
    
}