//
//  SwiftyTesseractRTE.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/5/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import AVFoundation
import SwiftyTesseract

infix operator |>: MultiplicationPrecedence
func |><T, U>(lhs: T, rhs: ((T) -> (U))) -> U {
  return rhs(lhs)
}

public protocol SwiftyTesseractRTEDelegate: class {
  func onRecognitionComplete(_ recognizedString: String)
  func captured(image: UIImage)
}

public class SwiftyTesseractRTE: NSObject {
  
  private var recognitionQueue: RecognitionQueue<String>
  private let swiftyTesseract: SwiftyTesseract
  private let captureSession = AVCaptureSession()
  private let sessionQueue = DispatchQueue(label: "recognition")
  private let cameraPosition: AVCaptureDevice.Position = .back
  private let cameraQuality: AVCaptureSession.Preset = .medium
  
  private let ciContext = CIContext()
  
  private var isAuthorized = false
  
  public weak var delegate: SwiftyTesseractRTEDelegate?
  
  public init(desiredReliability: RecognitionReliability,
              bundle: Bundle = .main,
              recognitionLanguage: RecognitionLanguage = .english) {
    recognitionQueue = RecognitionQueue(maxElements: 25)
    swiftyTesseract = SwiftyTesseract(language: recognitionLanguage, bundle: bundle, engineMode: .tesseractOnly)
    swiftyTesseract.whiteList = CharacterGroup.uppercase.rawValue.appending(CharacterGroup.numbers.rawValue).appending(".")
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
    guard let captureDevice = selectCaptureDevice() else { fatalError() }
    guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
    guard captureSession.canAddInput(captureDeviceInput) else { return }
    captureSession.addInput(captureDeviceInput)
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "otherQueue"))
    guard captureSession.canAddOutput(videoOutput) else { return }
    captureSession.addOutput(videoOutput)
    guard let connection = videoOutput.connection(with: .video) else { return }
    guard connection.isVideoOrientationSupported else { return }
    guard connection.isVideoMirroringSupported else { return }
    connection.videoOrientation = .portrait
//    connection.isVideoMirrored = cameraPosition == .back
  }
  
  private func selectCaptureDevice() -> AVCaptureDevice? {
    return AVCaptureDevice.DiscoverySession(deviceTypes:[.builtInDualCamera,
                                                         .builtInTelephotoCamera,
                                                         .builtInTrueDepthCamera,
                                                         .builtInWideAngleCamera],
                                            mediaType: .video,
                                            position: .back).devices.first
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

extension SwiftyTesseractRTE: AVCaptureVideoDataOutputSampleBufferDelegate {
  public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    guard let image = imageFrom(sampleBuffer: sampleBuffer) else { return }
    DispatchQueue.main.async { [weak self] in
      self?.delegate?.captured(image: image)
    }
    swiftyTesseract.performOCR(from: image) { [weak self] success, recognizedString in
      guard
        success,
        let recognizedString = recognizedString
      else { return }
      print(recognizedString)
//      self?.recognitionQueue.enqueue(recognizedString)
    }
    
    if recognitionQueue.allValuesMatch {
      guard let evaluatedString = recognitionQueue.dequeue() else { return }
      delegate?.onRecognitionComplete(evaluatedString)
      captureSession.stopRunning()
    }
    
  }
}

extension DispatchQueue {
  convenience init(queueLabel: DispatchQueueLabel) {
    self.init(label: queueLabel.rawValue)
  }
  
  convenience init(queueLabel: DispatchQueueLabel, qos: DispatchQoS, attributes: DispatchQueue.Attributes, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency, target: DispatchQueue?) {
    self.init(label: queueLabel.rawValue, qos: qos, attributes: attributes, autoreleaseFrequency: autoreleaseFrequency, target: target)
  }
}

