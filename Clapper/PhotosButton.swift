//
//  PhotosButton.swift
//  Clapper
//
//  Created by Jack Cook on 4/17/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import UIKit

class PhotosButton: UIView {
    
    var delegate: PhotosButtonDelegate?
    
    var image = UIImage() {
        didSet {
            imageView.image = image
        }
    }
    
    private var imageView: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        imageView = UIImageView()
        imageView.contentMode = .ScaleToFill
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        delegate?.openPhotosApp()
    }
}

protocol PhotosButtonDelegate {
    func openPhotosApp()
}
