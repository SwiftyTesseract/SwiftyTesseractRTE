//
//  VideoManager.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/19/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import Foundation
import AVFoundation

class VideoManager: AVManager {
  var previewLayer: AVCaptureVideoPreviewLayer
  var captureSession: AVCaptureSession
  var sessionQueue: DispatchQueue
  var mediaType: AVMediaType
  
  var cameraPosition: AVCaptureDevice.Position {
    didSet {
      configure(captureSession: captureSession, withQuality: cameraQuality, forMediaType: mediaType, andCameraPosition: cameraPosition)
    }
  }
  
  var cameraQuality: AVCaptureSession.Preset {
    didSet {
      configure(captureSession: captureSession, withQuality: cameraQuality, forMediaType: mediaType, andCameraPosition: cameraPosition)
    }
  }
  
  weak var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
  
  init(previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(),
       captureSession: AVCaptureSession = AVCaptureSession(),
       sessionQueue: DispatchQueue = DispatchQueue(queueLabel: .session),
       cameraPosition: AVCaptureDevice.Position = .back,
       cameraQuality: AVCaptureSession.Preset = .medium,
       mediaType: AVMediaType = .video) {
    
    self.previewLayer = previewLayer
    self.captureSession = captureSession
    self.sessionQueue = sessionQueue
    self.cameraPosition = cameraPosition
    self.cameraQuality = cameraQuality
    self.mediaType = mediaType
    
    self.previewLayer.videoGravity = .resizeAspectFill
    self.previewLayer.connection?.videoOrientation = .portrait
    self.previewLayer.session = self.captureSession
    
    isAuthorized(for: mediaType)
    sessionQueue.async { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.configure(captureSession: captureSession, withQuality: cameraQuality, forMediaType: mediaType, andCameraPosition: cameraPosition)
    }
  }
  
  @discardableResult
  func isAuthorized(for mediaType: AVMediaType) -> Bool {
    switch AVCaptureDevice.authorizationStatus(for: mediaType) {
    case .authorized:
      return true
    case .notDetermined:
      requestPermission(for: mediaType)
      return false
    default:
      return false
    }
  }
  
  func requestPermission(for mediaType: AVMediaType) {
    sessionQueue.suspend()
    AVCaptureDevice.requestAccess(for: mediaType) { [weak self] granted in
      guard let strongSelf = self else { return }
      if granted {
        strongSelf.configure(captureSession: strongSelf.captureSession,
                             withQuality: strongSelf.cameraQuality,
                             forMediaType: mediaType,
                             andCameraPosition: strongSelf.cameraPosition)
        
        strongSelf.sessionQueue.resume()
      }
    }
  }
  
  func configure(captureSession: AVCaptureSession, withQuality quality: AVCaptureSession.Preset, forMediaType mediaType: AVMediaType,
                 andCameraPosition cameraPosition: AVCaptureDevice.Position) {
    guard isAuthorized(for: mediaType) else { return }
    
    captureSession.sessionPreset = quality
    
    guard
      let captureDevice = AVCaptureDevice.default(for: mediaType),
      let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice),
      captureSession.canAddInput(captureDeviceInput)
      else { return }
    captureSession.addInput(captureDeviceInput)
    
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue(queueLabel: .videoOutput))
    
    guard captureSession.canAddOutput(videoOutput) else { return }
    captureSession.addOutput(videoOutput)
    
    guard
      let connection = videoOutput.connection(with: mediaType),
      connection.isVideoOrientationSupported,
      connection.isVideoMirroringSupported
    else { return }
    
    connection.videoOrientation = .portrait
    connection.isVideoMirrored = cameraPosition == .front
  }
}
