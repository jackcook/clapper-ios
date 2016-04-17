//
//  CameraButton.swift
//  Clapper
//
//  Created by Jack Cook on 4/17/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import UIKit

class CameraButton: UIView {
    
    var delegate: CameraButtonDelegate?
    
    private var outerView: UIView!
    private var middleView: UIView!
    private var innerView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.clearColor()
        
        outerView = UIView()
        outerView.backgroundColor = UIColor.clapperLightColor()
        addSubview(outerView)
        
        middleView = UIView()
        middleView.backgroundColor = UIColor.clapperDarkColor()
        addSubview(middleView)
        
        innerView = UIView()
        innerView.backgroundColor = UIColor.clapperLightColor()
        addSubview(innerView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        outerView.frame = bounds
        outerView.layer.cornerRadius = outerView.bounds.width / 2
        
        middleView.frame = CGRectMake(4, 4, bounds.width - 8, bounds.height - 8)
        middleView.layer.cornerRadius = middleView.bounds.width / 2
        
        innerView.frame = CGRectMake(6, 6, bounds.width - 12, bounds.height - 12)
        innerView.layer.cornerRadius = innerView.bounds.width / 2
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        UIView.animateWithDuration(0.15) {
            self.innerView.backgroundColor = UIColor.grayColor()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        UIView.animateWithDuration(0.15) {
            self.innerView.backgroundColor = UIColor.clapperLightColor()
        }
        
        delegate?.takePhoto(self)
    }
}

protocol CameraButtonDelegate {
    func takePhoto(button: CameraButton)
}
