//
//  SwiftyTesseractRTE.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/5/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import SwiftyTesseract
import AVFoundation

// MARK: - SwiftyTesseractRTEDelegate definition
public protocol SwiftyTesseractRTEDelegate: class {
  func onRecognitionComplete(_ recognizedString: String)
  func captured(image: UIImage)
}

public class SwiftyTesseractRTE: NSObject {
  
  // MARK: - Private variables
  private var recognitionQueue: RecognitionQueue<String>
  
  // MARK: - Private constants
  private let swiftyTesseract: SwiftyTesseract
  private let imageProcessor: AVSampleProcessor
  private let videoManager: AVManager
  
  // MARK: - Public variables
  public var areaOfInterest: CGRect?
  
  // MARK: - Computed Properties
  public var previewLayer: AVCaptureVideoPreviewLayer {
    return videoManager.previewLayer
  }
  
  public var captureSession: AVCaptureSession {
    return videoManager.captureSession
  }

  public var whitelist: String? {
    set {
      swiftyTesseract.whiteList = newValue
    }
    get {
      return swiftyTesseract.whiteList
    }
  }
  
  public var cameraPosition: AVCaptureDevice.Position {
    return videoManager.cameraPosition
  }
  
  public var cameraQuality: AVCaptureSession.Preset {
    return videoManager.cameraQuality
  }
  
  // MARK: - Delegate
  public weak var delegate: SwiftyTesseractRTEDelegate?

  
  // MARK: - Initializers
  public convenience init(swiftyTesseract: SwiftyTesseract,
                          desiredReliability: RecognitionReliability,
                          imageProcessor: AVSampleProcessor,
                          cameraQuality: AVCaptureSession.Preset = .medium) {

    let recognitionQueue = RecognitionQueue<String>(desiredReliability: desiredReliability)
    let avManager = VideoManager(cameraQuality: cameraQuality)
    
    self.init(swiftyTesseract: swiftyTesseract,
              recognitionQueue: recognitionQueue,
              imageProcessor: imageProcessor,
              avManager: avManager)
  }
  
  public convenience init(swiftyTesseract: SwiftyTesseract,
                          desiredReliability: RecognitionReliability,
                          cameraQuality: AVCaptureSession.Preset = .medium) {
    
    let recognitionQueue = RecognitionQueue<String>(desiredReliability: desiredReliability)
    let videoManager = VideoManager(cameraQuality: cameraQuality)
    
    self.init(swiftyTesseract: swiftyTesseract,
              recognitionQueue: recognitionQueue,
              avManager: videoManager)
  }
  
  init(swiftyTesseract: SwiftyTesseract,
       recognitionQueue: RecognitionQueue<String>,
       imageProcessor: AVSampleProcessor = ImageProcessor(),
       avManager: AVManager = VideoManager()) {
    
    self.swiftyTesseract = swiftyTesseract
    self.recognitionQueue = recognitionQueue
    self.imageProcessor = imageProcessor
    self.videoManager = avManager
    super.init()
    self.videoManager.delegate = self
  }
  
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate Extension

extension SwiftyTesseractRTE: AVCaptureVideoDataOutputSampleBufferDelegate {
  
  public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    
    guard let grayscaleCgImage = imageProcessor.convertToGrayscaleCgImage(from: sampleBuffer) else { return }
    let grayscaleUiImage = UIImage(cgImage: grayscaleCgImage)
    
    guard
      let imageCroppedToPreviewLayer = imageProcessor.crop(output: grayscaleUiImage, toBoundsOf: previewLayer),
      let imageCroppedToAreaOfInterest = imageProcessor.crop(output: imageCroppedToPreviewLayer, toBoundsOf: areaOfInterest!, containedIn: previewLayer)
    else { return }

    delegate?.captured(image: imageCroppedToAreaOfInterest)
    
    swiftyTesseract.performOCR(from: imageCroppedToAreaOfInterest) { [weak self] success, recognizedString in
      guard success, let recognizedString = recognizedString, let strongSelf = self else { return }
      print("recognizedString in SwiftyTesseractRTE: \(recognizedString)")
      if strongSelf.recognitionQueue.count == strongSelf.recognitionQueue.size && strongSelf.recognitionQueue.allValuesMatch {
        strongSelf.delegate?.onRecognitionComplete(recognizedString)
        strongSelf.recognitionQueue.clear()
      } else {
        strongSelf.recognitionQueue.enqueue(recognizedString)
      }

    }
  }
}
