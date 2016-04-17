//
//  AppDelegate.swift
//  Clapper
//
//  Created by Jack Cook on 4/16/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import UIKit

let ClapperClapNotification = "ClapperClapNotification"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var server: HTTPServer!
    var window: UIWindow?
    
    private func startServer() {
        do {
            try server.start()
            print("Started HTTP server on port \(server.listeningPort())")
        } catch let error as NSError {
            print("Error starting HTTP server: \(error)")
        }
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        
        server = HTTPServer()
        server.setType("_http._tcp.")
        server.setPort(12345)
        server.setConnectionClass(ClapperConnection)
        
        startServer()
        
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        startServer()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        server.stop()
    }
}
