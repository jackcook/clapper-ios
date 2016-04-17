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
let ClapperLightNotification = "ClapperLightNotification"
let ClapperTemperatureNotification = "ClapperTemperatureNotification"
let ClapperFlashNotification = "ClapperFlashNotification"

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
        
        server.get("/light") { (request, response, callback) in
            guard let n = request.arguments["n"], ni = Int(n) else {
                return
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(ClapperLightNotification, object: ni)
            
            response.bodyString = "success"
            callback(.Send(request, response))
            
            return
        }
        
        server.get("/temperature") { (request, response, callback) in
            guard let n = request.arguments["n"], ni = Int(n) else {
                return
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(ClapperTemperatureNotification, object: ni)
            
            response.bodyString = "success"
            callback(.Send(request, response))
            
            return
        }
        
        server.get("/flash") { (request, response, callback) in
            guard let n = request.arguments["n"], ni = Int(n) else {
                return
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName(ClapperFlashNotification, object: ni)
            
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
