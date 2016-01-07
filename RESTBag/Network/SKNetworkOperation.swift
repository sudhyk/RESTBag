 //
 //  SKNetworkOperation.swift
 //  MobileAppCore
 //
 //  Created by Sudheendra Kaanugovi on 7/8/15.
 //  Copyright (c) 2015 Sudheendra Kaanugovi. All rights reserved.
 //
 
 import Foundation
 
 class SKNetworkOperation: NSOperation {
    
    var request: NSURLRequest
    var completionblock: ServiceCompletion
    var error: NSError?
    
    init(request: NSURLRequest, completion: ServiceCompletion) {
        self.request = request
        completionblock = completion
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
        
        executing = true
        main()
    }
    
    override func main() {
        
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { [weak self] (data, response, responseerror) in
            print(response)
            //Callbacks after task
            self?.completeOperation(data, response: response, error: responseerror)
            }).resume()
    }
    
    override func cancel() {
        super.cancel()
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    }
    
    
    func completeOperation(data:NSData?, response:NSURLResponse?, error:NSError?) {
        var decodedJson: [String:AnyObject]? = nil
        do {
            decodedJson = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String:AnyObject]
        } catch let error as NSError {
            self.error = NSError(domain: CoreConstants.domain, code:ServiceError.kServiceResponseError.value() , userInfo: [:])
            print("json error: \(error.localizedDescription)")
        }
        self.completionblock(decodedJson, self.error)
        executing = false
        finished = true
    }
 }