//
//  ViewController.swift
//  MetalCamera_Swift
//
//  Created by HanGyo Jeong on 2020/03/27.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    /*
     Initialise session
     */
    let captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Request access to hardware
         */
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted: Bool) -> Void in
            guard granted else {
                //Report an error. we didn't get access to hardware
                NSLog("Fail to access hardware resource")
                return
            }
            //All good, Hardware Access granted
        }
        
        guard let inputDevice = device(mediaType: AVMediaType.video, position: AVCaptureDevice.Position.front) else {
            //Handle an error. we couldn't get hold of the requested hardware
            NSLog("Can't get hold of the requested hardware");
            return
        }
        
        /*
         Add input to session
         */
        var captureInput: AVCaptureDeviceInput!
        do {
            captureInput = try AVCaptureDeviceInput(device: inputDevice)
        }
        catch {
            //Handle an error. Input device is not available
            NSLog("Input device is not available")
        }
        
        captureSession.beginConfiguration()
        
        guard captureSession.canAddInput(captureInput) else {
            //Handle an error, Failed to add an input device
            NSLog("Fail to add an input device")
            captureSession.commitConfiguration()
            return
        }
        
        captureSession.addInput(captureInput)
        
        /*
         Add output to session
         */
        let outputData = AVCaptureVideoDataOutput()
        
        //Setting the camera data format
        outputData.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)]
        
        //Setting delegate that is going to receive each and every video frame
        let captureSessionQueue = DispatchQueue(label: "CameraSessionQueue", attributes: [])
        outputData.setSampleBufferDelegate(self, queue: captureSessionQueue)
        
        guard captureSession.canAddOutput(outputData) else {
            //Handle an error, when failed to add an output device
            NSLog("Fail to add an output device")
            return
        }
        captureSession.addOutput(outputData)
        
        /*
         Start session
         */
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }

    //Get a AVCaptureDevice instance representing the camera
    func device(mediaType: AVMediaType, position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        guard let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInDualCamera, .builtInWideAngleCamera], mediaType: mediaType, position: .unspecified).devices as? [AVCaptureDevice] else
        {
            return nil;
        }
        
        if let index = devices.firstIndex(where: { $0.position == position })
        {
            return devices[index]
        }
        return nil
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate
{
    //AVCaptureVideoDataOutputSampleBufferDelegate method
    //output callback that will be called for every frame, passing tthe frame data in a CMSampleBuffer
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        NSLog("capture output")
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            //Handle an error. we failed to get image buffer
            NSLog("Fail to get image buffer")
            return
        }
    }
}
