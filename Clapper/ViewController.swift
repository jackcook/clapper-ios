//
//  ViewController.swift
//  Clapper
//
//  Created by Jack Cook on 4/16/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import Swifter
import UIKit

class ViewController: UIViewController {
    
    var server: HTTPServer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        
        server = HTTPServer()
        server.setType("_http._tcp.")
        server.setPort(12345)
        server.setConnectionClass(ClapperConnection)
        
        do {
            try server.start()
            print("Started HTTP server on port \(server.listeningPort())")
        } catch let error as NSError {
            print("Error starting HTTP server: \(error)")
        }
    }
}
