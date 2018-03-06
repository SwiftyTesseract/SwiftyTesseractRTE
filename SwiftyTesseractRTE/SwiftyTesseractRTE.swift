//
//  SwiftyTesseractRTE.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/5/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import AVFoundation

infix operator |>: MultiplicationPrecedence
func |><T, U>(lhs: T, rhs: ((T) -> (U))) -> U {
  return rhs(lhs)
}

protocol SwiftyTesseractRTEDelegate: class {
  func captured(image: UIImage)
}

class SwiftyTesseractRTE: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
  private let captureSession = AVCaptureSession()
  private let sessionQueue = DispatchQueue(label: "recognition")
  private let cameraPosition: AVCaptureDevice.Position = .front
  private let cameraQuality: AVCaptureSession.Preset = .medium
  
  private let ciContext = CIContext()
  
  private var isAuthorized = false
  
  public weak var delegate: SwiftyTesseractRTEDelegate?
  
  override init() {
    super.init()
    checkPermission()
    
    sessionQueue.async { [weak self] in
      self?.configureSession()
      self?.captureSession.startRunning()
    }
  }

  
  private func checkPermission() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      isAuthorized = true
    case .notDetermined:
      requestPermission()
    default:
      isAuthorized = false
    }
  }
  
  private func requestPermission() {
    sessionQueue.suspend()
    AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
      self?.isAuthorized = granted
      self?.sessionQueue.resume()
    }
  }
  
  private func configureSession() {
    guard isAuthorized else { return }
    captureSession.sessionPreset = cameraQuality
    guard let captureDevice = selectCaptureDevice() else { return }
    guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
    guard captureSession.canAddInput(captureDeviceInput) else { return }
    captureSession.addInput(captureDeviceInput)
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
    guard captureSession.canAddOutput(videoOutput) else { return }
    captureSession.addOutput(videoOutput)
  }
  
  private func selectCaptureDevice() -> AVCaptureDevice? {
    return AVCaptureDevice
      .DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                            mediaType: .video,
                                            position: .front)
      .devices.first
    
  }
  
  func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    guard let uiImage = imageFrom(sampleBuffer: sampleBuffer) else { return }
    DispatchQueue.main.async { [weak self] in
      self?.delegate?.captured(image: uiImage)
    }
    
  }
  
  private func imageFrom(sampleBuffer: CMSampleBuffer) -> UIImage? {
    return sampleBuffer |> cvImageBuffer |> ciImage |> cgImage |> uiImage
  }
  
  private func cvImageBuffer(from sampleBuffer: CMSampleBuffer) -> CVImageBuffer? {
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
    return imageBuffer
  }
  
  private func ciImage(from imageBuffer: CVImageBuffer?) -> CIImage? {
    guard let imageBuffer = imageBuffer else { return nil }
    return CIImage(cvImageBuffer: imageBuffer)
  }
  
  private func cgImage(from ciImage: CIImage?) -> CGImage? {
    guard
      let ciImage = ciImage,
      let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent)
    else { return nil }
    return cgImage
  }
  
  private func uiImage(from cgImage: CGImage?) -> UIImage? {
    guard let cgImage = cgImage else { return nil }
    return UIImage(cgImage: cgImage)
  }
}

