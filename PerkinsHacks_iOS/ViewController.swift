//
//  ViewController.swift
//  PerkinsHacks_iOS
//
//  Created by Rishab Nayak on 5/23/18.
//  Copyright © 2018 OAR. All rights reserved.
//

import UIKit
import AVFoundation
import Clarifai_Apple_SDK

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    var captureSession =  AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var concepts: [Concept] = []
    var model: Model!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.model = Clarifai.sharedInstance().generalModel
        setupCaptureSession()
    }
    
    func setupCaptureSession(){
        let captureSession = AVCaptureSession()
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        do {
            if let captureDevice = availableDevices.first {
                let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(captureDeviceInput)
            }
        } catch {
            print(error.localizedDescription)
        }
        let captureOutput = AVCaptureVideoDataOutput()
        captureOutput.alwaysDiscardsLateVideoFrames = true
        captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(captureOutput)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let buffer = sampleBuffer.imageBuffer
        let ciimage = CIImage(cvImageBuffer: buffer!)
        let uiimage = UIImage(ciImage: ciimage)
        let image = Image(image: uiimage)
        let dataAsset = DataAsset.init(image: image)
        let input = Input.init(dataAsset:dataAsset)
        let inputs = [input]
        self.model.predict(inputs, completionHandler: {(outputs: [Output]?,error: Error?) -> Void in
            // Iterate through outputs to learn about what has been predicted
            for output in outputs! {
                // Do something with your outputs
                // In the sample code below the output concepts are being added to an array to be displayed.
                self.concepts.append(contentsOf: output.dataAsset.concepts!)
            }
            print(self.concepts[1].name)
        })
        self.concepts.removeAll()
        usleep(1000000)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

