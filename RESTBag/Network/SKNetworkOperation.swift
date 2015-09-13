 //
//  SKNetworkOperation.swift
//  MobileAppCore
//
//  Created by Sudheendra Kaanugovi on 7/8/15.
//  Copyright (c) 2015 Sudheendra Kaanugovi. All rights reserved.
//

import Foundation

class SKNetworkOperation: NSOperation {
    
    var request:NSURLRequest! = nil
    var completionblock:ServiceCompletion
    var error:NSError?

    init(request:NSURLRequest, completion:ServiceCompletion) {
        
        self.request = request
        self.completionblock = completion
        super.init()
        
    }

    var _executing = false
    var _finished = false
    
    override var executing:Bool {
        get { return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    override var finished:Bool {
        get { return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    override func start() {
        
        if self.cancelled {
            return
        }
        
        self.executing = true
        self.main()
    }
    
    override func main() {
        if let localRequest = self.request {
            NSURLSession.sharedSession().dataTaskWithRequest(localRequest, completionHandler: { [weak self] (data, response, responseerror) -> Void in
                println(response)
                //Callbacks after task
                self?.completeOperation(data, response: response, error: responseerror)
            }).resume()
        } else {
            self.error = NSError(domain: CoreConstants.domain, code:ServiceError.kServiceRequestError.value(), userInfo: [:])
            self.completeOperation(nil, response: nil, error: self.error)
        }
    }
    
    override func cancel() {
        super.cancel()
        
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    }
    
    
    func completeOperation(data:NSData?, response:NSURLResponse?, error:NSError?) {
        
        var responseDictionary:NSDictionary! = nil
        if let localizedError = error {
            self.error = localizedError
        } else {
            var jsonError: NSError?
            if let responseData = data, let localizedResponse = response {
                let decodedJson = NSJSONSerialization.JSONObjectWithData(responseData, options: nil, error: &jsonError) as? Dictionary<String, AnyObject>
                if !(jsonError != nil) {
                    responseDictionary = decodedJson
                    println(decodedJson)
                } else {
                     self.error = NSError(domain: CoreConstants.domain, code:ServiceError.kServiceResponseError.value() , userInfo: [:])
                }
            } else {
                self.error = NSError(domain: CoreConstants.domain, code:ServiceError.kServiceResponseError.value() , userInfo: [:])
            }
        }
        
        self.completionblock(responseDictionary, self.error)
        executing = false
        finished = true
    }
    
    
}