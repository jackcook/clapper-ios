//
//  ViewController.swift
//  Clapper
//
//  Created by Jack Cook on 4/16/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(clap), name: ClapperClapNotification, object: nil)
    }
    
    func clap() {
        dispatch_async(dispatch_get_main_queue()) { 
            self.view.backgroundColor = UIColor.redColor()
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.view.backgroundColor = UIColor.whiteColor()
        }
    }
}
