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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupScanner()
    
    view.addSubview(qrCodeViewLayer)
    view.bringSubviewToFront(qrCodeViewLayer)
    qrCodeViewLayer.frame = view.frame
  }
  
  @objc func buttonPressed(sender: UIButton) {
    print(sender.accessibilityIdentifier)
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
      UIView.transition(with: self.view, duration: 0.1, options: [.transitionCrossDissolve], animations: {
        self.qrCodeViewLayer.subviews.forEach {
          $0.removeFromSuperview()
        }
      })
      return
    }
    
    for object in metadataObjects {
      let metadataObj = object as! AVMetadataMachineReadableCodeObject
      
      if metadataObj.type == AVMetadataObject.ObjectType.qr {
        if metadataObj.stringValue != nil {
          let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
          if (qrCodeViewLayer.subviews.map { ($0 as! QRContentView).content }.contains(metadataObj.stringValue)) {
            qrCodeViewLayer.subviews.forEach {
              if ($0 as! QRContentView).content == metadataObj.stringValue {
                if ($0 as! QRContentView).userInteracting {
                  ($0 as! QRContentView).updatePosition(self.view.frame)
                } else {
                  ($0 as! QRContentView).updatePosition(barCodeObject!.bounds)
                }
              }
            }
          } else {
            generator.impactOccurred()
            let qrContentView = QRContentView.init(content: metadataObj.stringValue!, frame: barCodeObject!.bounds)

            UIView.transition(with: self.view, duration: 0.1, options: [.transitionCrossDissolve], animations: {
              self.qrCodeViewLayer.addSubview(qrContentView)
            }, completion: nil)
          }
        }
      }
    }
  }
}

