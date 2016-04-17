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
    @IBOutlet weak var finishedView: UIImageView!
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var captureDevice: AVCaptureDevice!
    private var stillImageOutput: AVCaptureStillImageOutput!
    private var imageTaken: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeCamera()
        
        finishedView.alpha = 0
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(clap), name: ClapperClapNotification, object: nil)
    }
    
    func initializeCamera() {
        captureSession = AVCaptureSession()
        
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
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraView.layer.addSublayer(previewLayer)
        previewLayer.frame = UIScreen.mainScreen().bounds
        
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        captureSession.addOutput(stillImageOutput)
        
        captureSession.addInput(cameraInput)
        captureSession.startRunning()
    }
    
    func clap() {
        var videoConnection: AVCaptureConnection?
        
        connectionsLoop: for connection in stillImageOutput.connections {
            for port in connection.inputPorts as! [AVCaptureInputPort] {
                if port.mediaType == AVMediaTypeVideo {
                    videoConnection = connection as? AVCaptureConnection
                    break connectionsLoop
                }
            }
        }
        
        stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageSampleBuffer, error) -> Void in
            let data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
            self.imageTaken = UIImage(data: data)
            self.finishedView.image = self.imageTaken
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.finishedView.alpha = 1
            })
        })
    }
}
