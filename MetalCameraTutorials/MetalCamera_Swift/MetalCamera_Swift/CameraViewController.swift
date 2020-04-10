//
//  CameraViewController.swift
//  MetalCamera_Swift
//
//  Created by HanGyo Jeong on 2020/04/09.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreVideo
import MobileCoreServices

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate
{
    private enum SessionSetupResult
    {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private var setupResult: SessionSetupResult = .success
    
    private let session = AVCaptureSession()
    
    // Communicate with the session and other session objects on this queue
    private let sessionQueue = DispatchQueue(label: "SessionQueue", attributes: [], autoreleaseFrequency: .workItem)
    private let dataOutputQueue = DispatchQueue(label: "VideoDataQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    private var videoInput: AVCaptureDeviceInput!
    
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    private var renderingEnabled = true
    
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera],
                                                                               mediaType: .video,
                                                                               position: .unspecified)
    
    @IBOutlet weak var preView: PreviewMetalView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Check video authorization status, video access is required
        switch AVCaptureDevice.authorizationStatus(for: .video)
        {
        case .authorized:
            // The user has previously granted access to the camera
            break
            
        case .notDetermined:
            //The user has not yet been presented with the option to grant video access
            //Suspend the SessionQueue to delay session setup until the access request has completed
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: {
                granted in
                if !granted
                {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            break
            
        default:
            setupResult = .notAuthorized
        }
        
        /*
         Don't do this on the main queue, because AVCaptureSession.startRunning() is a blocking call
         */
        sessionQueue.async
        {
            self.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        sessionQueue.async
        {
            switch self.setupResult
            {
            case .success:
                
                self.dataOutputQueue.async
                {
                    self.renderingEnabled = true
                }
                self.session.startRunning()
                
            case .notAuthorized:
                DispatchQueue.main.async
                {
                    let message = NSLocalizedString("AVCamFilter doesn't have permission to use the camera, please change privacy settings", comment: "Alert message when the user has denied access to the camera")
                    
                    let actions = [
                        UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil),
                        UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"), style: .default, handler: {
                            _ in
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                        })
                    ]
                    self.alert(title: "AVCamFilter", message: message, actions: actions)
                }
            case .configurationFailed:
                DispatchQueue.main.async {
                    let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
                    
                    self.alert(title: "AVCamFilter", message: message, actions: [UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil)])
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        dataOutputQueue.async
        {
            self.renderingEnabled = false
        }
        sessionQueue.async
        {
            if self.setupResult == .success
            {
                self.session.stopRunning()
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    //MARK: Session Management
    private func configureSession()
    {
        if setupResult != .success
        {
            return
        }
        
        let defaultVideoDevices: AVCaptureDevice? = videoDeviceDiscoverySession.devices.first
        
        guard let videoDevice = defaultVideoDevices else
        {
            print("Could not find any video device")
            setupResult = .configurationFailed
            return
        }
        
        do
        {
            videoInput = try AVCaptureDeviceInput(device: videoDevice)
        }
        catch
        {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            return
        }
        
        session.beginConfiguration()
        
        session.sessionPreset = AVCaptureSession.Preset.photo
        
        // Add a video input
        guard session.canAddInput(videoInput) else
        {
            print("Could not add video device input to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        session.addInput(videoInput)
        
        // Add a video data output
        if session.canAddOutput(videoDataOutput)
        {
            session.addOutput(videoDataOutput)
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
            videoDataOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
        }
        else
        {
            print("Could not add video data output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        //capFrameRate
        
        session.commitConfiguration()
    }
    
    func alert(title: String, message: String, actions: [UIAlertAction])
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        actions.forEach{
            alertController.addAction($0)
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Video Data Output Delegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
        processVideo(sampleBuffer: sampleBuffer)
    }
    
    func processVideo(sampleBuffer: CMSampleBuffer)
    {
        if !renderingEnabled
        {
            return
        }
        
        guard let videoPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else
        {
            return
        }
        
        preView.pixelBuffer = videoPixelBuffer
    }
}
