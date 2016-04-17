//
//  ViewController.swift
//  Clapper
//
//  Created by Jack Cook on 4/16/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import AVFoundation
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var captureDevice: AVCaptureDevice!
    private var stillImageOutput: AVCaptureStillImageOutput!
    private var imageTaken: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeCamera()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(clap), name: ClapperClapNotification, object: nil)
    }
    
    func initializeCamera() {
        let session = AVCaptureSession()
        
        let camera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        let cameraInput = try! AVCaptureDeviceInput(device: camera)
        
        var bestFormat: AVCaptureDeviceFormat?
        var frameRateRange: AVFrameRateRange?
        
        formatLoop: for format in camera.formats as! [AVCaptureDeviceFormat] {
            let dimensions = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            let pixelArea = dimensions.width * dimensions.height
            
            if pixelArea <= 1080 * 1920 {
                bestFormat = format
                
                for range in format.videoSupportedFrameRateRanges as! [AVFrameRateRange] {
                    if range.maxFrameRate == 60 {
                        bestFormat = format
                        frameRateRange = range
                        break formatLoop
                    }
                }
            }
        }
        
        do {
            try camera.lockForConfiguration()
            camera.activeFormat = bestFormat
            camera.activeVideoMinFrameDuration = frameRateRange!.minFrameDuration
            camera.activeVideoMaxFrameDuration = frameRateRange!.maxFrameDuration
            camera.unlockForConfiguration()
        } catch {
            print("error locking camera for configuration")
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        cameraView.layer.addSublayer(previewLayer)
        previewLayer.frame = UIScreen.mainScreen().bounds
        
        session.addInput(cameraInput)
        session.startRunning()
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
