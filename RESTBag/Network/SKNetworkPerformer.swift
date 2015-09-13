//
//  SKNetworkPerformer.swift
//  MobileAppCore
//
//  Created by Sudheendra Kaanugovi on 7/8/15.
//  Copyright (c) 2015 Sudheendra Kaanugovi. All rights reserved.
//

import Foundation

class SKNetworkPerformer: NSObject {
    
    var concurrentqueue: NSOperationQueue!
    var serialqueue: NSOperationQueue!
    
    
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
        self.concurrentqueue = NSOperationQueue()
        self.concurrentqueue.maxConcurrentOperationCount = CoreConstants.maximumconcurrentoperations
        
        self.serialqueue = NSOperationQueue()
        self.serialqueue.maxConcurrentOperationCount = 1
        
        super.init()
    }
    
    func perform(operation: SKNetworkOperation) {
        self.concurrentqueue.addOperation(operation)
    }
    
    func processserialtask(operation: SKNetworkOperation) {
        self.serialqueue.addOperation(operation)
    }
    
    func cancelAllOperations() {
        self.concurrentqueue.cancelAllOperations()
        self.serialqueue.cancelAllOperations()
    }
    
}