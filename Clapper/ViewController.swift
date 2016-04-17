//
//  ViewController.swift
//  Clapper
//
//  Created by Jack Cook on 4/16/16.
//  Copyright © 2016 Jack Cook. All rights reserved.
//

import AVFoundation
import Photos
import UIKit

class ViewController: UIViewController, CameraButtonDelegate, PhotosButtonDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var cameraButton: CameraButton!
    @IBOutlet weak var photosButton: PhotosButton!
    @IBOutlet weak var filterView: UIView!
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var camera: AVCaptureDevice!
    private var stillImageOutput: AVCaptureStillImageOutput!
    private var imageTaken: UIImage!
    
    private var assets = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeCamera()
        initializePhotos()
        
        cameraButton.delegate = self
        photosButton.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(clap(_:)), name: ClapperClapNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(lightingUpdated(_:)), name: ClapperLightNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(temperatureUpdated(_:)), name: ClapperTemperatureNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(flashUpdated(_:)), name: ClapperFlashNotification, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        filterView.frame = view.bounds
    }
    
    func initializeCamera() {
        captureSession = AVCaptureSession()
        
        camera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
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
    
    func initializePhotos() {
        assets = [PHAsset]()
        
        let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
        fetchResult.enumerateObjectsUsingBlock { (asset, idx, stop) in
            guard let asset = asset as? PHAsset else {
                return
            }
            
            self.assets.append(asset)
        }
        
        PHImageManager.defaultManager().requestImageForAsset(assets.last!, targetSize: CGSizeMake(96, 96), contentMode: .AspectFill, options: nil) { (image, info) in
            guard let image = image else {
                return
            }
            
            self.photosButton.image = image
        }
    }
    
    func takePicture() {
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
            
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({ 
                PHAssetChangeRequest.creationRequestForAssetFromImage(self.imageTaken)
            }, completionHandler: { (success, error) in
                if success {
                    print("success")
                } else {
                    print("error: \(error)")
                }
            })
            
            self.photosButton.image = self.imageTaken
        })
    }
    
    func openPhotosApp() {
        let controller = UIImagePickerController()
        controller.allowsEditing = false
        controller.sourceType = .PhotoLibrary
        
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func clap(notification: NSNotification) {
        print("clap")
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            self.takePicture()
        }
    }
    
    func lightingUpdated(notification: NSNotification) {
        guard let n = notification.object as? Int else {
            return
        }
        
        let bias = 4 - Float(n) * (camera.maxExposureTargetBias - camera.minExposureTargetBias) / 108
        
        do {
            try camera.lockForConfiguration()
            camera.setExposureTargetBias(bias) { (time) in
                print("bias set")
            }
            camera.unlockForConfiguration()
        } catch {
            print("couldn't set light")
        }
    }
    
    func temperatureUpdated(notification: NSNotification) {
        guard let n = notification.object as? Int else {
            return
        }
        
        if n < 50 {
            filterView.backgroundColor = UIColor(red: 51/255, green: 152/255, blue: 219/255, alpha: CGFloat(min(0.2, 4 / Float(n))))
        } else {
            filterView.backgroundColor = UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: CGFloat(min(0.2, 0.4 - (20 / Float(n)))))
        }
    }
    
    func flashUpdated(notification: NSNotification) {
        guard let n = notification.object as? Int else {
            return
        }
        
        do {
            try camera.lockForConfiguration()
            
            if n <= 0 {
                camera.torchMode = .Off
            } else if n >= 1 {
                camera.torchMode = .On
            } else {
                try camera.setTorchModeOnWithLevel(Float(n) / 350)
            }
            
            camera.unlockForConfiguration()
        } catch {
            print("couldn't set flash")
        }
    }
    
    func takePhoto(button: CameraButton) {
        takePicture()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
