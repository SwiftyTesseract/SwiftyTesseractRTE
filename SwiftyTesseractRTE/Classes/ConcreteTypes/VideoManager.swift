//
//  VideoManager.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/19/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import AVFoundation

class VideoManager: AVManager {
  
  private let sessionQueue: DispatchQueue
  private let mediaType: AVMediaType
  private let videoOrientation: AVCaptureVideoOrientation
  private let cameraPosition: AVCaptureDevice.Position
  
  private(set) var previewLayer: AVCaptureVideoPreviewLayer
  private(set) var captureSession: AVCaptureSession
  
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
        strongSelf.configure(strongSelf.captureSession)
        strongSelf.sessionQueue.resume()
      }
    }
  }
  
  private func configure(_ captureSession: AVCaptureSession) {
    guard isAuthorized(for: mediaType) else { return }
    
    captureSession.sessionPreset = cameraQuality
    configureInput(for: captureSession)
    
    let connection = configureOutputConnection(for: captureSession)
    configureOutput(for: connection)
  }
  
  private func configureInput(for captureSession: AVCaptureSession) {
    guard
      let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: mediaType, position: cameraPosition),
      let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice),
      captureSession.canAddInput(captureDeviceInput)
    else { return }
    
    captureSession.addInput(captureDeviceInput)
  }
  
  private func configureOutputConnection(for captureSession: AVCaptureSession) -> AVCaptureConnection? {
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(delegate, queue: DispatchQueue(queueLabel: .videoOutput))
    
    guard captureSession.canAddOutput(videoOutput) else { return nil }
    captureSession.addOutput(videoOutput)
    
    return videoOutput.connection(with: mediaType)
  }
  
  private func configureOutput(for captureConnection: AVCaptureConnection?) {
    guard
      let captureConnection = captureConnection,
      captureConnection.isVideoOrientationSupported
    else { return }
    
    captureConnection.videoOrientation = videoOrientation
  }
  
  private func suspendQueueAndConfigureSession() {
    sessionQueue.suspend()
    configure(captureSession)
    sessionQueue.resume()
  }
}
