//
//  AppDelegate.swift
//  Clapper
//
//  Created by Jack Cook on 4/16/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import Taylor
import UIKit

let ClapperClapNotification = "ClapperClapNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var server: Server!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        server = Taylor.Server()
        
        server.get("/clap") { (request, response, callback) in
            NSNotificationCenter.defaultCenter().postNotificationName(ClapperClapNotification, object: nil)
            
            response.bodyString = "success"
            callback(.Send(request, response))
            
            return
        }
        
        dispatch_async(dispatch_queue_create("serverQueue", DISPATCH_QUEUE_SERIAL)) {
            let port = 12345
            do {
                print("Starting server on port \(port)")
                try self.server.serveHTTP(port: port, forever: true)
            } catch {
                print("Server start failed \(error)")
            }
        }
        
        return true
    }
}
