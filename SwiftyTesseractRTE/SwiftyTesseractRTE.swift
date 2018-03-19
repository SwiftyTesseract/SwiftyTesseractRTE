//
//  SwiftyTesseractRTE.swift
//  SwiftyTesseractRTE
//
//  Created by Steven Sherry on 3/5/18.
//  Copyright © 2018 Steven Sherry. All rights reserved.
//

import AVFoundation
import SwiftyTesseract

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
  public init(recognitionLanguage: RecognitionLanguage = .english,
              desiredReliability: RecognitionReliability,
              bundle: Bundle = .main,
              cameraPosition: AVCaptureDevice.Position = .back,
              cameraQuality: AVCaptureSession.Preset = .medium) {

    recognitionQueue = RecognitionQueue(desiredReliability: desiredReliability)
    swiftyTesseract = SwiftyTesseract(language: recognitionLanguage, bundle: .main, engineMode: .lstmOnly)
    self.imageProcessor = ImageProcessor()
    self.videoManager = VideoManager()
    super.init()
    self.videoManager.delegate = self
  }
  
//  init(recognitionLanguage: RecognitionLanguage,
//               desiredReliability: RecognitionReliability,
//               bundle: Bundle,
//               cameraPositions: AVCaptureDevice.Position,
//               cameraQuality: AVCaptureSession.Preset,
//               imageProcessor: AVSampleProcessor = ImageProcessor(),
//               avManager: AVManager = VideoManager(cameraPosition: cameraPosition,
//                                                   cameraQuality: cameraQuality),
//               recognitionQueue: RecognitionQueue<String> = RecognitionQueue(desiredReliability: desiredReliability)) {
//
//  }
  
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate Extension

extension SwiftyTesseractRTE: AVCaptureVideoDataOutputSampleBufferDelegate {
  
  public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    print("Thread priority \(Thread.threadPriority())")
    guard let cgImage = imageProcessor.convertToGrayscaleCgImage(from: sampleBuffer) else { return }

    let image = UIImage(cgImage: cgImage)
    guard
      let thisImage = imageProcessor.crop(output: image, toBoundsOf: previewLayer),
      let thatImage = imageProcessor.crop(output: thisImage, toBoundsOf: areaOfInterest!, containedIn: previewLayer)
    else { return }

    delegate?.captured(image: thatImage)
    swiftyTesseract.performOCR(from: thatImage) { [weak self] success, recognizedString in
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
