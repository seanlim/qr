//
//  ViewController.swift
//  QR
//
//  Created by Sean Lim on 19/4/20.
//  Copyright © 2020 Sean Lim. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
  var captureSession = AVCaptureSession()
  var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  var qrCodeViewLayer: UIView = UIView()
  let generator = UIImpactFeedbackGenerator(style: .medium)
  
  var showingMedia = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupScanner()
    
    view.addSubview(qrCodeViewLayer)
    view.bringSubviewToFront(qrCodeViewLayer)
    qrCodeViewLayer.frame = view.frame
  }
  
  func setupScanner() {
    guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
      print("Failed to get the camera device")
      return
    }
    do {
      let input = try AVCaptureDeviceInput(device: captureDevice)
      captureSession.addInput(input)
      
      let captureMetadataOutput = AVCaptureMetadataOutput()
      captureSession.addOutput(captureMetadataOutput)
      
      captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      captureMetadataOutput.metadataObjectTypes = [
        AVMetadataObject.ObjectType.qr
      ]
      
      // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
      videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
      videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
      videoPreviewLayer?.frame = view.layer.bounds
      view.layer.addSublayer(videoPreviewLayer!)
      
      captureSession.startRunning()
    } catch {
      print(error)
      return
    }
  }
}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    // Check if the metadataObjects array is not nil and it contains at least one object.
    if metadataObjects.count == 0 || metadataObjects.count < qrCodeViewLayer.subviews.count {
      qrCodeViewLayer.subviews.forEach {
        $0.removeFromSuperview()
      }
      return
    }
    
    for object in metadataObjects {
      let metadataObj = object as! AVMetadataMachineReadableCodeObject
      
      if metadataObj.type == AVMetadataObject.ObjectType.qr {
        if metadataObj.stringValue != nil {
          print(metadataObj.stringValue)
          let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
          if (qrCodeViewLayer.subviews.map { $0.accessibilityIdentifier }.contains(metadataObj.stringValue)) {
            qrCodeViewLayer.subviews.forEach {
              if $0.accessibilityIdentifier == metadataObj.stringValue {
                $0.frame = barCodeObject!.bounds
              }
            }
          } else {
            generator.impactOccurred()
            let qrCodeFrameView = UIView()
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            qrCodeFrameView.frame = barCodeObject!.bounds

            qrCodeFrameView.accessibilityIdentifier = metadataObj.stringValue
            
            qrCodeViewLayer.addSubview(qrCodeFrameView)
          }
        }
      }
    }
  }
}

