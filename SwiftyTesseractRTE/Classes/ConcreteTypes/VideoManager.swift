//
//  VideoManager.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/19/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import AVFoundation

class VideoManager: AVManager {
  
  private(set) var previewLayer: AVCaptureVideoPreviewLayer
  private(set) var captureSession: AVCaptureSession
  private(set) var sessionQueue: DispatchQueue
  private(set) var mediaType: AVMediaType
  private(set) var videoOrientation: AVCaptureVideoOrientation
  private(set) var cameraPosition: AVCaptureDevice.Position
  
  var cameraQuality: AVCaptureSession.Preset {
    didSet {
      suspendQueueAndConfigureSession()
    }
  }
  
  weak var delegate: AVCaptureVideoDataOutputSampleBufferDelegate? {
    didSet {
      suspendQueueAndConfigureSession()
    }
  }
  
  init(previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(),
       captureSession: AVCaptureSession = AVCaptureSession(),
       sessionQueue: DispatchQueue = DispatchQueue(queueLabel: .session),
       cameraPosition: AVCaptureDevice.Position = .back,
       cameraQuality: AVCaptureSession.Preset = .medium,
       videoOrientation: AVCaptureVideoOrientation = .portrait,
       mediaType: AVMediaType = .video) {
    
    self.previewLayer = previewLayer
    self.captureSession = captureSession
    self.sessionQueue = sessionQueue
    self.cameraPosition = cameraPosition
    self.cameraQuality = cameraQuality
    self.videoOrientation = videoOrientation
    self.mediaType = mediaType
    
    self.previewLayer.session = self.captureSession
    self.previewLayer.videoGravity = .resizeAspectFill
    
//    if isAuthorized(for: mediaType) {
//      sessionQueue.async { [weak self] in
//        guard let strongSelf = self else { return }
//        strongSelf.configure(captureSession: strongSelf.captureSession)
//      }
//    }
  }
  
  private func isAuthorized(for mediaType: AVMediaType) -> Bool {
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
  
  private func requestPermission(for mediaType: AVMediaType) {
    sessionQueue.suspend()
    AVCaptureDevice.requestAccess(for: mediaType) { [weak self] granted in
      guard let strongSelf = self else { return }
      if granted {
        strongSelf.configure(captureSession: strongSelf.captureSession)
        strongSelf.sessionQueue.resume()
      }
    }
  }
  
  private func configure(captureSession: AVCaptureSession) {
    guard
      let delegate = delegate,
      isAuthorized(for: mediaType)
    else { return }
    
    captureSession.sessionPreset = cameraQuality
    
    guard
      let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: mediaType, position: cameraPosition),
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
    
    connection.videoOrientation = videoOrientation
    connection.isVideoMirrored = cameraPosition == .front
  }
  
  private func suspendQueueAndConfigureSession() {
    sessionQueue.suspend()
    configure(captureSession: captureSession)
    sessionQueue.resume()
  }
}
